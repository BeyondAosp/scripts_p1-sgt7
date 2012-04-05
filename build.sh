#!/bin/bash

DEVICE=p1
for i in p1 p1c; do
  [ "$2" == "$i" ] && DEVICE="$i"
done

# VARIANT 	use
# user 		limited access; suited for production
# userdebug 	like "user" but with root access and debuggability; preferred for debugging
# eng		development configuration with additional debugging tools

VARIANT=userdebug
for i in user userdebug eng; do
  [ "$3" == "$i" ] && VARIANT="$i"
done

# --------------------------------------------

KERNELDIR="$ANDROID_BUILD_TOP/kernel/samsung/p1"
DEVICEDIR="$ANDROID_BUILD_TOP/device/samsung/$DEVICE"
CROSSCOMPILE="$ANDROID_BUILD_TOP/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-"

# --------------------------------------------

THREADS=$(grep processor /proc/cpuinfo | wc -l)

case "$1" in

  distclean)
      repo forall -c 'git clean -xdf'
      ;&
  clean)
      make clean
      cd $KERNELDIR
      make mrproper CROSS_COMPILE=$CROSSCOMPILE
      ;;
  kernel)
      cd $KERNELDIR
      ./build.sh $DEVICE
      mv $DEVICEDIR/kernel-$DEVICE $DEVICEDIR/kernel
      ;;
  system)
      time {
        source build/envsetup.sh
        [ ! -d vendor/cm/proprietary ] && ( cd vendor/cm ; ./get-prebuilts )
        lunch "cm_"$DEVICE"-"$VARIANT
        make -j$THREADS bacon
      }
      ;;
  *)
      echo
      echo "usage: ${0##*/} <action> [ <device> ] [ <build-variant> ]"
      echo
      echo "  <action> : clean|distclean|kernel|system"
      echo "  <device> : p1|p1c               default=$DEVICE"
      echo "  <variant>: user|userdebug|eng   default=$VARIANT"

esac
