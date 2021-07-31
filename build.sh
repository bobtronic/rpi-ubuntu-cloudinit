#! /bin/bash

#### ARMHF (hard float) - For Raspberry Pi Zero
#IMAGE=ubuntu-20.04-preinstalled-server-armhf+raspi
#IMAGE=ubuntu-20.04-preinstalled-server-arm64+raspi
#IMAGE=ubuntu-21.04-preinstalled-server-armhf+raspi

#### ARM64 (hard float) - For modern Raspberry Pi boards (Pi 2, Pi 3 and Pi 4)
#IMAGE=ubuntu-20.04.1-preinstalled-server-armhf+raspi
#IMAGE=ubuntu-20.04.2-preinstalled-server-arm64+raspi
#IMAGE=ubuntu-21.04-preinstalled-server-arm64+raspi

#### Snappy
#IMAGE=ubuntu-core-20-armhf+raspi
#IMAGE=ubuntu-core-20-arm64+raspi
#IMAGE_PATH=https://cdimage.ubuntu.com/ubuntu-core/20/stable/current/

#20.10
#IMAGE=ubuntu-20.10-preinstalled-server-arm64+raspi
#IMAGE_PATH=http://cdimage.ubuntu.com/releases/20.10/release

#21.04
IMAGE=ubuntu-21.04-preinstalled-server-arm64+raspi
IMAGE_PATH=http://cdimage.ubuntu.com/releases/21.04/release






while [ $# -gt 0 ]; do
  case "$1" in
    --outdir*)
      if [[ "$1" != *=* ]]; then shift; fi
      OUTDIR="${1#*=}"
      ;;

    --username*|-u)
      if [[ "$1" != *=* ]]; then shift; fi
      USERNAME="${1#*=}"
      ;;

    --password*|-p)
      if [[ "$1" != *=* ]]; then shift; fi
      PASSWORD="${1#*=}"
      ;;

    --ssh-import-id*|-ssh-id*)
      if [[ "$1" != *=* ]]; then shift; fi
      SSH_IMPORT_ID="${1#*=}"
      ;;

    --host*|-h)
      if [[ "$1" != *=* ]]; then shift; fi
      HOST="${1#*=}"
      ;;

    --fqdn*)
      if [[ "$1" != *=* ]]; then shift; fi
      FQDN="${1#*=}"
      ;;

    --tailscale-tskey*)
      if [[ "$1" != *=* ]]; then shift; fi
      TAILSCALE_TSKEY="${1#*=}"
      ;;

    --wifi-ssid*|-wssid*)
      if [[ "$1" != *=* ]]; then shift; fi
      WIFI_SSID="${1#*=}"
      ;;

    --wifi-pwd*|-wpwd*)
      if [[ "$1" != *=* ]]; then shift; fi
      WIFI_PWD="${1#*=}"
      ;;

    --help|-h)
      printf "Meaningful help message" # Flag argument
      exit 0
      ;;

    *)
      >&2 printf "Error: Invalid argument %s\n" $1
      exit 1
      ;;
  esac
  shift
done


TIMEZONE="Pacific/Auckland"
OUTDIR="build"
OUTPUT=rpi-ubuntu-cloudinit.img




# create build directory if not exists
if [ -d $OUTDIR ]; then
    echo "* build directory found"
else 
    echo "* creating build directory"
    mkdir $OUTDIR
fi
cd $OUTDIR


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
mkdir $OUTPUT.mount
PARTITION=$(kpartx -av "$OUTPUT" | grep -P '.*loop\d{1,2}+p1\s' | awk '{print $3}')
echo "* Partition: " $PARTITION
mount -o loop /dev/mapper/$PARTITION $OUTPUT.mount

# update the image files
echo "* applying cloud init to image"
# copy the cloud init config on
cp --force ../cloud-init/* $OUTPUT.mount/
# update the macros
sed -i \
    -e "s|\${WIFI_SSID}|$WIFI_SSID|" \
    -e "s|\${WIFI_PWD}|$WIFI_PWD|" \
    $OUTPUT.mount/network-config
# update the macros
sed -i \
    -e "s|\${USERNAME}|$USERNAME|" \
    -e "s|\${PASSWORD}|$PASSWORD|" \
    -e "s|\${SSH_IMPORT_ID}|$SSH_IMPORT_ID|" \
    -e "s|\${HOST}|$HOST|" \
    -e "s|\${FQDN}|$FQDN|" \
    -e "s|\${TIMEZONE}|$TIMEZONE|" \
    -e "s|\${TAILSCALE_TSKEY}|$TAILSCALE_TSKEY|" \
    $OUTPUT.mount/user-data

# put a timestamp in
echo "Built via rpi-ubuntu-cloudinit" > $OUTPUT.mount/rpi-ubuntu-cloudinit
date >> $OUTPUT.mount/rpi-ubuntu-cloudinit
echo && echo "######################################" 
cat $OUTPUT.mount/rpi-ubuntu-cloudinit
echo "######################################" && echo

# cleanup time
echo "* unmounting image"
umount $OUTPUT.mount
kpartx -d $OUTPUT
dmsetup remove_all
rm -fR $OUTPUT.mount/*
rmdir $OUTPUT.mount

echo && echo $OUTDIR/$OUTPUT Done!
