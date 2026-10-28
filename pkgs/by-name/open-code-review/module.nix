{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.open-code-review;

  defaultStateDir = "/var/lib/open-code-review";

  jsonFormat = pkgs.formats.json { };

  # Only emit keys the user actually set; upstream treats a present-but-empty
  # field differently from an absent one in a few places (notably `api_key`,
  # which suppresses the `api_key_cmd` fallback when non-empty).
  optionalAttr =
    name: value: lib.optionalAttrs (value != null && value != { } && value != [ ]) { ${name} = value; };

  providerEntry = {
    url = cfg.provider.url;
    protocol = cfg.provider.protocol;
  }
  // optionalAttr "api_key" cfg.provider.apiKey
  // optionalAttr "api_key_cmd" cfg.provider.apiKeyCmd
  // optionalAttr "models" cfg.provider.models
  // optionalAttr "auth_header" cfg.provider.authHeader
  // optionalAttr "timeout_sec" cfg.provider.timeoutSec
  // optionalAttr "extra_headers" cfg.provider.extraHeaders
  // optionalAttr "extra_body" cfg.provider.extraBody;

  # `providers` holds upstream's built-in presets; anything else has to live in
  # `custom_providers` or resolution fails with "not configured in <section>".
  providerSection =
    if builtins.elem cfg.provider.name presetProviders then "providers" else "custom_providers";

  presetProviders = [
    "anthropic"
    "baidu-qianfan"
    "bedrock"
    "chatgpt"
    "dashscope"
    "dashscope-tokenplan"
    "deepseek"
    "edenai"
    "gemini"
    "hy-tokenplan"
    "iflytek"
    "kimi"
    "kimi-global"
    "litellm"
    "mimo"
    "minimax"
    "minimax-cn"
    "mistral"
    "novita"
    "ollama-cloud"
    "openai"
    "openai-responses"
    "openrouter"
    "siliconflow"
    "siliconflow-cn"
    "tencent-tokenhub"
    "volcengine"
    "xai"
    "z-ai"
    "z-ai-coding"
  ];

  generatedSettings = {
    provider = cfg.provider.name;
    model = cfg.provider.model;
    ${providerSection} = {
      ${cfg.provider.name} = providerEntry;
    };
    telemetry = {
      enabled = cfg.telemetry.enable;
      content_logging = cfg.telemetry.contentLogging;
    }
    // optionalAttr "exporter" cfg.telemetry.exporter
    // optionalAttr "otlp_endpoint" cfg.telemetry.otlpEndpoint;
  };

  finalSettings = lib.recursiveUpdate generatedSettings cfg.settings;

  configFile = jsonFormat.generate "open-code-review-config.json" finalSettings;

  # Telemetry is opt-in upstream (it only switches on for OCR_ENABLE_TELEMETRY=1),
  # but both switches are pinned explicitly so the default stays off regardless.
  telemetryEnv = {
    OCR_ENABLE_TELEMETRY = if cfg.telemetry.enable then "1" else "0";
    OCR_CONTENT_LOGGING = if cfg.telemetry.contentLogging then "1" else "0";
  };

  viewerAddr = "${cfg.viewer.host}:${toString cfg.viewer.port}";
in
{
  options.services.open-code-review = {
    enable = lib.mkEnableOption "open-code-review, an AI-powered code review CLI";

    package = lib.mkPackageOption pkgs "open-code-review" { };

    installSystemWide = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Add the `ocr` CLI to {option}`environment.systemPackages` and export the
        `OCR_LLM_*` variables system-wide, so the configured provider works for
        every user without a per-home `config.json`.

        The token lands in `/etc/set-environment`, which is world-readable. Leave
        this on for a local endpoint whose key is a placeholder; turn it off and
        use {option}`services.open-code-review.provider.apiKeyCmd` with a per-user
        `~/.opencodereview/config.json` when the key is a real secret.
      '';
    };

    provider = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "ollama";
        description = ''
          Name of the provider to activate. Names matching an upstream preset
          (`anthropic`, `openai`, `ollama-cloud`, ...) are written to the
          `providers` section of `config.json`; anything else -- including the
          default `ollama`, which upstream has no preset for -- goes to
          `custom_providers`.
        '';
      };

      url = lib.mkOption {
        type = lib.types.str;
        default = "http://192.168.1.91:8012/v1";
        description = ''
          Base URL of the LLM endpoint. For an OpenAI-compatible server such as
          Ollama this must include the `/v1` suffix.
        '';
      };

      protocol = lib.mkOption {
        type = lib.types.enum [
          "openai"
          "openai-responses"
          "anthropic"
        ];
        default = "openai";
        description = ''
          Wire protocol to speak. Ollama's compatibility endpoint is `openai`.
        '';
      };

      model = lib.mkOption {
        type = lib.types.str;
        default = "gemmini-thinking";
        example = "qwen3-coder:30b";
        description = ''
          Model to review with. This has to name a model the configured endpoint
          actually serves; a name it does not recognise is only caught at review
          time, as an error from the provider rather than at evaluation time.
        '';
      };

      models = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "qwen3-coder:30b" ];
        description = "Models offered in `ocr config model`. Purely cosmetic.";
      };

      apiKey = lib.mkOption {
        type = lib.types.str;
        default = "ollama";
        description = ''
          API key sent to the endpoint. Upstream requires a non-empty token even
          for servers that ignore it, hence the placeholder default.

          This value is written to the world-readable Nix store. Use
          {option}`services.open-code-review.provider.apiKeyCmd` for real secrets.
        '';
      };

      apiKeyCmd = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "cat /run/secrets/ocr-api-key";
        description = ''
          Shell command whose stdout is used as the API key. Consulted only when
          {option}`services.open-code-review.provider.apiKey` is empty, so set
          that to `""` when using this. Keeps the secret out of the Nix store.
        '';
      };

      authHeader = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "Authorization";
        description = "Override the HTTP header the token is sent in.";
      };

      timeoutSec = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        example = 600;
        description = ''
          Per-request HTTP timeout in seconds (upstream default is 300). Local
          models on modest hardware frequently need this raised.
        '';
      };

      extraHeaders = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Extra HTTP headers sent with every request.";
      };

      extraBody = lib.mkOption {
        type = jsonFormat.type;
        default = { };
        example = {
          temperature = 0;
        };
        description = "Extra fields merged into the JSON request body.";
      };
    };

    telemetry = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Enable OpenTelemetry traces/metrics. Disabled by default, and the
          corresponding `OCR_ENABLE_TELEMETRY=0` is exported explicitly rather
          than relying on upstream's opt-in default.
        '';
      };

      contentLogging = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Include prompt and response bodies -- i.e. your source code -- in
          telemetry events. Keep this off unless you own the collector.
        '';
      };

      exporter = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "console"
            "otlp"
          ]
        );
        default = null;
        description = "Telemetry exporter. Upstream defaults to `console`.";
      };

      otlpEndpoint = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "http://127.0.0.1:4317";
        description = "OTLP collector address. Implies the `otlp` exporter.";
      };
    };

    settings = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      example = {
        language = "en";
        max_tokens = 32000;
        effort = "high";
      };
      description = ''
        Extra `config.json` settings, merged recursively over everything
        generated from the options above (this wins on conflict). Use it for
        keys without a dedicated option, such as `language`, `max_tokens`,
        `effort`, `mcp_servers` or a second provider entry.
      '';
    };

    viewer = {
      enable = lib.mkEnableOption "the open-code-review session viewer web UI";

      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        example = "0.0.0.0";
        description = ''
          Address the viewer binds to. The web UI has no authentication
          whatsoever, so only move this off loopback on a trusted network.
        '';
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 5483;
        description = "Port the viewer listens on.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "open-code-review";
        description = ''
          User to run the viewer as. The viewer renders the review sessions found
          under `$HOME/.opencodereview/sessions`, so this decides *whose* sessions
          are visible -- see {option}`services.open-code-review.viewer.homeDir`.
        '';
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "open-code-review";
        description = "Group to run the viewer as.";
      };

      homeDir = lib.mkOption {
        type = lib.types.path;
        default = defaultStateDir;
        example = "/home/alice";
        description = ''
          `HOME` for the viewer process, which is how upstream locates sessions
          (there is no flag for it).

          The default state directory starts out empty, so the viewer will show
          nothing until reviews are run as that user. To browse your own reviews,
          point this at your home directory and set
          {option}`services.open-code-review.viewer.user` to your username.
        '';
      };

      manageHomeConfig = lib.mkOption {
        type = lib.types.bool;
        defaultText = lib.literalExpression ''viewer.homeDir == "${defaultStateDir}"'';
        default = cfg.viewer.homeDir == defaultStateDir;
        description = ''
          Symlink the generated `config.json` into
          `''${viewer.homeDir}/.opencodereview/`.

          Defaults to false once {option}`services.open-code-review.viewer.homeDir`
          is pointed at a real user's home, because doing so would replace a
          hand-written config -- including any credentials in it -- with a store
          symlink. Set it explicitly to override that.
        '';
      };

      openBrowser = lib.mkOption {
        type = lib.types.enum [
          "auto"
          "always"
          "never"
        ];
        default = "never";
        description = ''
          Whether the viewer tries to launch a browser on start. `never` is the
          only sensible value for a system service.
        '';
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Open {option}`services.open-code-review.viewer.port` in the firewall.
          Given the viewer is unauthenticated, prefer an SSH tunnel or a
          reverse proxy that handles auth.
        '';
      };

      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Extra command-line arguments for `ocr viewer`.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.provider.apiKey != "" || cfg.provider.apiKeyCmd != null;
        message = ''
          services.open-code-review: one of provider.apiKey or provider.apiKeyCmd
          must be set -- open-code-review refuses to resolve an endpoint without a
          token, even for local servers that ignore it.
        '';
      }
      {
        assertion = cfg.installSystemWide -> cfg.provider.apiKey != "";
        message = ''
          services.open-code-review: installSystemWide exports the token through
          OCR_LLM_TOKEN, which cannot run provider.apiKeyCmd. Either set
          provider.apiKey, or set installSystemWide = false and configure a
          per-user ~/.opencodereview/config.json.
        '';
      }
      {
        assertion = cfg.viewer.enable -> !(cfg.viewer.openFirewall && cfg.viewer.host == "127.0.0.1");
        message = ''
          services.open-code-review.viewer: openFirewall is set while host is
          127.0.0.1, so the port would be opened but nothing would be reachable on
          it. Set viewer.host to an address reachable from the network.
        '';
      }
    ];

    warnings =
      lib.optional (cfg.viewer.enable && cfg.viewer.host != "127.0.0.1" && cfg.viewer.host != "localhost")
        ''
          services.open-code-review.viewer is bound to ${cfg.viewer.host}, exposing an
          unauthenticated web UI that serves the full text of reviewed source code
          and LLM output to anyone who can reach ${viewerAddr}.
        ''
      ++ lib.optional cfg.telemetry.contentLogging ''
        services.open-code-review.telemetry.contentLogging is enabled: prompts and
        responses, which contain your source code, will be sent to the telemetry
        exporter.
      '';

    environment.systemPackages = lib.mkIf cfg.installSystemWide [ cfg.package ];

    # Upstream reads config only from $HOME/.opencodereview/config.json and has no
    # --config flag, so a system-wide default has to go through the environment.
    # Resolution requires all three of URL/TOKEN/MODEL before it uses this path.
    environment.variables = lib.mkIf cfg.installSystemWide (
      telemetryEnv
      // {
        OCR_LLM_URL = cfg.provider.url;
        OCR_LLM_TOKEN = cfg.provider.apiKey;
        OCR_LLM_MODEL = cfg.provider.model;
        OCR_LLM_PROTOCOL = cfg.provider.protocol;
      }
      // lib.optionalAttrs (cfg.provider.timeoutSec != null) {
        OCR_LLM_TIMEOUT = toString cfg.provider.timeoutSec;
      }
    );

    # A reference copy users can symlink to ~/.opencodereview/config.json; the
    # CLI never reads this path by itself.
    environment.etc."open-code-review/config.json".source = configFile;

    users.users = lib.mkIf (cfg.viewer.enable && cfg.viewer.user == "open-code-review") {
      open-code-review = {
        isSystemUser = true;
        group = cfg.viewer.group;
        home = cfg.viewer.homeDir;
        description = "open-code-review session viewer";
      };
    };

    users.groups = lib.mkIf (cfg.viewer.enable && cfg.viewer.group == "open-code-review") {
      open-code-review = { };
    };

    systemd.tmpfiles.settings = lib.mkIf cfg.viewer.enable {
      "10-open-code-review" = {
        "${cfg.viewer.homeDir}/.opencodereview".d = {
          user = cfg.viewer.user;
          group = cfg.viewer.group;
          mode = "0750";
        };
        "${cfg.viewer.homeDir}/.opencodereview/sessions".d = {
          user = cfg.viewer.user;
          group = cfg.viewer.group;
          mode = "0750";
        };
      }
      // lib.optionalAttrs cfg.viewer.manageHomeConfig {
        "${cfg.viewer.homeDir}/.opencodereview/config.json"."L+".argument = "${configFile}";
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.viewer.enable && cfg.viewer.openFirewall) [
      cfg.viewer.port
    ];

    systemd.services.open-code-review-viewer = lib.mkIf cfg.viewer.enable {
      description = "open-code-review session viewer";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = telemetryEnv // {
        HOME = cfg.viewer.homeDir;
      };

      serviceConfig = {
        ExecStart = lib.escapeShellArgs (
          [
            (lib.getExe cfg.package)
            "viewer"
            "--addr"
            viewerAddr
            "--open"
            cfg.viewer.openBrowser
            "--color"
            "never"
          ]
          ++ cfg.viewer.extraArgs
        );

        User = cfg.viewer.user;
        Group = cfg.viewer.group;
        Restart = "on-failure";
        RestartSec = 5;

        StateDirectory = lib.mkIf (cfg.viewer.homeDir == defaultStateDir) "open-code-review";

        # The viewer only reads session files and serves HTTP; it never needs to
        # write outside its own home.
        AmbientCapabilities = lib.mkIf (cfg.viewer.port < 1024) [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = lib.mkIf (cfg.viewer.port >= 1024) [ "" ];
        DevicePolicy = "closed";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        # Not "true": the sessions the viewer exists to render usually live under
        # /home. ReadWritePaths below re-grants just the one directory.
        ProtectHome = lib.mkDefault (
          if lib.hasPrefix "/home" cfg.viewer.homeDir then "read-only" else true
        );
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        ReadWritePaths = [ "${cfg.viewer.homeDir}/.opencodereview" ];
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
        UMask = "0077";
      };
    };
  };
}
