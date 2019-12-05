#!/bin/bash

COMPILERDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
KERNELDIR=$COMPILERDIR/Kernels/ElementalQ;
OUTDIR=$COMPILERDIR/Elemental_Q_Compiled;
FLASHDIR=$COMPILERDIR/Elemental_Q_Flashable;

echo "------------------------------------------";
echo " Clean up our build."
echo "------------------------------------------";

cd $KERNELDIR;

make ARCH=arm64 distclean
rm -rf $OUTDIR/*
rm -f $FLASHDIR/aroma/boot/elex.Image
rm -f $FLASHDIR/aroma/*.zip
rm -f $FLASHDIR/non-aroma/boot/elex.Image
rm -f $FLASHDIR/non-aroma/*.zip

echo "------------------------------------------";
echo " All set ..."
echo "------------------------------------------";

cd $COMPILERDIR

