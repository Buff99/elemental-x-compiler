#!/bin/bash

# let's make sure the toolchain to use has been passed in as an argument, if not, show what to do, and exit
if [ -z $1 ]; then
    echo "No toolchain provided. Usage: $0 google|uber"
    exit 2
fi 

# Let's clean up first
source clean_pie.sh;

echo "------------------------------------------";
echo " Time to build.";
echo "------------------------------------------";

# setup some variables
COMPILERDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
KERNELDIR="$(dirname "$COMPILERDIR")"/ElementalPie;
OUTDIR=$COMPILERDIR/Elemental_Pie_Compiled;
FLASHDIR=$COMPILERDIR/Elemental_Pie_Flashable;
OWNER=$(stat -c '%U' "$COMPILERDIR");
ELEVERSION="4.1.0"
CORES=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l);

# Set which toolchain you want to use.  right now, only uber, and google are valid
TOOLCHAIN=$1

# setup our flashfile name
FLASHFILE=ElementalX-PH1-$ELEVERSION-$TOOLCHAIN.zip

# setup some default exprts
export KBUILD_BUILD_USER=kevp75;
export KBUILD_BUILD_HOST=wmhost.cc;
export KBUILD_CFLAGS += -w
export ARCH=arm64

# throw in our cross compiler
export CROSS_COMPILE=$COMPILERDIR/toolchains/$TOOLCHAIN/bin/aarch64-linux-android-

# make our output directory, and hop into it
mkdir -p $OUTDIR;
cd $KERNELDIR;

# compile the configuration
make O=$OUTDIR elementalx_defconfig;

# compile the kernel
make O=$OUTDIR -j$CORES;

# make sure we own the outdir
chown -R $OWNER:$OWNER $OUTDIR

# copy the kernel image to the zip folders
cp $OUTDIR/arch/arm64/boot/Image.gz-dtb $FLASHDIR/aroma/boot/elex.Image
cp $OUTDIR/arch/arm64/boot/Image.gz-dtb $FLASHDIR/non-aroma/boot/elex.Image

# pop into the aroma zip dir and compress it
cd $FLASHDIR/aroma
zip -r $FLASHFILE *
mv $FLASHFILE ../aroma-$FLASHFILE

# pop into the non-aroma zip dir and compress it
cd $FLASHDIR/non-aroma
zip -r $FLASHFILE *
mv $FLASHFILE ../non-aroma-$FLASHFILE

# go back to our home dir, and make sure we own the outdir
cd $COMPILERDIR
chown -R $OWNER:$OWNER *

