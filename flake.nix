{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    zig-overlay.url = "github:mitchellh/zig-overlay";
    android.url = "github:tadfisher/android-nixpkgs";

    zig-overlay.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, zig-overlay, android, devshell }:
    {
      overlay = final: prev: {
        inherit (self.packages.${final.system}) android-sdk zig;
      };
    }
    //
    flake-utils.lib.eachSystem ["x86_64-linux"] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            devshell.overlay
            self.overlay
          ];
        };
      in
      rec {
        packages = {
          zig = zig-overlay.packages.${system}.master;
          android-sdk = android.sdk.${system} (sdkPkgs: with sdkPkgs; [
            build-tools-33-0-0
            cmdline-tools-latest
            emulator
            platform-tools
            platforms-android-21
            ndk-25-1-8937393
          ]);
        };

        devShells.android = import ./devshell.nix { inherit pkgs; };
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            pkg-config
            gtk3
          ];

          shellHook =
            ''
              export XDG_DATA_DIRS=$GSETTINGS_SCHEMAS_PATH:$XDG_DATA_DIRS
            '';
        };
      });
}
