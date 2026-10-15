{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.nbd-vram;

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    mkMerge
    types
    optional
    optionalAttrs
    literalExpression
    ;

  libexec = "${cfg.package}/libexec/nbd-vram";

  # Upstream's installer bakes `nproc` into the unit. We resolve it at runtime
  # instead so the config isn't tied to the build machine. The daemon caps
  # threads at 64, so connections are capped to match.
  envDefaults = ''
    n=$(${pkgs.coreutils}/bin/nproc)
    [ "$n" -gt 64 ] && n=64
    export VRAM_NBD_THREADS="''${VRAM_NBD_THREADS:-$n}"
    export VRAM_NBD_CONNECTIONS="''${VRAM_NBD_CONNECTIONS:-$VRAM_NBD_THREADS}"
  '';

  # `exec` keeps the daemon as the unit's main PID, which Type=notify needs.
  startDaemon = pkgs.writeShellScript "nbd-vram-start" ''
    ${envDefaults}
    exec ${cfg.package}/bin/nbd-vram
  '';

  connect = pkgs.writeShellScript "nbd-vram-connect" ''
    ${envDefaults}
    exec ${libexec}/nbd-vram-connect
  '';

  sysctlOr = key: default: toString (config.boot.kernel.sysctl.${key} or default);
in
{
  options.services.nbd-vram = {
    enable = mkEnableOption "nbd-vram, NVIDIA VRAM as swap over NBD";

    package = mkOption {
      type = types.package;
      default = pkgs.nbd-vram or (pkgs.callPackage ./package.nix { });
      defaultText = literalExpression "pkgs.callPackage ./package.nix { }";
      description = "The nbd-vram package to use.";
    };

    sizeMB = mkOption {
      type = types.ints.positive;
      default = 7168;
      description = ''
        Maximum VRAM to allocate for swap, in MiB. The daemon backs off in
        512 MiB steps if the GPU can't provide this much, so it's a ceiling.
        Leave headroom if the card also drives a display or runs games.
      '';
    };

    priority = mkOption {
      type = types.int;
      default = 1500;
      description = "Swap priority of the VRAM device (higher is used first).";
    };

    threads = mkOption {
      type = types.nullOr (types.ints.between 1 64);
      default = null;
      description = "Daemon worker threads. `null` means `nproc` at runtime (capped at 64).";
    };

    connections = mkOption {
      type = types.nullOr (types.ints.between 1 64);
      default = null;
      description = "NBD connections. `null` means the same as the thread count. Keep equal to `threads`.";
    };

    nvidiaPersistenceMode = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Run `nvidia-smi -pm 1` before starting, which wakes the GPU and avoids
        GSP RPC timeouts (Xid 119) on laptops. Failure is ignored.
      '';
    };

    nvidiaSmi = mkOption {
      type = types.str;
      default = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi";
      defaultText = literalExpression ''"''${config.hardware.nvidia.package.bin}/bin/nvidia-smi"'';
      description = "Path to nvidia-smi.";
    };

    vmTuning = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          While the service runs, raise swappiness and min_free_kbytes so the
          kernel swaps before RAM is exhausted and always has memory left to
          service swap I/O. Restored on stop (to your `boot.kernel.sysctl`
          values if set, otherwise 60 / 65536 like upstream).
        '';
      };
      swappiness = mkOption {
        type = types.ints.between 0 200;
        default = 200;
        description = "vm.swappiness while the service runs.";
      };
      minFreeKbytes = mkOption {
        type = types.ints.positive;
        default = 524288;
        description = "vm.min_free_kbytes while the service runs.";
      };
    };

    suspendHook = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Tear the swap down before suspend/hibernate and rebuild it on resume.
        Required for correctness on machines that sleep: suspend destroys the
        CUDA context backing the device and in-flight swap I/O hangs resume.
      '';
    };

    powerManagement = {
      enable = mkEnableOption "stopping VRAM swap on battery power (udev AC events plus a 60s poll)";
      disableOnBattery = mkOption {
        type = types.bool;
        default = true;
        description = "Stop VRAM swap whenever AC is unplugged.";
      };
      batteryThreshold = mkOption {
        type = types.ints.between 0 100;
        default = 20;
        description = ''
          When on battery and `disableOnBattery` is false, stop VRAM swap once
          the battery drops below this percentage. 0 disables the check.
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages = [ cfg.package ];

      boot.kernelModules = [ "nbd" ];
      boot.extraModprobeConfig = "options nbd max_part=0";

      systemd.services.vram-swap-nbd = {
        description = "VRAM Swap via NBD (CUDA memcpy backend)";
        wantedBy = [ "multi-user.target" ];
        # After the display manager so the GUI claims its VRAM first; grabbing it
        # earlier on a cold boot can starve Xorg.
        after = [
          "systemd-modules-load.service"
          "nvidia-persistenced.service"
          "display-manager.service"
        ];
        wants = [ "nvidia-persistenced.service" ];

        # Stopping runs swapoff, which can take minutes with GBs swapped out.
        # Don't do that implicitly on every nixos-rebuild switch.
        restartIfChanged = false;

        environment = {
          VRAM_SETUP_SIZE_MB = toString cfg.sizeMB;
          VRAM_SWAP_PRIORITY = toString cfg.priority;
          VRAM_TUNE_VM = if cfg.vmTuning.enable then "1" else "0";
          VRAM_RESTORE_SWAPPINESS = sysctlOr "vm.swappiness" 60;
          VRAM_RESTORE_MIN_FREE_KBYTES = sysctlOr "vm.min_free_kbytes" 65536;
        }
        // optionalAttrs (cfg.threads != null) { VRAM_NBD_THREADS = toString cfg.threads; }
        // optionalAttrs (cfg.connections != null) { VRAM_NBD_CONNECTIONS = toString cfg.connections; };

        serviceConfig = {
          Type = "notify";
          NotifyAccess = "main";

          ExecStartPre =
            optional cfg.nvidiaPersistenceMode "-${cfg.nvidiaSmi} -pm 1"
            ++ optional cfg.vmTuning.enable
              "${pkgs.procps}/bin/sysctl -w vm.swappiness=${toString cfg.vmTuning.swappiness} vm.min_free_kbytes=${toString cfg.vmTuning.minFreeKbytes}";
          ExecStart = startDaemon;
          ExecStartPost = connect;
          ExecStop = "${libexec}/nbd-vram-disconnect";

          LimitMEMLOCK = "infinity";
          OOMScoreAdjust = -1000;

          Restart = "on-failure";
          RestartSec = 10;
          TimeoutStartSec = 60;
          # Never SIGKILL: a killed daemon takes live swap pages with it and the
          # kernel treats that as memory corruption. See upstream unit comments.
          TimeoutStopSec = 1800;
          SendSIGKILL = false;
          KillMode = "process";
          SyslogIdentifier = "nbd-vram";
        };
      };
    }

    (mkIf cfg.suspendHook {
      systemd.services.vram-swap-nbd-suspend = {
        description = "Tear down VRAM swap before sleep so the GPU can power down cleanly";
        wantedBy = [ "sleep.target" ];
        before = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
          "systemd-hybrid-sleep.service"
          "systemd-suspend-then-hibernate.service"
          "nvidia-suspend.service"
          "nvidia-hibernate.service"
        ];
        # Stop as soon as sleep.target goes away on resume, which runs ExecStop
        # (the restore) and re-arms ExecStart for the next sleep.
        unitConfig.StopWhenUnneeded = true;
        restartIfChanged = false;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${libexec}/nbd-vram-sleep pre";
          ExecStop = "${libexec}/nbd-vram-sleep post";
        };
      };
    })

    {
      # The power-check script always reads this; it's a no-op unless enabled.
      environment.etc."nbd-vram.conf".text = ''
        VRAM_POWER_MANAGEMENT=${if cfg.powerManagement.enable then "1" else "0"}
        VRAM_DISABLE_ON_BATTERY=${if cfg.powerManagement.disableOnBattery then "1" else "0"}
        VRAM_BATTERY_THRESHOLD=${toString cfg.powerManagement.batteryThreshold}
      '';
    }

    (mkIf cfg.powerManagement.enable {
      systemd.services.nbd-vram-power-check = {
        description = "nbd-vram power state check";
        after = [ "vram-swap-nbd.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${libexec}/nbd-vram-power-check";
        };
      };

      # Battery-threshold poll; activates nbd-vram-power-check.service.
      systemd.timers.nbd-vram-power-check = {
        description = "nbd-vram battery threshold poll (60s)";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnActiveSec = 60;
          OnUnitActiveSec = 60;
        };
      };

      services.udev.extraRules = ''
        ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="${config.systemd.package}/bin/systemctl --no-block start nbd-vram-power-check.service"
      '';
    })
  ]);
}
