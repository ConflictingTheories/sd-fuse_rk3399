# sd-fuse_rk3399 for kernel-5.4.y
Create bootable SD card for NanoPC T4/NanoPi R4S/NanoPi M4/Som-RK3399/NanoPi NEO4  
  
***Note: Since RK3399 contains multiple different versions of kernel and uboot, please refer to the table below to switch this repo to the specified branch according to the OS***  
| OS                        | branch          |
| ------------------------- | --------------- |
| [*]friendlywrt            | kernel-5.4.y    |
| [ ]friendlycore focal     | kernel-4.19     |
| [ ]android10              | kernel-4.19     |
| [ ]friendlydesktop bionic | master          |
| [ ]friendlycore bionic    | master          |
| [ ]lubuntu xenial         | master          |
| [ ]eflasher               | master          |
| [ ]android8               | --unsupported-- |
| [ ]android7               | --unsupported-- |
  
## How to find the /dev name of my SD Card
Unplug all usb devices:
```
ls -1 /dev > ~/before.txt
```
plug it in, then
```
ls -1 /dev > ~/after.txt
diff ~/before.txt ~/after.txt
```

## Build friendlycore bootable SD card
```
git clone https://github.com/friendlyarm/sd-fuse_rk3399.git -b kernel-5.4.y
cd sd-fuse_rk3399
sudo ./fusing.sh /dev/sdX friendlywrt
```
Notes:  
fusing.sh will check the local directory for a directory with the same name as OS, if it does not exist fusing.sh will go to download it from network.  
So you can download from the netdisk in advance, on netdisk, the images files are stored in a directory called images-for-eflasher, for example:
```
cd sd-fuse_rk3399
tar xvzf /path/to/NETDISK/images-for-eflasher/friendlywrt-images.tgz
sudo ./fusing.sh /dev/sdX friendlywrt
```

## Build an sd card image
First, download and unpack:
```
git clone https://github.com/friendlyarm/sd-fuse_rk3399.git -b kernel-5.4.y
cd sd-fuse_rk3399
wget http://112.124.9.243/dvdfiles/RK3399/images-for-eflasher/friendlywrt-images.tgz
tar xvzf friendlywrt-images.tgz
```
Now,  Change something under the friendlywrt directory, 
for example, replace the file you compiled, then build friendlywrt bootable SD card: 
```
sudo ./fusing.sh /dev/sdX friendlywrt
```
or build an sd card image:
```
sudo ./mk-sd-image.sh friendlywrt
```
The following file will be generated:  
```
out/rk3399-sd-friendlywrt-5.4-arm64-yyyymmdd.img
```
You can use dd to burn this file into an sd card:
```
dd if=out/rk3399-sd-friendlywrt-5.4-arm64-yyyymmdd.img of=/dev/sdX bs=1M
```
## Build an sdcard-to-emmc image (eflasher rom)
Enable exFAT file system support on Ubuntu:
```
sudo apt-get install exfat-fuse exfat-utils
```
Generate the eflasher raw image, and put friendlycore image files into eflasher:
```
git clone https://github.com/friendlyarm/sd-fuse_rk3399.git -b kernel-5.4.y
cd sd-fuse_rk3399
wget http://112.124.9.243/dvdfiles/RK3399/images-for-eflasher/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz
wget http://112.124.9.243/dvdfiles/RK3399/images-for-eflasher/friendlywrt-images.tgz
tar xzf friendlywrt-images.tgz
sudo ./mk-emmc-image.sh friendlywrt
```
The following file will be generated:  
```
out/rk3399-eflasher-friendlywrt-5.4-yyyymmdd.img
```
You can use dd to burn this file into an sd card:
```
dd if=out/rk3399-eflasher-friendlywrt-5.4-yyyymmdd.img of=/dev/sdX bs=1M
```

## Replace the file you compiled

### Install cross compiler and tools

Install the package:
```
sudo apt install liblz4-tool
sudo apt install android-tools-fsutils
sudo apt install swig
sudo apt install python-dev python3-dev
```
Install Cross Compiler:
```
git clone https://github.com/friendlyarm/prebuilts.git -b master --depth 1 friendlyelec-toolchain
(cd friendlyelec-toolchain/gcc-x64 && cat toolchain-6.4-aarch64.tar.gz* | sudo tar xz -C /)

```

### Build U-boot and Kernel for FriendlyWrt
Download image files:
```
cd sd-fuse_rk3399
wget http://112.124.9.243/dvdfiles/RK3399/images-for-eflasher/friendlywrt-images.tgz
tar xzf friendlywrt-images.tgz
```
Build kernel for friendlywrt, the relevant image files in the images directory will be automatically updated, including the kernel modules in the file system:
```
cd sd-fuse_rk3399
git clone https://github.com/friendlyarm/kernel-rockchip --depth 1 -b nanopi-r2-v5.4.y out/kernel-rk3399
KERNEL_SRC=$PWD/kernel-rk3399 ./build-kernel.sh friendlywrt
```
Build uboot for friendlywrt, the relevant image files in the images directory will be automatically updated:
```
git clone https://github.com/friendlyarm/uboot-rockchip --depth 1 -b nanopi4-v2017.09
UBOOT_SRC=$PWD/uboot-rockchip ./build-uboot.sh friendlywrt
```
re-generate new firmware:
```
./mk-sd-image.sh friendlywrt
```

### Custom rootfs for friendlywrt
Use FriendlyCore as an example:
```
git clone https://github.com/friendlyarm/sd-fuse_rk3399.git -b kernel-5.4.y
cd sd-fuse_rk3399

wget http://112.124.9.243/dvdfiles/RK3399/rootfs/rootfs-friendlywrt.tgz
tar xzf rootfs-friendlywrt.tgz
```
Now,  change something under rootfs directory, like this:
```
echo hello > friendlywrt/rootfs/root/welcome.txt
```
Re-make rootfs.img:
```
./build-rootfs-img.sh friendlywrt/rootfs friendlywrt
```
Make sdboot image:
```
./mk-sd-image.sh friendlywrt
```
or make sd-to-emmc image (eflasher rom):
```
./mk-emmc-image.sh friendlywrt
```
