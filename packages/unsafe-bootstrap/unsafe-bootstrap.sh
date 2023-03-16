set -e

BLUE=34
CYAN=36
RED=31

#PART=-part
PART=p

lsblk -o name,mountpoint,size,uuid,vendor

if test -z "${TARGET_DEVICE-}"; then
	TARGET_DEVICE=$(gum input --prompt "What is the target device? (TARGET_DEVICE): " --placeholder "/dev/nvme?n?")
fi
echo "Got \`$(gum style --foreground ${BLUE} "TARGET_DEVICE")=$(gum style --foreground ${CYAN} "${TARGET_DEVICE}")\`"

if test -z "${INST_PARTSIZE_SWAP-}"; then
	INST_PARTSIZE_SWAP=$(gum input --prompt "Swap size? (INST_PARTSIZE_SWAP): " --placeholder "4")
fi
echo "Got \`$(gum style --foreground ${BLUE} "INST_PARTSIZE_SWAP")=$(gum style --foreground ${CYAN} "${INST_PARTSIZE_SWAP}")\`"


if test -z "${INST_PARTSIZE_RPOOL-}"; then
	INST_PARTSIZE_RPOOL=$(gum input --prompt "What will be size of main partition empty for ALL space? (INST_PARTSIZE_RPOOL): " --placeholder "")
fi
echo "Got \`$(gum style --foreground ${BLUE} "INST_PARTSIZE_RPOOL")=$(gum style --foreground ${CYAN} "${INST_PARTSIZE_RPOOL}")\`"


gum style "
This will irrevocably destroy all data on \`TARGET_DEVICE=${TARGET_DEVICE-/dev/null}\`!!!

An FAT32 EFI system partition will be created as the first partition.

An ZFS partition will be created as the second partition.
Expected as: \`ROOT_PARITION=${ROOT_PARTITION-/dev/null}\`

Several zpools will be created, then mounted on \`/mnt\`.

Several files will be created in the \`persist\` subvolume.

This script will not install NixOS, but you will be able to run \`nixos-install\` immediately after.

This process is highly experimental and will absolutely toss your machine into the rubbish bin."

gum confirm "Are you ready to have a really bad time?" || (echo "Okay! Then, toodles!" && exit 1)


gum style --bold --foreground "${RED}" "Destroying existing partitions on \`TARGET_DEVICE=${TARGET_DEVICE}\` in 10..."
sleep 10
gum style --bold --foreground "${RED}" "Let's gooooo!!!"

umount -r /mnt || true
umount -r "${TARGET_DEVICE}" || true


sgdisk --zap-all ${TARGET_DEVICE}
# efi part1
#EFI System partition (ef00)
sgdisk -n1:1M:+1G -t1:EF00 ${TARGET_DEVICE}
# boot part2
# be00 Solaris boot  
sgdisk -n2:0:+4G -t2:BE00 ${TARGET_DEVICE}

# part4 - swap partition
# 8200 Linux swap
sgdisk -n4:0:+${INST_PARTSIZE_SWAP}G -t4:8200 ${TARGET_DEVICE}

# rpool part3 - zfs root/data partition
if test -z ${INST_PARTSIZE_RPOOL}; then
    sgdisk -n3:0:0 -t3:BF00 ${TARGET_DEVICE}
else
    sgdisk -n3:0:+${INST_PARTSIZE_RPOOL}G -t3:BF00 ${TARGET_DEVICE}
fi

# part5
#BIOS Boot Partition (type code ef02)
sgdisk -a1 -n5:24K:+1000K -t5:EF02 ${TARGET_DEVICE}

sync && udevadm settle && sleep 3

# swap
cryptsetup open --type plain --key-file /dev/random ${TARGET_DEVICE}${PART}4 ${i##*/}${PART}4
mkswap /dev/mapper/${i##*/}${PART}4
swapon /dev/mapper/${i##*/}${PART}4

# zfs/solaris boot
zpool create \
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
    $(printf "${TARGET_DEVICE}${PART}2")


# zfs data partition
zpool create \
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
	$(printf "${TARGET_DEVICE}${PART}3")

echo zfs rpool/nixos

zfs create \
   -o canmount=off \
   -o mountpoint=none \
   rpool/nixos


# echo zfs ostali

zfs create -o mountpoint=legacy rpool/nixos/root
mount -t zfs rpool/nixos/root /mnt/

zfs create -o mountpoint=legacy rpool/nixos/home
mkdir /mnt/home
mount -t zfs rpool/nixos/home /mnt/home

zfs create -o mountpoint=legacy rpool/nixos/var
zfs create -o mountpoint=legacy rpool/nixos/var/lib
zfs create -o mountpoint=none bpool/nixos

zfs create -o mountpoint=legacy rpool/nixos/empty
zfs snapshot rpool/nixos/empty@start



#mount -o compress=zstd,lazytime /dev/mapper/encrypt /mnt/ -v

#mkdir -p /mnt/snapshots/root/
#btrfs subvolume snapshot -r /mnt/root /mnt/snapshots/root/blank

#mkdir -pv /mnt/nix
#mount -o subvol=nix,compress=zstd,lazytime /dev/mapper/encrypt /mnt/nix


#mkdir -pv /mnt/persist
#mount -o subvol=persist,compress=zstd,lazytime /dev/mapper/encrypt /mnt/persist

zfs create -o mountpoint=legacy rpool/nixos/persist
mkdir -pv /mnt/persist
mount -t zfs rpool/nixos/persist /mnt/persist


#mount -o subvol=log,compress=zstd,lazytime /dev/mapper/encrypt /mnt/var/log
zfs create -o mountpoint=legacy rpool/nixos/var/log
mkdir -pv /mnt/var/log
mount -t zfs rpool/nixos/var/log /mnt/var/log

#mkdir -pv /mnt/boot
#mount -o subvol=boot,compress=zstd,lazytime /dev/mapper/encrypt /mnt/boot
zfs create -o mountpoint=legacy bpool/nixos/root
mkdir -pv /mnt/boot
mount -t zfs bpool/nixos/root /mnt/boot

# format and mount EFI partition
mkfs.vfat -n EFI ${TARGET_DEVICE}${PART}1

#https://stackoverflow.com/questions/31307210/what-does-1-mean-in-bash
# TARGET_DEVICE=/dev/sdb, ${TARGET_DEVICE##*/} => sdb

mkdir -p /mnt/boot/efis/${TARGET_DEVICE##*/}${PART}1
mount -t vfat ${TARGET_DEVICE}${PART}1 /mnt/boot/efis/${TARGET_DEVICE##*/}${PART}1

#mkfs.vfat -F 32 "${EFI_PARTITION}"
#mkdir -p /mnt/efi
#mount "${EFI_PARTITION}" /mnt/efi

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
