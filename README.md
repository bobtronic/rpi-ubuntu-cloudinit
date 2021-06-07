# RPi cloud-init

## Overview

This will update an ubuntu raspberry pi disk image with basic user account and networking configuration to allow a headless initial setup.

Secure public key SSH connection over VPN (tailscale) will be possible after the approx 2 minute cloud init procedure.

---
## How to use it

This repository is designed to be used from within a vscode dev container.

You can beging by cloning into a container, or opening in a container.

Executing build.sh within the devcontainer will perform the following steps:
* download an offical ubuntu raspberry pi image archive
* extract the image from the archive
* mount the image
* substitute configuration you provide into cloud init config files
* copy cloud init config files into the image
* unmount the image ready for burning to sd card

build.sh takes the follow command line parameters to perform the cloud init substitutions:
*    --username
*    --password
*    --ssh-import-id
*    --host
*    --fqdn
*    --tailscale-tskey
*    --wifi-ssid
*    --wifi-pwd

---
## Devcontainer
You can beging by cloning into a container, or opening in a container.
Container volume will have higher performance, but folder bind container will make accessing the generated img file easier.
```
    Remote containers: Clone repository in container volume...
    Remote containers: Open folder in container...
```

The dockerfile sets up the container with a minimal linux environment to download, mount and edit the img file ready for burning to sd card.

This requires privledged access to docker which is applied by the devcontainer settings in the repository.
```json
.devcontainer/devcontainer.json 
    //allows kpartx and mount operations from within the container
    "runArgs": ["--privileged"],
```

---
## Cloud-init

Images are downloaded and cached directly from ubuntu. Browse for the one you want and set it in the build script. The URL's are similar to the following:

http://cdimage.ubuntu.com/releases/20.04/release/ubuntu-20.04-preinstalled-server-arm64+raspi.img.xz

These images are cloud-init capable, so all we need to do is provide a couple of files with configuration to setup our raspberry pi for basic operations right from the first boot.

### user-data
* hostname
* timezone
* inital user & ssh keys from github
* tailscale vpn
### network-config
* wifi networking
### usercfg.txt
* enable GPU and camera on the Pi (check raspberry pi docs for more)
---
## SSH
RSA key protected SSH is enabled and configured from the first boot via could init. Password authentication is disabled, and the authentication public keys are installed from your github account - easy!

Alternatively the public keys can be hardcoded into cloud-init if you dont use your github key for SSH. Look for `ssh_import_id` in the user-data configuration file.

---
## Tailscale
Tailscale is awesome, and if you dont use it already you probably should.

As well as point to point VPN mesh, it also provides smart DNS resolution, ACL's and much more.

Once the cloud-init process is complete, you will see the raspberry pi device in the device list on your tailscale console and your will be able to SSH directly in from a tailscale connected computer using its host name - i.e. *user@hostname*

---
## Credits and references

### Cloudinit
https://cloudinit.readthedocs.io/en/latest/
https://www.raspberrypi.org/forums/viewtopic.php?t=255465
https://www.digitalocean.com/community/tutorials/how-to-use-cloud-config-for-your-initial-server-setup

### Networking
https://linuxconfig.org/ubuntu-20-04-connect-to-wifi-from-command-line
https://tailscale.com/kb/1039/install-ubuntu-2004

### Updating a disk image
https://www.ullright.org/ullWiki/show/mount-disk-image-files-kpartx

### Burning to sd card
https://www.balena.io/etcher/
