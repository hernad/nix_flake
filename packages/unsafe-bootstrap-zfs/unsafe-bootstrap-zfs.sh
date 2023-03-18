set -e

BLUE=34
CYAN=36
RED=31

#PART=-part
#PART=p

lsblk -o name,mountpoint,size,uuid,vendor

if test -z "${TARGET_DEVICE-}"; then
	TARGET_DEVICE=$(gum input --prompt "What is the target device? (TARGET_DEVICE): " --placeholder "/dev/nvme?n?")
fi
echo "Got \`$(gum style --foreground ${BLUE} "TARGET_DEVICE")=$(gum style --foreground ${CYAN} "${TARGET_DEVICE}")\`"

if test -z "${EFI_PARTITION-}"; then
	EFI_PARTITION=$(gum input --prompt "What will be the created EFI partition? (EFI_PARTITION): " --placeholder "/dev/nvme?n?p1")
fi
echo "Got \`$(gum style --foreground ${BLUE} "EFI_PARTITION")=$(gum style --foreground ${CYAN} "${EFI_PARTITION}")\`"

if test -z "${BOOT_PARTITION-}"; then
	BOOT_PARTITION=$(gum input --prompt "What will be the created root partition? (BOOT_PARTITION): " --placeholder "/dev/nvme?n?p2")
fi
echo "Got \`$(gum style --foreground ${BLUE} "BOOT_PARTITION")=$(gum style --foreground ${CYAN} "${BOOT_PARTITION}")\`"

if test -z "${ROOT_PARTITION-}"; then
	ROOT_PARTITION=$(gum input --prompt "What will be the created root partition? (ROOT_PARTITION): " --placeholder "/dev/nvme?n?p3")
fi
echo "Got \`$(gum style --foreground ${BLUE} "ROOT_PARTITION")=$(gum style --foreground ${CYAN} "${ROOT_PARTITION}")\`"

if test -z "${SWAP_PARTITION-}"; then
	SWAP_PARTITION=$(gum input --prompt "What will be the created root partition? (SWAP_PARTITION): " --placeholder "/dev/nvme?n?p4")
fi
echo "Got \`$(gum style --foreground ${BLUE} "SWAP_PARTITION")=$(gum style --foreground ${CYAN} "${SWAP_PARTITION}")\`"

if test -z "${BIOS_PARTITION-}"; then
	BIOS_PARTITION=$(gum input --prompt "What will be the created root partition? (BIOS_PARTITION): " --placeholder "/dev/nvme?n?p5")
fi
echo "Got \`$(gum style --foreground ${BLUE} "BIOS_PARTITION")=$(gum style --foreground ${CYAN} "${BIOS_PARTITION}")\`"

if test -z "${SWAP_SIZE_G-}"; then
	SWAP_SIZE_G=$(gum input --prompt "Swap size? (SWAP_SIZE_G): " --placeholder "4")
fi
echo "Got \`$(gum style --foreground ${BLUE} "SWAP_SIZE_G")=$(gum style --foreground ${CYAN} "${SWAP_SIZE_G}")\`"

if test -z "${LAST_PARTITION-}"; then
	LAST_PARTITION=$(gum input --prompt "Last used (windows) partition? (LAST_PARTITION): " --placeholder "4")
fi
echo "Got \`$(gum style --foreground ${BLUE} "LAST_PARTITION")=$(gum style --foreground ${CYAN} "${LAST_PARTITION}")\`"


gum style "
This will create new partitions !!!

This script will not install NixOS, but you will be able to run \`nixos-install\` immediately after.

This process is highly experimental and will absolutely toss your machine into the rubbish bin."

gum confirm "Are you ready to have a really bad time?" || (echo "Okay! Then, toodles!" && exit 1)


#gum style --bold --foreground "${RED}" "Destroying existing partitions on \`TARGET_DEVICE=${TARGET_DEVICE}\` in 10..."
#sleep 10
#gum style --bold --foreground "${RED}" "Let's gooooo!!!"

umount -r /mnt || true

swapoff "/dev/mapper/${SWAP_PARTITION##*/}" || true
cryptsetup close "${SWAP_PARTITION##*/}" || true

gum style --bold --foreground "${RED}" "sgdisk partitioning ..."


p=$((LAST_PARTITION+1))

# efi part1
#EFI System partition (ef00)
sgdisk "-n${p}:0:+1G" -t1:EF00 "${TARGET_DEVICE}"

p=$((LAST_PARTITION+2))
# boot part2
# be00 Solaris boot  
sgdisk "-n${p}:0:+4G" "-t${p}:BE00" "${TARGET_DEVICE}"

p=$((LAST_PARTITION+4))
# part4 - swap partition
# 8200 Linux swap
sgdisk "-n${p}:0:+${SWAP_SIZE_G}G" "-t${p}:8200" "${TARGET_DEVICE}" || true

p=$((LAST_PARTITION+3))
# rpool part3 - zfs root/data partition
sgdisk "-n${p}:0:0" "-t${p}:BF00" "${TARGET_DEVICE}"

p=$((LAST_PARTITION+5))
# part5
#BIOS Boot Partition (type code ef02)
sgdisk -a1 "-n${p}:24K:+1000K" "-t${p}:EF02" "${TARGET_DEVICE}"

partprobe "${TARGET_DEVICE}" || true

gum style --bold --foreground "${RED}" "swap ..."

# swap
cryptsetup open --type plain --key-file /dev/random "${SWAP_PARTITION}" "${SWAP_PARTITION##*/}"
mkswap -f "/dev/mapper/${SWAP_PARTITION##*/}" || true
swapon "/dev/mapper/${SWAP_PARTITION##*/}" || true


gum style --bold --foreground "${RED}" "zpool bpool ..."

# zfs/solaris boot
zpool create -f \
        -o compatibility=grub2 \
        -o ashift=12 \
        -o autotrim=on \
        -O acltype=posixacl \
        -O canmount=off \
        -O compression=lz4 \
        -O devices=off \
        -O normalization=formD \
        -O relatime=on \
        -O xattr=sa \
        -O mountpoint=/boot \
        -R /mnt \
        bpool \
        "${BOOT_PARTITION}"


gum style --bold --foreground "${RED}" "zpool rpool ..."

# zfs root - data partition
zpool create -f \
        -o ashift=12 \
        -o autotrim=on \
        -R /mnt \
        -O acltype=posixacl \
        -O canmount=off \
        -O compression=zstd \
        -O dnodesize=auto \
        -O normalization=formD \
        -O relatime=on \
        -O xattr=sa \
        -O mountpoint=/ \
        rpool \
        "${ROOT_PARTITION}"


gum style --bold --foreground "${RED}" "zfs rpool/nixos ..."

zfs create \
      -o canmount=off \
      -o mountpoint=none \
      rpool/nixos


zfs create -o mountpoint=legacy rpool/nixos/root
mount -t zfs rpool/nixos/root /mnt/

zfs create -o mountpoint=legacy rpool/nixos/nix
mkdir -pv /mnt/nix
mount -t zfs rpool/nixos/nix /mnt/nix

zfs create -o mountpoint=legacy rpool/nixos/home
mkdir -pv /mnt/home
mount -t zfs rpool/nixos/home /mnt/home

zfs create -o mountpoint=legacy rpool/nixos/var
zfs create -o mountpoint=legacy rpool/nixos/var/log
mkdir -pv /mnt/var/log
mount -t zfs rpool/nixos/var/log /mnt/var/log

zfs create -o mountpoint=legacy rpool/nixos/empty
zfs snapshot rpool/nixos/empty@start


gum style --bold --foreground "${RED}" "zfs bpool/nixos ..."

zfs create -o mountpoint=none bpool/nixos
zfs create -o mountpoint=legacy bpool/nixos/root
mkdir -pv /mnt/boot
mount -t zfs bpool/nixos/root /mnt/boot

zfs create -o mountpoint=legacy bpool/nixos/persist
mkdir -pv /mnt/persist
mount -t zfs bpool/nixos/persist /mnt/persist

gum style --bold --foreground "${RED}" "mkfs efi ${EFI_PARTITION} ..."

# format and mount EFI partition
mkfs.vfat -n EFI "${EFI_PARTITION}"

#https://stackoverflow.com/questions/31307210/what-does-1-mean-in-bash
# TARGET_DEVICE=/dev/sdb, ${TARGET_DEVICE##*/} => sdb

mkdir -p "/mnt/boot/efis/${EFI_PARTITION##*/}"
mount -t vfat "${EFI_PARTITION}" "/mnt/boot/efis/${EFI_PARTITION##*/}"





# Workaround https://github.com/NixOS/nixpkgs/issues/73404
mkdir -p /mnt/mnt
mount --bind /mnt /mnt/mnt

mkdir -pv /mnt/persist/var/lib/NetworkManager/
touch /mnt/persist/var/lib/NetworkManager/secret_key
touch /mnt/persist/var/lib/NetworkManager/seen-bssids
touch /mnt/persist/var/lib/NetworkManager/timestamps
mkdir -pv /mnt/persist/etc/NetworkManager/system-connections
mkdir -pv /mnt/persist/var/lib/bluetooth
mkdir -pv /mnt/persist/etc/ssh
mkdir -pv /mnt/persist/encrypted-passwords
gum style --foreground "${CYAN}" "Done! Review the following block listing for the UUIDs to update the platform with."
lsblk -o name,mountpoint,uuid
