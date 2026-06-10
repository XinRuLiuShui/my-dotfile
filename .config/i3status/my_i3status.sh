#!/bin/sh
# 保存为 ~/my_i3status.sh

i3status | while :
do
        read line
        echo "$(~/Projets/xiao_liu_ren/main) | $line" || exit 1
done
