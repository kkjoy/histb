#!/bin/bash

apt update && apt install android-sdk-ext4-utils -y
./0-clean.sh
./1-init-img.sh -mv100
./2-chroot.sh
./3-init-packages.sh
./4-mkimg.sh
echo "已完成"
