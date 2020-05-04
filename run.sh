#!/usr/bin/env bash

# Fail on error, verbose output
set -exo pipefail

# Build project
../../../../android-ndk-r21/ndk-build.cmd NDK_DEBUG=1 1>&2

# Figure out which ABI and SDK the device has
abi=$(adb shell getprop ro.product.cpu.abi | tr -d '\r')
sdk=$(adb shell getprop ro.build.version.sdk | tr -d '\r')
pre=$(adb shell getprop ro.build.version.preview_sdk | tr -d '\r')
rel=$(adb shell getprop ro.build.version.release | tr -d '\r')

if [[ -n "$pre" && "$pre" > "0" ]]; then
  sdk=$(($sdk + 1))
fi

# PIE is only supported since SDK 16
if (($sdk >= 16)); then
  bin=minicap
else
  bin=minicap-nopie
fi

args=
if [ "$1" = "autosize" ]; then
  set +o pipefail
  size=$(adb shell dumpsys window | grep -Eo 'init=[0-9]+x[0-9]+' | head -1 | cut -d= -f 2)
  if [ "$size" = "" ]; then
    w=$(adb shell dumpsys window | grep -Eo 'DisplayWidth=[0-9]+' | head -1 | cut -d= -f 2)
    h=$(adb shell dumpsys window | grep -Eo 'DisplayHeight=[0-9]+' | head -1 | cut -d= -f 2)
    size="${w}x${h}"
  fi
  args="-P $size@$size/0"
  set -o pipefail
  shift
fi

# Create a directory for our resources
# dir=/data/local/tmp/minicap-devel #not working with Git Bash so following workaround is needed
dir='//data\local\tmp\minicap-devel\'
# Keep compatible with older devices that don't have `mkdir -p`.
adb shell "mkdir $dir 2>/dev/null || true"

#custom check
[ ! -d $dir/ ] && echo "Directory target DOES NOT exists."
echo "--------------------------------------"
echo $dir

# Upload the binary
# adb push libs/$abi/$bin $dir/ # the last '/' causing issues with Git Bash
adb push libs/$abi/$bin $dir

# Upload the shared library
if [ -e jni/minicap-shared/aosp/libs/android-$rel/$abi/minicap.so ]; then
  adb push jni/minicap-shared/aosp/libs/android-$rel/$abi/minicap.so $dir
else
  adb push jni/minicap-shared/aosp/libs/android-$sdk/$abi/minicap.so $dir
fi

###For windows 
 adb shell chmod 777 $dir$bin

# Run!
# adb shell LD_LIBRARY_PATH=$dir $dir/$bin $args "$@"
adb shell LD_LIBRARY_PATH=$dir $dir$bin $args "$@"

# Clean up
adb shell rm -r $dir
