{ writeShellApplication, bash, gum, cryptsetup, gptfdisk, btrfs-progs, dosfstools, ... }:

writeShellApplication {
  name = "unsafe-bootstrap-zfs";
  runtimeInputs = [
    bash
    gum
    #cryptsetup
    gptfdisk
    #btrfs-progs
    dosfstools
  ];
  text = builtins.readFile ./unsafe-bootstrap-zfs.sh;
}
