{ config, pkgs, lib, ... }:

{
  home.username = "hernad";
  home.homeDirectory = "/home/hernad";
  home.sessionVariables.GTK_THEME = "yaru";

   
  programs.git = {
    enable = true;
    userName = "Ernad Husremovic";
    userEmail = "hernad@bring.out.ba";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Moka";
      package = pkgs.moka-icon-theme;
    };
    theme = {
      name = "yaru";
      package = pkgs.yaru-theme;
    };
    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=0
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=0
      '';
    };
  };

  # Use `dconf watch /` to track stateful changes you are doing, then set them here.
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      disable-extension-version-validation = true;
      # `gnome-extensions list` for a list
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "trayIconsReloaded@selfmade.pl"
        "Vitals@CoreCoding.com"
        "dash-to-panel@jderose9.github.com"
        # "sound-output-device-chooser@kgshank.net"
        "space-bar@luchrioh"
      ];
      favorite-apps = [ 
        "firefox.desktop" 
        "google-chrome.desktop"
        "code.desktop" 
        #"org.gnome.Terminal.desktop" 
        #"spotify.desktop" 
        "virt-manager.desktop" 
        "org.gnome.Nautilus.desktop"
        "fish.desktop"
        "calc.desktop"
        "writer.desktop"
        "dbeaver.desktop"
        "org.remmina.Remmina.desktop"
        "viber.desktop"
        ];
    };
    "org/gnome/desktop/interface" = {
      #color-scheme = "prefer-dark";
      color-scheme = "prefer-light";
      enable-hot-corners = false;
    };
    # `gsettings get org.gnome.shell.extensions.user-theme name`
    "org/gnome/shell/extensions/user-theme" = {
      name = "yaru";
    };
    "org/gnome/desktop/wm/preferences" = {
      workspace-names = [ "Main" ];
      button-layout = "appmenu:minimize,maximize,close";
    };
    "org/gnome/shell/extensions/vitals" = {
      show-storage = false;
      show-voltage = true;
      show-memory = true;
      show-fan = true;
      show-temperature = true;
      show-processor = true;
      show-network = true;
    };

    "org/gnome/desktop/interface" = {
        font-name = "Cantarell 13";
        document-font-name = "Cantarell 12";
        text-scaling-factor = 1.70;
        monospace-font-name = "Source Code Pro 12";
        titlebar-font = "Cantarell Bold 12";
        clock-show-weekday = true; 
    };

    "system/locale" = {
      region = "bs_BA.UTF-8";
    };

    "org/gnome/desktop/input-sources" = {
      #window-position = lib.hm.gvariant.mkTuple [100 100];

      sources = [
        (lib.hm.gvariant.mkTuple ["xkb" "us"]) 
        (lib.hm.gvariant.mkTuple ["xkb" "ba"])
      ];
    };

    "org/gnome/shell/extensions/dash-to-panel" = {
      panel-sizes = "{\"0\":64}"; # 32, 48, 64, 96
    };

    #"org/gnome/desktop/background" = {
    #  picture-uri = "file://${./saturn.jpg}";
    #  picture-uri-dark = "file://${./saturn.jpg}";
    #};
    #"org/gnome/desktop/screensaver" = {
    #  picture-uri = "file://${./saturn.jpg}";
    #  primary-color = "#3465a4";
    #  secondary-color = "#000000";
    #};
  };

  home.packages = with pkgs; [
    gnomeExtensions.user-themes
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.vitals
    gnomeExtensions.dash-to-panel
    # gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.space-bar
    firefox
    #neovimConfigured
    vim
    inkscape
    gimp
    #fix-vscode
    asciinema
    agg
    libreoffice
    dbeaver
    google-chrome
    #viber
  ] ++ (if stdenv.isx86_64 then [
    # kicad
    #chromium
    #spotify
    obs-studio
    obs-studio-plugins.obs-gstreamer
    obs-studio-plugins.obs-vkcapture
    obs-studio-plugins.obs-pipewire-audio-capture
    obs-studio-plugins.obs-multi-rtmp
    obs-studio-plugins.obs-move-transition
  ] else if stdenv.isAarch64 then [
    spotifyd
  ] else [ ]);


  #home.activation = {
  #      afterWriteBoundary = {
  #        after = [ "writeBoundary" ];
  #        before = [ ];
  #        data = ''
  #           true
  #        '';
  #      };
  #};
 
  
  
  #programs.vscode = {
  #  enable = true;
  #  package = pkgs.vscode.fhs;
  #  userSettings = {
  #    "workbench.colorTheme" = "Palenight Operator";
  #    "terminal.integrated.scrollback" = 10000;
  #    "terminal.integrated.fontFamily" = "Jetbrains Mono";
  #    "terminal.integrated.fontSize" = 16;
  #    "editor.fontFamily" = "Jetbrains Mono";
  #    "telemetry.telemetryLevel" = "off";
  #    "remote.SSH.useLocalServer" = false;
  #    "editor.fontSize" = 18;
  #    "editor.formatOnSave" = true;
  #    "workbench.startupEditor" = "none";
  #    "window.titleBarStyle" = "custom";
  #  };
  #  extensions = with pkgs.vscode-extensions; [
  #    bbenoist.nix
  #    ms-vscode-remote.remote-ssh
  #    github.vscode-pull-request-github
  #    editorconfig.editorconfig
  #    matklad.rust-analyzer
  #    mkhl.direnv
  #    jock.svg
  #    usernamehw.errorlens
  #    vadimcn.vscode-lldb
  #    bungcip.better-toml
  #    msjsdiag.debugger-for-chrome
  #  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
  #    {
  #      name = "material-palenight-theme";
  #      publisher = "whizkydee";
  #      version = "2.0.2";
  #      sha256 = "sha256-//EpXe+kKloqbMIZ8kstUKdYB490tQBBilB3Z9FfBNI=";
  #    }
  #    {
  #      name = "todo-tree";
  #      publisher = "Gruntfuggly";
  #      version = "0.0.215";
  #      sha256 = "sha256-WK9J6TvmMCLoqeKWh5FVp1mNAXPWVmRvi/iFuLWMylM=";
  #    }
  #    {
  #      name = "hexeditor";
  #      publisher = "ms-vscode";
  #      version = "1.9.8";
  #      sha256 = "sha256-XgRD2rDSLf1uYBm5gBmLzT9oLCpBmhtfoabKBekldhg=";
  #    }
  #  ] ++ (if pkgs.stdenv.isx86_64 then with pkgs.vscode-extensions; [
  #    ms-python.python
  #    ms-vscode.cpptools
  #  ] else [ ]);
  #};

  # https://github.com/andyrichardson/dotfiles/blob/28c3630e71d65d92b88cf83b2f91121432be0068/nix/home/vscode.nix

  #xdg.configFile."Code/User/settings.json".source = lib.mkForce config.lib.file.mkOutOfStoreSymlink
  #       "${config.home.homeDirectory}/dev/dotfiles/nix/config/settings.json";

 
  
  programs.fish.enable = true;
  programs.fish.shellInit = ''
    function fish_greeting
      ${pkgs.neofetch}/bin/neofetch --config ${../../config/neofetch/config}
    end
  '';
  programs.fish.interactiveShellInit = ''
    source "${pkgs.fzf}/share/fzf/key-bindings.fish"
    ${pkgs.direnv}/bin/direnv hook fish | source
    ${pkgs.starship}/bin/starship init fish | source
  '';

  xdg.configFile."libvirt/qemu.conf".text = ''
    nvram = ["/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd"]
  '';

  programs.home-manager.enable = true;
  home.stateVersion = "22.11";
}
