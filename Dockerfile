FROM debian:bullseye-slim
RUN apt-get update && apt-get -y -qq install curl xz-utils kpartx
COPY . /rpi3-build
CMD /rpi3-build/build.sh
