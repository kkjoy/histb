#!/bin/bash

mkbootargs -s 64 -r /etc/bootargs_input.txt -o /tmp/bootargs.bin >/dev/null 2>&1
dd if=/tmp/bootargs.bin of=/dev/mmcblk0p2 bs=1024 count=1024
echo "已经成功更改你的盒子MAC地址，重启即可生效"
echo "如有疑问，请访问 https://bbs.histb.com 获得相关教程"

