#! /bin/bash

#### ARMHF (hard float) - For modern Raspberry Pi boards (Pi 2, Pi 3 and Pi 4)
#IMAGE=ubuntu-20.04-preinstalled-server-armhf+raspi
#IMAGE=ubuntu-20.04-preinstalled-server-arm64+raspi

#### ARM64 (hard float) - For modern Raspberry Pi boards (Pi 2, Pi 3 and Pi 4)
#IMAGE=ubuntu-20.04.1-preinstalled-server-armhf+raspi
#IMAGE=ubuntu-20.04.2-preinstalled-server-arm64+raspi
#IMAGE_PATH=http://cdimage.ubuntu.com/releases/20.04/release

IMAGE=ubuntu-20.10-preinstalled-server-arm64+raspi
IMAGE_PATH=http://cdimage.ubuntu.com/releases/20.10/release

OUTPUT=rpi3-ubuntu.img


# create build directory if not exists
if [ -d build ]; then
    echo "* build directory found"
else 
    echo "* creating build directory"
    mkdir build
fi
cd build


if [ -f "$IMAGE.img" ]; then
    echo "* $IMAGE.img found"
else
    # download image from ubuntu
    if [ -f "$IMAGE.img.xz" ]; then
        echo "* $IMAGE.img.xz found"
    else
        if [ -f $IMAGE.img ]; then
            rm $IMAGE.img
        fi
        echo "* $IMAGE.img.xz not found - downloading:"
        curl "$IMAGE_PATH/$IMAGE.img.xz" -o $IMAGE.img.xz -#
#        zsync "$IMAGE_PATH/$IMAGE.img.xz.zsync" -i $IMAGE.img.xz.zsync -o $IMAGE.img.xz
    fi

    # unpack
    echo "* unpacking image"
    unxz --verbose --stdout $IMAGE.img.xz > $IMAGE.img
fi


# refresh working copy
echo "* cloning image to $OUTPUT"
cp $IMAGE.img $OUTPUT


# map the image to partitions, and mount the 'p1' (boot) partition
echo "* mounting image"
if [ -d /$OUTPUT.mount ]; then
    rm -fR /$OUTPUT.mount
fi
mkdir /$OUTPUT.mount
PARTITION=$(kpartx -av $OUTPUT | grep -P '.*loop\d+p1\s' | awk '{print $3}')
mount -o loop /dev/mapper/$PARTITION /$OUTPUT.mount


# update the image files
echo "* applying cloud init to image"
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
rm -fR /$OUTPUT.mount/*
rmdir /$OUTPUT.mount

echo && echo "Done!"
