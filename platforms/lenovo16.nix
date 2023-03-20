{ config, pkgs, lib, modulesPath, ... }:

let
  diskPart = (import ./../disk_layout/lenovo16_zfs.nix).diskPart;
  diskName = diskPart.diskName;
  swap = "/dev/${diskPart.swap}"; 
  efi = "${diskPart.efi}";
  makeMounts = import ./../functions/make_mounts_zfs.nix;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    # "${modulesPath}/profiles/qemu-guest.nix"
  ];

  
  config = {
    boot.kernelParams = [ "amd_iommu=on" "iommu=pt" "iommu=1" "rd.driver.pre=vfio-pci" ];
    boot.initrd.kernelModules = [];
    boot.kernelModules = [ 
      "tap" 
      "kvm-amd" 
      "kvm-intel" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" 
    ];

    services.xserver.videoDrivers = [ "amdgpu" ];

    hardware.cpu.amd.updateMicrocode = true;
    systemd.services.zfs-mount.enable = false;

    fileSystems = makeMounts {
      inherit efi;
    };

    swapDevices = [
      {
        device = "/dev/${swap}";
        discardPolicy = "both";
        randomEncryption = {
          enable = true;
          allowDiscards = true;
        };
      }
    ];

    boot.loader.grub.devices = [
      "/dev/${diskName}" 
    ];

    # $ head -c4 /dev/urandom | od -A none -t x4
    # da9793e5

    networking.hostId = "da9793e5";

    # This doesn't seem to work...
    /* environment.etc."crypttab" = {
      enable = true;
      text = ''
      encrypt /dev/nvme1n1p2 - fido2-device=auto
      '';
    }; */
  
    virtualisation.docker.enable = true;

    nix.distributedBuilds = true;
    nix.settings.builders = [ "@/etc/nix/machines" ];

    networking.hostName = "lenovo16";
    networking.domain = "bringout.home";
  };
}

