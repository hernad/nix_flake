/*
  Make a mount tree for adding to `fileSystems`

*/
{ efi }:

{

    "/" =
    { device = "rpool/nixos/root";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

    "/home" =
    { device = "rpool/nixos/home";
      fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];
    };

    "/var/lib" =
    { device = "rpool/nixos/var/lib";
      fsType = "zfs"; 
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

    "/var/log" =
    { device = "rpool/nixos/var/log";
      fsType = "zfs"; 
      options = [ "zfsutil" "X-mount.mkdir" ];
    };

    "/boot" =
    { 
      device = "bpool/nixos/root";
      fsType = "zfs"; 
      options = [ "zfsutil" "X-mount.mkdir" ];
      neededForBoot = true;
    };

    "/persist" = {
       device = "rpool/nixos/persist";
       fsType = "zfs";
       options = [ "zfsutil" "X-mount.mkdir" ];
    };

    "/boot/efis/${efi}" = {
      device = "/dev/${efi}";
      fsType = "vfat";
      options = [
        "x-systemd.idle-timeout=1min"
        "x-systemd.automount"
        "noauto"
        "nofail"
      ];
    };

    "/boot/efi" =
    { 
      device = "/boot/efis/${efi}";
      fsType = "none";
      options = [ "bind" ];
    };


}

