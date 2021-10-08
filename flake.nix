{
  description = "A CLI drag-and-drop tool";

  inputs = {
    flake-utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "master";
    };

    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixpkgs-unstable";
    };

    pre-commit-hooks = {
      type = "github";
      owner = "cachix";
      repo = "pre-commit-hooks.nix";
      ref = "master";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    { self
    , flake-utils
    , nixpkgs
    , pre-commit-hooks
    }:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        };
      in
      rec {
        apps = {
          dragger = flake-utils.lib.mkApp { drv = packages.dragger; };
        };

        checks = {
          pre-commit = pre-commit-hooks.lib.${system}.run {
            src = self;

            hooks = {
              clang-format = {
                enable = true;
                name = "clang-format";
                entry = "${pkgs.clang-tools}/bin/clang-format -style=file -i";
                types = [ "text" "c++" ];
                language = "system";
              };

              nixpkgs-fmt = {
                enable = true;
              };
            };
          };
        };

        defaultApp = apps.dragger;

        defaultPackage = packages.dragger;

        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ ]
          ++ defaultPackage.nativeBuildInputs
          ++ defaultPackage.buildInputs
          ;

          inherit (checks.pre-commit) shellHook;
        };

        packages = {
          inherit (pkgs) dragger;
        };
      }) // {
      overlay = final: prev: {
        dragger = with final; stdenv.mkDerivation {
          pname = "dragger";
          version = "0.0.0";

          src = self;

          buildInputs = [
            libsForQt5.qt5.qtbase
          ];

          nativeBuildInputs = [
            libsForQt5.qt5.wrapQtAppsHook
          ];

          configurePhase = ''
            qmake
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp dragger $out/bin
          '';

          meta = with lib; {
            description = "A CLI drag-and-drop tool";
            homepage = "https://gitea.belanyi.fr/ambroisie/dragger";
            license = licenses.mit;
            maintainers = [ ambroisie ];
            platforms = platforms.all;
          };
        };
      };
    };
}
