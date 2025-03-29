FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    xorriso \
    grub-pc-bin \
    grub-common \
    qemu-system-x86 \
    m4 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash builder
USER builder
WORKDIR /home/builder

ENV PREFIX="/home/builder/opt/cross"
ENV TARGET="i686-elf"
ENV PATH="${PREFIX}/bin:${PATH}"

RUN mkdir -p /home/builder/src && cd /home/builder/src && \
    wget https://ftp.gnu.org/gnu/binutils/binutils-2.44.tar.xz && \
    tar -xf binutils-2.44.tar.xz && \
    mkdir build-binutils && cd build-binutils && \
    ../binutils-2.44/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror && \
    make && make install

RUN cd /home/builder/src && \
    wget https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz && \
    tar -xf gmp-6.3.0.tar.xz && \
    cd gmp-6.3.0 && \
    ./configure --prefix="$PREFIX" && \
    make && make install && \
    cd .. && \
    wget https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz && \
    tar -xf mpfr-4.2.1.tar.xz && \
    cd mpfr-4.2.1 && \
    ./configure --prefix="$PREFIX" --with-gmp="$PREFIX" && \
    make && make install && \
    cd .. && \
    wget https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz && \
    tar -xf mpc-1.3.1.tar.gz && \
    cd mpc-1.3.1 && \
    ./configure --prefix="$PREFIX" --with-gmp="$PREFIX" --with-mpfr="$PREFIX" && \
    make && make install

RUN cd /home/builder/src && \
    wget https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz && \
    tar -xf gcc-14.2.0.tar.xz && \
    mkdir build-gcc && cd build-gcc && \
    ../gcc-14.2.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers --disable-hosted-libstdcxx --with-gmp="$PREFIX" --with-mpfr="$PREFIX" --with-mpc="$PREFIX" && \
    make all-gcc && \
    make all-target-libgcc && \
    make all-target-libstdc++-v3 && \
    make install-gcc && \
    make install-target-libgcc && \
    make install-target-libstdc++-v3

COPY src/ /home/builder/src/
COPY grub.cfg /home/builder/

COPY Makefile /home/builder/

RUN make all

RUN mkdir -p /home/builder/output

RUN cp /home/builder/iso/myos.iso /home/builder/output/ && \
    cp /home/builder/bin/myos.bin /home/builder/output/

CMD ["/bin/bash"]

# run-iso: qemu-system-i386 -cdrom myos.iso
# run-bin: qemu-system-i386 -kernel myos.bin
