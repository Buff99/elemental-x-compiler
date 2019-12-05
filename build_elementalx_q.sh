#!/bin/bash

# let's make sure the toolchain to use has been passed in as an argument, if not, show what to do, and exit
if [ -z $1 ]; then
    echo "No toolchain provided. Usage: $0 google|uber|clang"
    exit 2
fi 

# Let's clean up first
source clean_elementalx_q.sh;

echo "------------------------------------------";
echo " Time to build.";
echo "------------------------------------------";

# setup some variables
COMPILERDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
KERNELDIR=$COMPILERDIR/Kernels/ElementalQ;
OUTDIR=$COMPILERDIR/Elemental_Q_Compiled;
FLASHDIR=$COMPILERDIR/Elemental_Q_Flashable;
OWNER=$(stat -c '%U' "$COMPILERDIR");
ELEVERSION="4.12";
CORES=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l);
THREADS=`expr $CORES / 2`;

# Set which toolchain you want to use.  right now, only uber, and google are valid
TOOLCHAIN=$1;

# setup our flashfile name
FLASHFILE=ElementalX-PH1-$ELEVERSION-$TOOLCHAIN.zip;

# setup some default exprts
export KBUILD_BUILD_USER=kevp75;
export KBUILD_BUILD_HOST=wmhost.cc;
export KBUILD_CFLAGS += -w;
export ARCH=arm64;

# throw in our cross compiler
export CROSS_COMPILE=$COMPILERDIR/Toolchains/$TOOLCHAIN/bin/aarch64-linux-android-;

# make our output directory, and hop into it
mkdir -p $OUTDIR;
cd $KERNELDIR;

# compile the configuration
make O=$OUTDIR elementalx_defconfig;

# compile the kernel
make O=$OUTDIR -j$THREADS;

# make sure we own the outdir
chown -R $OWNER:$OWNER $OUTDIR;

# copy the kernel image to the zip folders
cp $OUTDIR/arch/arm64/boot/Image.gz-dtb $FLASHDIR/aroma/boot/elex.Image;
cp $OUTDIR/arch/arm64/boot/Image.gz-dtb $FLASHDIR/non-aroma/boot/elex.Image;

# pop into the aroma zip dir and compress it
cd $FLASHDIR/aroma;
zip -r $FLASHFILE *;
mv $FLASHFILE ../aroma-$FLASHFILE;

# pop into the non-aroma zip dir and compress it
cd $FLASHDIR/non-aroma;
zip -r $FLASHFILE *;
mv $FLASHFILE ../non-aroma-$FLASHFILE;

# go back to our home dir, and make sure we own the outdir
cd $COMPILERDIR;
chown -R $OWNER:$OWNER *;

