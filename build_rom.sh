#!/bin/bash

# Colorize and add text parameters
grn=$(tput setaf 2)             #  green
txtbld=$(tput bold)             # Bold
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
txtrst=$(tput sgr0)             # Reset

DEVICE="$1"
SYNC="$2"
THREADS="$3"
CLEAN="$4"

# Time of build startup
res1=$(date +%s.%N)

# Sync with latest sources
if [ "$SYNC" == "sync" ]
then
   echo -e "${bldblu}Syncing latest sources ${txtrst}"
   repo sync -j"$THREADS"
fi

# Clean out folder
if [ "$CLEAN" == "clean" ]
then
   echo -e "${bldblu}Cleaning up out folder ${txtrst}"
   make clobber;
else
  echo -e "${bldblu}Skipping out folder cleanup ${txtrst}"
fi

# Setup environment
echo -e "${bldblu}Setting up build environment ${txtrst}"
. build/envsetup.sh

# Setup ccache
export USE_CCACHE=1
/usr/bin/ccache -M 50G

# For building recovery
export BUILDING_RECOVERY=false

# Prebuilt chromium
export USE_PREBUILT_CHROMIUM=1

# Fix common out folder not being a common
export ANDROID_FIXUP_COMMON_OUT=true

# Lunch device
echo -e "${bldblu}Lunching device... ${txtrst}"
lunch "slim_$DEVICE-userdebug"

# Remove previous build info
echo -e "${bldblu}Removing previous build.prop ${txtrst}"
rm $OUT/system/build.prop;

# Start compilation
echo -e "${bldblu}Starting build for $DEVICE ${txtrst}"
make -j"$THREADS" bacon

# Get elapsed time
res2=$(date +%s.%N)
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
