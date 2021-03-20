FROM debian:bullseye-slim
RUN apt-get -q update && apt-get -y -qq -o Dpkg::Use-Pty=0 install curl xz-utils kpartx zsync git
#COPY . /rpi3-build
#CMD /rpi3-build/build.sh
