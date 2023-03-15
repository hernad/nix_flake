{ config, pkgs, lib, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      #jetbrains.clion
      #jetbrains.datagrip
      jetbrains.pycharm-professional
    ];

    # CLion requires cargo-xlib.
    environment.noXlibs = lib.mkForce false;

    nixpkgs.config.allowUnfree = true;
  };
}
