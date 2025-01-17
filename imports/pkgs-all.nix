{ ... }:
{

  perSystem =
    { pkgs, ... }:
    {
      packages = {
        intrinsics-viewer = pkgs.callPackage ../pkgs/by-name/intrinsics-viewer { };
      };
    };
}
