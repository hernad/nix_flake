{ writeShellApplication, bash, gum, cryptsetup, gptfdisk, btrfs-progs, dosfstools, ... }:

# https://nixos.org/manual/nixpkgs/stable/#trivial-builder-writeShellApplication

writeShellApplication {
  name = "mount-zfs";
  runtimeInputs = [
    bash
    gum
    #cryptsetup
    gptfdisk
    btrfs-progs
    dosfstools
  ];
  text = builtins.readFile ./mount-zfs.sh;
}
