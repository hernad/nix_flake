/*
  Make a mount tree for adding to `fileSystems`

*/
{ efiDev, rootDev }:

{
  "/" = {
    device = rootDev;
    fsType = "btrfs";
    options = [
      "subvol=root"
      "compress=zstd"
      "lazytime"
    ];
  };
  "/home" = {
    device = rootDev;
    fsType = "btrfs";
    options = [
      "subvol=home"
      "compress=zstd"
      "lazytime"
    ];
  };
  "/nix" = {
    device = rootDev;
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "compress=zstd"
      "lazytime"
    ];
  };
  "/persist" = {
    device = rootDev;
    fsType = "btrfs";
    neededForBoot = true;
    options = [
      "subvol=persist"
      "compress=zstd"
      "lazytime"
    ];
  };
  "/boot" = {
    device = rootDev;
    fsType = "btrfs";
    neededForBoot = true;
    options = [
      "subvol=boot"
      "compress=zstd"
      "lazytime"
    ];
  };
  "/var/log" = {
    device = rootDev;
    fsType = "btrfs";
    neededForBoot = true;
    options = [
      "subvol=log"
      "compress=zstd"
      "lazytime"
    ];
  };
  "/efi" = {
    device = efiDev;
    fsType = "vfat";
  };
}