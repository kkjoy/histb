#!/bin/bash

./0-clean.sh
./1-init-img.sh -mv300 -64
./2-chroot.sh
./3-init-packages.sh
./4-mkimg.sh
echo "已完成"
