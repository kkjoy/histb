#!/bin/bash

timestamp=$(date +%Y%m%d)
model=$(awk 'NR==1' target 2> /dev/null)
ARCH=$(awk 'NR==2' target_arch 2> /dev/null)
if [ "$ARCH" = "arm64" ]; then
    arch_suffix="-64"
else
    arch_suffix="-32"
fi
file_prefix="Ubuntu-$(awk 'NR==1' target_arch 2> /dev/null)-${ARCH}-hi3798${model}"
img_file="${file_prefix}-${timestamp}-MD5.img"
TMPFS="tmp"

echo "Firmware Model: $img_file"
echo "Firmware will output into: $(pwd), Please wait ..."

dd if=/dev/zero of=$img_file count=1000 obs=1 seek=900M
mkfs.ext4 $img_file
umount $TMPFS 2> /dev/null ; rm -r "$TMPFS" 2> /dev/null ; mkdir -p $TMPFS ; sleep 1
mount $img_file $TMPFS
cp -a rootfs/* $TMPFS
sync
umount $TMPFS 2> /dev/null ; rm -r "$TMPFS" 2> /dev/null
e2fsck -p -f $img_file
resize2fs -M $img_file

echo "Calculating MD5 for Firmware ..."
old_img_file=$img_file
img_file="${img_file/MD5/$(md5sum ${img_file} 2> /dev/null| cut -c1-5)}"
mv -f "${old_img_file}" "${img_file}"

echo "Packing Firmware with command gzip ..."
gzip -c -1 "$img_file" > "${old_img_file}.gz"

echo "Calculating MD5 for Packed Firmware ..."
gz_file="${old_img_file/MD5/$(md5sum ${old_img_file}.gz 2> /dev/null | cut -c1-5)}.gz"
mv -f "${old_img_file}.gz" "$gz_file"

echo
echo "Packed Firmware: $gz_file"
echo "Packed Firmware Size: $(du -h $gz_file 2> /dev/null | awk '{print $1}')"

echo
echo "Packing ext4 for backup partition"
mkdir backup
backup_ext4="${file_prefix}-${timestamp}-backup-MD5.ext4"
cp $gz_file backup/backup-${model}${arch_suffix}.gz
sync
make_ext4fs -l 512M -s $backup_ext4 backup/

echo "Calculating MD5 for backup Firmware ..."
old_backup_ext4=$backup_ext4
backup_ext4="${backup_ext4/MD5/$(md5sum ${backup_ext4} 2> /dev/null| cut -c1-5)}"
mv -f "${old_backup_ext4}" "${backup_ext4}"
rm -r backup 2> /dev/null
