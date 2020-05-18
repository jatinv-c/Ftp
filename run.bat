::@echo off
::Determine device dimensions
if "%1"=="" (
set cmd_dimension=adb shell dumpsys window
FOR /f "tokens=1" %%G IN ('%cmd_dimension% ^|find "init"') DO set dim=%%G
set orienation=0
set args=-P %dim:~5%@%dim:~5%/%orienation%
)else (set args=%1)
echo %args%
::Build the project first before running this script by following command
::ndk-build
::
::Figure out which ABI and SDK the device has
::ABI
FOR /F "tokens=* USEBACKQ" %%g IN (`adb shell getprop ro.product.cpu.abi`) do (SET "ABI=%%g")
::SDK
FOR /F "tokens=* USEBACKQ" %%g IN (`adb shell getprop ro.build.version.sdk`) do (SET "SDK=%%g")
::PRE
FOR /F "tokens=* USEBACKQ" %%g IN (`adb shell getprop ro.build.version.preview_sdk`) do (SET "PRE=%%g")
::REL
FOR /F "tokens=* USEBACKQ" %%g IN (`adb shell getprop ro.build.version.release`) do (SET "REL=%%g")
::
::PIE is only supported since SDK 16
if %SDK% GTR 17 (set BIN=minicap) else (set BIN=minicap-nopie)
echo BIN : %BIN%
::
::
::Create a directory for our resources
SET DIR=/data/local/tmp/minicap-devel
echo DIR : %DIR%
::Keep compatible with older devices that don't have `mkdir -p`.
adb shell "mkdir $dir 2>/dev/null || true"
::
::
::Upload the binary
adb push libs/%ABI%/%BIN% %DIR%
::
::Upload the shared library
adb push jni/minicap-shared/aosp/libs/android-%SDK%/%ABI%/minicap.so %DIR%
::
::
adb shell chmod 777 %DIR%/%BIN%
::Run!
adb shell LD_LIBRARY_PATH=%DIR% %DIR%/%BIN% %args%
::pause
::pause

