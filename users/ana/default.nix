{ lib, pkgs, ... }:

{
  config = {
    home-manager.users.hernad = ./home.nix;
    users.users.hernad = {
      isNormalUser = true;
      home = "/home/hernad";
      createHome = true;
      passwordFile = "/persist/encrypted-passwords/hernad";
      shell = pkgs.fish;
      extraGroups = [ "wheel" "disk" "networkmanager" "libvirtd" "qemu-libvirtd" "kvm" "i2c" "plugdev" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDVkA7kB9DDbjmU93LaGz7h2uco4hCJx7xT7OJ9YkoXzcFqIiXhBITx9s3+OJSlWkeJ51nShgZXTLgDPaW8uU1TS7vwqVwGbe35rSPCyAxjYzY7ZMKi3u9PTb73cI6CfmWg9uU5ox3g3dUF5xNm5CsKulCd/eXASYgaiEH8AQ8R1nrr4M7A92ZzxepzhETjCVYdz8fT4f35Pfs/Sn70h9uxfZ7SCbQ3jhGuWpEhgfEBwqRpqeMRSXUQwE88ThKn++iXfENVzPJKP4TT+bX36oHlH7c1Wex5e3uHd/elDbq3Q+h3b7T3QUlH5AdKk6SkHnPn6NSdHoU+gWiMDdeCipPdpJZAkJlTmACq62JcmT3trIbNi3Q92Oh+lvonaN17d6sAmNx5om82R84qrzPusom4YIIfLRekbPFzPDvdR8ZDJPaXM8jDv+JwMhMxxxx= hernad@nomad"
      ];
    };
  };
}
