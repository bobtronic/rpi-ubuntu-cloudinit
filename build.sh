#! /bin/bash
IMAGE=ubuntu-20.04-preinstalled-server-arm64+raspi.img.xz
IMAGE_URL=http://cdimage.ubuntu.com/releases/20.04/release/$IMAGE


# create build directory if not exists
if [ -d build ]; then
    echo "* build directory found"
else 
    echo "* creating build directory"
    mkdir build
fi
cd build


# download image from ubuntu
if [ -f "$IMAGE" ]; then
    echo "* $IMAGE found"
else
    echo "* $IMAGE not found - downloading:"
    wget $IMAGE_URL
fi


# unpack
echo "* unpacking image"
if [ -f system-boot.img ]; then
    rm system-boot.img
fi
unxz --verbose --stdout $IMAGE > system-boot.img


# map the image to partitions, and mount the 'p1' (boot) partition
echo "* mounting image"
if [ -d system-boot ]; then
    rm -fR ./system-boot
fi
mkdir ./system-boot
PARTITION=$(kpartx -av system-boot.img | grep -P '.*loop\d+p1\s' | awk '{print $3}')
mount -o loop /dev/mapper/$PARTITION ./system-boot


# update the image files
echo "* applying cloud init"
# copy the cloud init config on
cp --force ../cloud-init/* ./system-boot/


# put a timestamp in
echo "Built via rpi3-ubuntu-cloudinit" > ./system-boot/rpi3-ubuntu-cloudinit
date >> ./system-boot/rpi3-ubuntu-cloudinit
echo && echo "######################################" 
cat ./system-boot/rpi3-ubuntu-cloudinit
echo "######################################" && echo


# cleanup time
echo "* unmounting image"
umount ./system-boot
kpartx -d system-boot.img
rmdir ./system-boot
echo && echo "Done!"
