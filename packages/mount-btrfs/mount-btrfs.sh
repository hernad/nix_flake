set -e

BLUE=34
CYAN=36


lsblk -o name,mountpoint,size,uuid,vendor

if test -z "${TARGET_DEVICE-}"; then
	TARGET_DEVICE=$(gum input --prompt "What is the target device? (TARGET_DEVICE): " --placeholder "/dev/nvme?n?")
fi
echo "Got \`$(gum style --foreground ${BLUE} "TARGET_DEVICE")=$(gum style --foreground ${CYAN} "${TARGET_DEVICE}")\`"

if test -z "${EFI_PARTITION-}"; then
	EFI_PARTITION=$(gum input --prompt "What will be the created EFI partition? (EFI_PARTITION): " --placeholder "/dev/nvme?n?p1")
fi
echo "Got \`$(gum style --foreground ${BLUE} "EFI_PARTITION")=$(gum style --foreground ${CYAN} "${EFI_PARTITION}")\`"

if test -z "${ROOT_PARTITION-}"; then
	ROOT_PARTITION=$(gum input --prompt "What will be the created root partition? (ROOT_PARTITION): " --placeholder "/dev/nvme?n?p2")
fi
echo "Got \`$(gum style --foreground ${BLUE} "ROOT_PARTITION")=$(gum style --foreground ${CYAN} "${ROOT_PARTITION}")\`"



umount -r /mnt || true
umount -r "${TARGET_DEVICE}" || true

mount -o subvol=root,compress=zstd,lazytime "${ROOT_PARTITION}" /mnt
mkdir -pv /mnt/home
mount -o subvol=home,compress=zstd,lazytime "${ROOT_PARTITION}" /mnt/home
mkdir -pv /mnt/nix
mount -o subvol=nix,compress=zstd,lazytime "${ROOT_PARTITION}" /mnt/nix
mkdir -pv /mnt/persist
mount -o subvol=persist,compress=zstd,lazytime "${ROOT_PARTITION}" /mnt/persist
mkdir -pv /mnt/var/log
mount -o subvol=log,compress=zstd,lazytime "${ROOT_PARTITION}" /mnt/var/log
mkdir -pv /mnt/boot
mount -o subvol=boot,compress=zstd,lazytime "${ROOT_PARTITION}" /mnt/boot

mkdir -p /mnt/efi
mount "${EFI_PARTITION}" /mnt/efi

# Workaround https://github.com/NixOS/nixpkgs/issues/73404
mkdir -p /mnt/mnt
mount --bind /mnt /mnt/mnt

gum style --foreground "${CYAN}" "Done! Review the following block listing for the UUIDs to update the platform with."
lsblk -o name,mountpoint,uuid