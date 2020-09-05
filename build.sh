#! /bin/bash

#### ARMHF (hard float) - For modern Raspberry Pi boards (Pi 2, Pi 3 and Pi 4)
#IMAGE=ubuntu-20.04-preinstalled-server-armhf+raspi.img.xz
#IMAGE=ubuntu-20.04-preinstalled-server-arm64+raspi.img.xz

#### ARM64 (hard float) - For modern Raspberry Pi boards (Pi 2, Pi 3 and Pi 4)
#IMAGE=ubuntu-20.04.1-preinstalled-server-armhf+raspi.img.xz
IMAGE=ubuntu-20.04.1-preinstalled-server-arm64+raspi.img.xz

IMAGE_URL=http://cdimage.ubuntu.com/releases/20.04/release/$IMAGE
OUTPUT=rpi3-ubuntu.img


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
    curl $IMAGE_URL -o $IMAGE -#
fi


# unpack
echo "* unpacking image"
if [ -f $OUTPUT ]; then
    rm $OUTPUT
fi
unxz --verbose --stdout $IMAGE > $OUTPUT


# map the image to partitions, and mount the 'p1' (boot) partition
echo "* mounting image"
if [ -d /$OUTPUT.mount ]; then
    rm -fR /$OUTPUT.mount
fi
mkdir /$OUTPUT.mount
PARTITION=$(kpartx -av $OUTPUT | grep -P '.*loop\d+p1\s' | awk '{print $3}')
mount -o loop /dev/mapper/$PARTITION /$OUTPUT.mount


# update the image files
echo "* applying cloud init"
# copy the cloud init config on
cp --force ../cloud-init/* /$OUTPUT.mount/


# put a timestamp in
echo "Built via rpi3-ubuntu-cloudinit" > /$OUTPUT.mount/rpi3-ubuntu-cloudinit
date >> /$OUTPUT.mount/rpi3-ubuntu-cloudinit
echo && echo "######################################" 
cat /$OUTPUT.mount/rpi3-ubuntu-cloudinit
echo "######################################" && echo


# cleanup time
echo "* unmounting image"
umount /$OUTPUT.mount
kpartx -d $OUTPUT
rmdir /$OUTPUT.mount

echo && echo "Done!"
