set -e

BLUE=34
CYAN=36

lsblk -o name,mountpoint,size,uuid,vendor

if test -z "${EFI_PARTITION-}"; then
	EFI_PARTITION=$(gum input --prompt "What will be the created EFI partition? (EFI_PARTITION): " --placeholder "/dev/nvme?n?p1")
fi
echo "Got \`$(gum style --foreground ${BLUE} "EFI_PARTITION")=$(gum style --foreground ${CYAN} "${EFI_PARTITION}")\`"

umount -r /mnt || true

zpool import -f rpool
zpool import -f bpool

mount -t zfs rpool/nixos/root /mnt/

mkdir -pv /mnt/home
mount -t zfs rpool/nixos/home /mnt/home

mkdir -pv /mnt/nix
mount -t zfs rpool/nixos/nix /mnt/nix

mkdir -pv /mnt/var/log
mount -t zfs rpool/nixos/var/log /mnt/var/log



mkdir -pv /mnt/boot
mount -t zfs bpool/nixos/root /mnt/boot

mkdir -pv /mnt/persist
mount -t zfs bpool/nixos/persist /mnt/persist


mkdir -p "/mnt/boot/efis/${EFI_PARTITION##*/}"
mount -t vfat "${EFI_PARTITION}" "/mnt/boot/efis/${EFI_PARTITION##*/}"

