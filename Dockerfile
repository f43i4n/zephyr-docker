FROM ubuntu:18.04

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install --no-install-recommends git cmake ninja-build gperf \
    ccache dfu-util device-tree-compiler wget \
    python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
    make gcc gcc-multilib g++-multilib libsdl2-dev -y

RUN apt-get install -y gnupg software-properties-common

# install version of cmake higher than 3.13.1
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add - \
    && apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' \
    && apt-get update && apt-get install -y cmake

RUN pip3 install --user -U west

ENV PATH="/root/.local/bin:${PATH}"

RUN west init /zephyrproject

WORKDIR /zephyrproject

RUN west update

RUN west zephyr-export

RUN pip3 install --user -r ./zephyr/scripts/requirements.txt

WORKDIR /root

RUN wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.11.3/zephyr-sdk-0.11.3-setup.run

RUN chmod +x zephyr-sdk-0.11.3-setup.run

RUN ./zephyr-sdk-0.11.3-setup.run -- -d ~/zephyr-sdk-0.11.3

WORKDIR /zephyrproject

RUN pip3 install --user -r ./bootloader/mcuboot/scripts/requirements.txt

# set locale
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# install imgtool for signing images
RUN pip3 install --user imgtool
