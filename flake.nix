{
  description = "Hoverbear's Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      # url = "github:nix-community/NixOS-WSL";
      url = "github:K900/NixOS-WSL/native-systemd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      overlays.default = final: prev: {
        neovimConfigured = final.callPackage ./packages/neovimConfigured { };
        fix-vscode = final.callPackage ./packages/fix-vscode { };
      };

      packages = forAllSystems
        (system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
              config.allowUnfree = true;
            };
          in
          {
            inherit (pkgs) neovimConfigured fix-vscode;

            # Excluded from overlay deliberately to avoid people accidently importing it.
            unsafe-bootstrap-zfs = pkgs.callPackage ./packages/unsafe-bootstrap-zfs { };
            unsafe-bootstrap-btrfs = pkgs.callPackage ./packages/unsafe-bootstrap-btrfs { };
            mount-btrfs = pkgs.callPackage ./packages/mount-btrfs { };
            mount-zfs = pkgs.callPackage ./packages/mount-zfs { };
          });

      devShells = forAllSystems
        (system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            };
          in
          {
            default = pkgs.mkShell
              {
                inputsFrom = with pkgs; [ ];
                buildInputs = with pkgs; [
                  nixpkgs-fmt
                ];
              };
          });

      homeConfigurations = forAllSystems
        (system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            };
          in
          {
            hernad = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              # https://github.com/nix-community/home-manager/issues/1800
              # https://github.com/andyrichardson/dotfiles/blob/28c3630e71d65d92b88cf83b2f91121432be0068/nix/home/vscode.nix
              modules = [
                ./users/hernad/home.nix
              ];
            };
          }
        );

      nixosConfigurations =
        let
          # Shared config between both the liveimage and real system
          aarch64Base = {
            system = "aarch64-linux";
            modules = with self.nixosModules; [
              ({ config = { nix.registry.nixpkgs.flake = nixpkgs; }; })
              home-manager.nixosModules.home-manager
              traits.overlay
              traits.base
              services.openssh
            ];
          };
          x86_64Base = {
            system = "x86_64-linux";
            modules = with self.nixosModules; [
              ({ config = { nix.registry.nixpkgs.flake = nixpkgs; }; })
              home-manager.nixosModules.home-manager
              traits.overlay
              traits.base
              services.openssh
            ];
          };
        in
        with self.nixosModules; {
          x86_64IsoImage = nixpkgs.lib.nixosSystem {
            inherit (x86_64Base) system;
            modules = x86_64Base.modules ++ [
              platforms.iso
            ];
          };
          aarch64IsoImage = nixpkgs.lib.nixosSystem {
            inherit (aarch64Base) system;
            modules = aarch64Base.modules ++ [
              platforms.iso
              {
                config = {
                  virtualisation.vmware.guest.enable = nixpkgs.lib.mkForce false;
                  services.xe-guest-utilities.enable = nixpkgs.lib.mkForce false;
                };
              }
            ];
          };
          honeycombIsoImage = nixpkgs.lib.nixosSystem {
            inherit (aarch64Base) system;
            modules = aarch64Base.modules ++ [
              platforms.iso
              traits.honeycomb_lx2k
              {
                config = {
                  virtualisation.vmware.guest.enable = nixpkgs.lib.mkForce false;
                  services.xe-guest-utilities.enable = nixpkgs.lib.mkForce false;
                };
              }
            ];
          };
          
          lenovo16 = nixpkgs.lib.nixosSystem {
            inherit (x86_64Base) system;
            modules = x86_64Base.modules ++ [
              traits.machine_zfs
              platforms.lenovo16
              traits.workstation
              traits.gnome
              traits.hardened
              traits.gaming
              traits.jetbrains
             users.hernad
            ];
          };
        
          lenovo16b = nixpkgs.lib.nixosSystem {
            inherit (x86_64Base) system;
            modules = x86_64Base.modules ++ [
              traits.machine_btrfs
              platforms.lenovo16b
              traits.workstation
              traits.gnome
              traits.hardened
              traits.gaming
              traits.jetbrains
             users.hernad
            ];
          };
          #gizmo = nixpkgs.lib.nixosSystem {
          #  inherit (aarch64Base) system;
          #  modules = aarch64Base.modules ++ [
          #    platforms.gizmo
          #    traits.honeycomb_lx2k
          #    traits.machine
          #    traits.workstation
          #    traits.gnome
          #    traits.hardened
          #    users.hernad
          #  ];
          #};
          #architect = nixpkgs.lib.nixosSystem {
          #  inherit (x86_64Base) system;
          #  modules = x86_64Base.modules ++ [
          #    platforms.architect
          #    traits.machine
          #    traits.workstation
          #    traits.gnome
          #    traits.hardened
          #    traits.gaming
          #    users.hernad
          #  ];
          #};
          #nomad = nixpkgs.lib.nixosSystem {
          #  inherit (x86_64Base) system;
          #  modules = x86_64Base.modules ++ [
          #    platforms.nomad
          #    traits.machine
          #    traits.workstation
          #    traits.gnome
          #    traits.hardened
          #    users.hernad
          #  ];
          #};
          wsl = nixpkgs.lib.nixosSystem {
            inherit (x86_64Base) system;
            modules = x86_64Base.modules ++ [
              nixos-wsl.nixosModules.wsl
              platforms.wsl
              users.hernad
            ];
          };
        };

      nixosModules = {
        platforms.container = ./platforms/container.nix;
        platforms.wsl = ./platforms/wsl.nix;
        #platforms.gizmo = ./platforms/gizmo.nix;
        #platforms.architect = ./platforms/architect.nix;
        #platforms.nomad = ./platforms/nomad.nix;
        platforms.lenovo16 = ./platforms/lenovo16.nix;
        platforms.lenovo16b = ./platforms/lenovo16b.nix;
        platforms.iso-minimal = "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix";
        platforms.iso = "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix";
        traits.overlay = { nixpkgs.overlays = [ self.overlays.default ]; };
        traits.base = ./traits/base.nix;
        traits.machine_btrfs = ./traits/machine_btrfs.nix;
        traits.machine_zfs = ./traits/machine_zfs.nix;
        traits.gaming = ./traits/gaming.nix;
        traits.gnome = ./traits/gnome.nix;
        traits.jetbrains = ./traits/jetbrains.nix;
        traits.hardened = ./traits/hardened.nix;
        traits.sourceBuild = ./traits/source-build.nix;
        traits.honeycomb_lx2k = ./traits/honeycomb_lx2k.nix;
        services.postgres = ./services/postgres.nix;
        services.openssh = ./services/openssh.nix;
        # This trait is unfriendly to being bundled with platform-iso
        traits.workstation = ./traits/workstation.nix;
        users.hernad = ./users/hernad;
      };

      checks = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        {
          format = pkgs.runCommand "check-format"
            {
              buildInputs = with pkgs; [ rustfmt cargo ];
            } ''
            ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}
            touch $out # it worked!
          '';
        });

    };
}
