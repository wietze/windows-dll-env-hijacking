FROM ubuntu:22.04

WORKDIR /mnt

SHELL [ "/bin/bash", "-c" ]

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade --no-install-recommends -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        binutils-mingw-w64-x86-64 \
        bison \
        build-essential \
        bzip2 \
        ca-certificates \
        expat \
        file \
        flex \
        g++-10 \
        gcc-10 \
        gcc-mingw-w64-x86-64 \
        git \
        gnupg \
        gperf \
        libexpat-dev \
        libgmp-dev \
        libssl-dev \
        make \
        meson \
        ninja-build \
        patch \
        texinfo \
        wget \
        xz-utils \
        yasm \
        zip \
        zlib1g-dev \
    # && git clone --depth 1 git://sourceware.org/git/binutils-gdb.git \
    # && cd binutils-gdb \
    # && ./configure --target x86_64-w64-mingw32 \
    # && make \
    # && make install \
    # && cd .. \
    # && rm -r binutils-gdb \
    # \
    && apt-get remove --purge -y gnupg \
    && apt-get autoremove --purge -y \
    && apt-get clean
