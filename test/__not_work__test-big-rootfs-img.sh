#!/bin/bash
set -eux

HTTP_SERVER=112.124.9.243

# hack for me
PCNAME=`hostname`
if [ x"${PCNAME}" = x"tzs-i7pc" ]; then
       HTTP_SERVER=192.168.1.9
fi

# clean
mkdir -p tmp
sudo rm -rf tmp/*

cd tmp
git clone ../../.git sd-fuse_rk3399 -b kernel-5.4.y
cd sd-fuse_rk3399
wget http://${HTTP_SERVER}/dvdfiles/rk3399/images-for-eflasher/friendlywrt-images.tgz
tar xzf friendlywrt-images.tgz
wget http://${HTTP_SERVER}/dvdfiles/rk3399/images-for-eflasher/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz

# make big file
fallocate -l 1G friendlywrt/rootfs.img

# calc image size
IMG_SIZE=`du -s -B 1 friendlywrt/rootfs.img | cut -f1`

# re-gen parameter.txt
./tools/generate-partmap-txt.sh ${IMG_SIZE} friendlywrt

sudo ./mk-sd-image.sh friendlywrt
sudo ./mk-emmc-image.sh friendlywrt
