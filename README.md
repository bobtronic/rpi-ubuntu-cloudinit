#RPi 3 cloud-init

very important - need to modify:
    .devcontainer/devcontainer.json 
with:
    //allows kpartx and mount operations from within the container
    "runArgs": ["--privileged"],


https://cloudinit.readthedocs.io/en/latest/topics/examples.html


docker build                            \
    -t rpi3-build .                     \
&&                                      \
docker run                              \
    --privileged --rm                   \
    --mount                             \
        type=bind,                      \
        source="$(pwd)"/build,          \
        destination=/rpi3-build/build   \
    --name rpi3-build                   \
    rpi3-build

--one liner
docker build -t rpi3-build .  && docker run --privileged --rm --mount type=bind,source="$(pwd)"/build,destination=/rpi3-build/build --name rpi3-build rpi3-build

http://cdimage.ubuntu.com/releases/20.04/release/ubuntu-20.04-preinstalled-server-arm64+raspi.img.xz


https://cloudinit.readthedocs.io/en/latest/
https://www.raspberrypi.org/forums/viewtopic.php?t=255465

hostname

inital user

networking
https://linuxconfig.org/ubuntu-20-04-connect-to-wifi-from-command-line

ssh setup




tailscale
https://tailscale.com/kb/1039/install-ubuntu-2004


burn it
https://www.balena.io/etcher/
https://www.ullright.org/ullWiki/show/mount-disk-image-files-kpartx
