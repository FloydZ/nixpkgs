{ ... }:
{

  perSystem =
    { pkgs, ... }:
    {
      packages = {
        alive2              = pkgs.callPackage ../pkgs/by-name/alive2 {};
        assemblyline        = pkgs.callPackage ../pkgs/by-name/assemblyline {};
        audiblez            = pkgs.callPackage ../pkgs/by-name/audiblez {};
        autoperf            = pkgs.callPackage ../pkgs/by-name/autoperf {};
        blaster             = pkgs.callPackage ../pkgs/by-name/blaster {};
        bosphorus           = pkgs.callPackage ../pkgs/by-name/bosphorus {};
        coz                 = pkgs.callPackage ../pkgs/by-name/coz {};
        cpu_features        = pkgs.callPackage ../pkgs/by-name/cpu_features {};
        espresso            = pkgs.callPackage ../pkgs/by-name/espresso {};
        flatter             = pkgs.callPackage ../pkgs/by-name/flatter {};
        hardinfo2           = pkgs.callPackage ../pkgs/by-name/hardinfo2 {};
        hexl                = pkgs.callPackage ../pkgs/by-name/hexl {};
        intel-oneapi-vtune  = pkgs.callPackage ../pkgs/by-name/intel-oneapi-vtune {};
        intrinsics-viewer   = pkgs.callPackage ../pkgs/by-name/intrinsics-viewer {};
        jfs                 = pkgs.callPackage ../pkgs/by-name/jfs {};
        libcoral            = pkgs.callPackage ../pkgs/by-name/libcoral  {};
        libedgetpu          = pkgs.callPackage ../pkgs/by-name/libedgetpu {};
        libsafec            = pkgs.callPackage ../pkgs/by-name/libsafec {};
        measuresuite        = pkgs.callPackage ../pkgs/by-name/measuresuite {};
        metasearch2         = pkgs.callPackage ../pkgs/by-name/metasearch2 {};
        nanobench           = pkgs.callPackage ../pkgs/by-name/nanobench {};
        not-perf            = pkgs.callPackage ../pkgs/by-name/not-perf {};
        oneapi              = pkgs.callPackage ../pkgs/by-name/oneapi {};
        orbit               = pkgs.callPackage ../pkgs/by-name/orbit {};
        paper2remarkable    = pkgs.callPackage ../pkgs/by-name/paper2remarkable   {};
        parafrost           = pkgs.callPackage ../pkgs/by-name/parafrost {};
        perf2perfetto       = pkgs.callPackage ../pkgs/by-name/perf2perfetto {};
        perf_data_converter = pkgs.callPackage ../pkgs/by-name/perf_data_converter {};
        pythonpackages      = pkgs.callPackage ../pkgs/by-name/pythonpackages {};
        quine-mccluskey     = pkgs.callPackage ../pkgs/by-name/quine-mccluskey {};
        seal                = pkgs.callPackage ../pkgs/by-name/seal {};
        shot                = pkgs.callPackage ../pkgs/by-name/shot {};
        slurm-web           = pkgs.callPackage ../pkgs/by-name/slurm-web {};
        smtgcc              = pkgs.callPackage ../pkgs/by-name/smtgcc {};
        souper              = pkgs.callPackage ../pkgs/by-name/souper {};
        ternarylogiccli     = pkgs.callPackage ../pkgs/by-name/ternarylogiccli {};
        usuba               = pkgs.callPackage ../pkgs/by-name/usuba {};
        vtune               = pkgs.callPackage ../pkgs/by-name/vtune {};
      };
    };
}
