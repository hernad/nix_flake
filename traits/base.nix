/*
  A trait for all boxxen
*/
{ config, pkgs, lib, ... }:

{
  config = {
    time.timeZone = "Europe/Sarajevo";
    # Windows wants hardware clock in local time instead of UTC
    time.hardwareClockInLocalTime = true;

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.supportedLocales = [ "all" ];

    # https://stackoverflow.com/questions/54811067/how-can-i-install-extension-of-vscode

  environment.systemPackages = with pkgs;
    let
      vcsodeWithExtension = vscode-with-extensions.override {
        # When the extension is already available in the default extensions set.
        vscodeExtensions = with vscode-extensions; [
          # nixpkgs/applications/editors/vscode/extensions/default.nix
          # bbenoist.nix = buildVscodeMarketplaceExtension { name = Nix ...
          # }
          bbenoist.nix
          bmalehorn.vscode-fish
          brettm12345.nixfmt-vscode
          bungcip.better-toml
          codezombiech.gitignore
          #denoland.vscode-deno
          dotjoshjohnson.xml
          ms-python.python
        ]
        # Concise version from the vscode market place when not available in the default set.
        ++ vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "code-runner";
            publisher = "formulahendry";
            version = "0.12.0";
            sha256 = "43681cb9c946ecd2d1f351e32a3ff4445d2333912a7b6bd931ba6869ba7fa2c8";
          }
        ];
      };

    in [
        remmina
        patchelf
        silver-searcher
        direnv
        nix-direnv
        git
        python310
        ansible
        jq
        fzf
        ripgrep
        lsof
        htop
        bat
        grex
        broot
        bottom
        fd
        sd
        fio
        hyperfine
        tokei
        bandwhich
        lsd
        #abduco
        #dvtm
        ntfs3g
        killall
        gptfdisk
        fio
        smartmontools
        rnix-lsp
        graphviz
        simple-http-server
        vcsodeWithExtension
  ];

    #environment.systemPackages = with pkgs; [
    #  # Shell utilities
    #  patchelf
    #  direnv
    #  nix-direnv
    #  git
    #  python310
    #  jq
    #  fzf
    #  ripgrep
    #  lsof
    #  htop
    #  bat
    #  grex
    #  broot
    #  bottom
    #  fd
    #  sd
    #  fio
    #  hyperfine
    #  tokei
    #  bandwhich
    #  lsd
    #  abduco
    #  dvtm
    #  #neovim-remote
    #  ntfs3g
    #  # nvme-cli
    #  # nvmet-cli
    #  # libhugetlbfs # This has a build failure.
    #  killall
    #  gptfdisk
    #  fio
    #  smartmontools
    #  neovimConfigured
    #  rnix-lsp
    #  graphviz
    #  simple-http-server
    #];

    environment.shellAliases = { };
    environment.variables = {
      EDITOR = "${pkgs.neovimConfigured}/bin/nvim";
    };
    environment.pathsToLink = [
      "/share/nix-direnv"
    ];

    programs.bash.promptInit = ''
      eval "$(${pkgs.starship}/bin/starship init bash)"
    '';
    programs.bash.shellInit = ''
    '';
    programs.bash.loginShellInit = ''
      HAS_SHOWN_NEOFETCH=''${HAS_SHOWN_NEOFETCH:-false}
      if [[ $- == *i* ]] && [[ "$HAS_SHOWN_NEOFETCH" == "false" ]]; then
        ${pkgs.neofetch}/bin/neofetch --config ${../config/neofetch/config}
        HAS_SHOWN_NEOFETCH=true
      fi
    '';
    programs.bash.interactiveShellInit = ''
      eval "$(${pkgs.direnv}/bin/direnv hook bash)"
      source "${pkgs.fzf}/share/fzf/key-bindings.bash"
      source "${pkgs.fzf}/share/fzf/completion.bash"
    '';

    security.sudo.wheelNeedsPassword = false;
    security.sudo.extraConfig = ''
      Defaults lecture = never
    '';

    # Use edge NixOS.
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';
    # nix.package = pkgs.nixUnstable;

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    nixpkgs.config.allowUnfree = true;

    # Hack: https://github.com/NixOS/nixpkgs/issues/180175
    systemd.services.systemd-udevd.restartIfChanged = false;

    
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "22.11"; # Did you read the comment?
  };
}
