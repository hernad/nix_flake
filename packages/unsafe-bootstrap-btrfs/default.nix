{ writeShellApplication, bash, gum, cryptsetup, gptfdisk, btrfs-progs, dosfstools, ... }:

# https://nixos.org/manual/nixpkgs/stable/#trivial-builder-writeShellApplication

writeShellApplication {
  name = "unsafe-bootstrap-btrfs";
  runtimeInputs = [
    bash
    gum
    #cryptsetup
    gptfdisk
    btrfs-progs
    dosfstools
  ];
  text = builtins.readFile ./unsafe-bootstrap-btrfs.sh;
}
