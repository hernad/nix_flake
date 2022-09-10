{ config, pkgs, lib, modulesPath, ... }:

let
  encryptedDeviceLabel = "encrypt";
  efiDeviceLabel = "efi";
  makeMounts = import ./../functions/make_mounts.nix;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = {
    boot.kernel.sysctl = {
      "dev.i915.perf_stream_paranoid" = 0;
    };
    boot.loader.efi.efiSysMountPoint = "/boot/efi";
    boot.initrd.luks.devices = {
      encrypt = {
        device = "/dev/disk/by-uuid/${encryptedDeviceLabel}";
        keyFile = "/keyfile.bin";
        allowDiscards = true;
      };
    };
    boot.initrd.secrets = {
      "keyfile.bin" = "/etc/secrets/initrd/keyfile.bin";
    };

    fileSystems = makeMounts {
      inherit encryptedDeviceLabel efiDeviceLabel;
    };

    networking.hostName = "nomad";
    networking.domain = "hoverbear.home";
  };
}

