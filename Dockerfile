FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    xorriso \
    qemu-system-x86 \
    libgmp3-dev \
    libmpc-dev \
    libmpfr-dev \
    grub-pc-bin \
    m4

ENV HOME="/root"
ENV PREFIX="${HOME}/opt/cross"
ENV TARGET="i686-elf"
ENV PATH="${PREFIX}/bin:${PATH}"

RUN mkdir -p $HOME/src && cd $HOME/src && \
    wget https://ftp.gnu.org/gnu/binutils/binutils-2.44.tar.xz && \
    tar -xf binutils-2.44.tar.xz && \
    mkdir build-binutils && cd build-binutils && \
    ../binutils-2.44/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror && \
    make && make install

RUN cd $HOME/src && \
    wget https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz && \
    tar -xf gcc-14.2.0.tar.xz && \
    mkdir build-gcc && cd build-gcc && \
    ../gcc-14.2.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers --disable-hosted-libstdcxx && \
    make all-gcc && \
    make all-target-libgcc && \
    make all-target-libstdc++-v3 && \
    make install-gcc && \
    make install-target-libgcc && \
    make install-target-libstdc++-v3

COPY src/ $HOME/src/
COPY grub.cfg $HOME/
COPY Makefile $HOME/

RUN cd $HOME && make all

CMD ["/bin/bash"]

# docker cp [container]:/root/kernel/myos.iso /home/[user]/kernel/
# docker cp [container]:/root/kernel/myos.bin /home/[user]/kernel/