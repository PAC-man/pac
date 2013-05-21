#!/bin/bash

# leave alone
DATE=`eval date +%m`-`eval date +%d`
res1=$(date +%s.%N)
DIR=`pwd`

# PAC version
MAJOR=$(cat $DIR/vendor/pac/config/pac_common.mk | grep 'PAC_VERSION_MAJOR = *' | sed  's/PAC_VERSION_MAJOR = //g')
MINOR=$(cat $DIR/vendor/pac/config/pac_common.mk | grep 'PAC_VERSION_MINOR = *' | sed  's/PAC_VERSION_MINOR = //g')
MAINTENANCE=$(cat $DIR/vendor/pac/config/pac_common.mk | grep 'PAC_VERSION_MAINTENANCE = *' | sed  's/PAC_VERSION_MAINTENANCE = //g')
VERSION=$MAJOR.$MINOR.$MAINTENANCE


# Colorize and add text parameters
red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
cya=$(tput setaf 6)             #  cyan
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgrn=${txtbld}$(tput setaf 2) #  green
bldylw=${txtbld}$(tput setaf 3) #  yellow
bldblu=${txtbld}$(tput setaf 4) #  blue
bldppl=${txtbld}$(tput setaf 5) #  purple
bldcya=${txtbld}$(tput setaf 6) #  cyan
txtrst=$(tput sgr0)             # Reset

# Scratch that
echo -e '\0033\0143'
clear

echo -e $bldcya"#####################################################"$txtrst"  "
echo -e $bldcya"# ____                                              #"$txtrst"  "
echo -e $bldcya"#/\  _'\                /'\_/'\                     #"$txtrst"  "
echo -e $bldcya"#\ \ \_\ \ __      ___ /\      \     __      ___    #"$txtrst"  "
echo -e $bldcya"# \ \ '__/'__'\   /'___\ \ \__\ \  /'__'\  /' _ '\  #"$txtrst"  "
echo -e $bldcya"#  \ \ \/\ \_\.\_/\ \__/\ \ \_/\ \/\ \_\.\_/\ \/\ \ #"$txtrst"  "
echo -e $bldcya"#   \ \_\ \__/.\_\ \____\\ \_\\ \_\ \__/.\_\ \_\ \_\#"$txtrst"  "
echo -e $bldcya"#    \/_/\/__/\/_/\/____/ \/_/ \/_/\/__/\/_/\/_/\/_/#"$txtrst"  "
echo -e $bldcya"#####################################################"$txtrst"  "
echo -e $bldcya"#▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼#"$txtrst"  "
echo -e ${cya}"#►              Building ${bldgrn}P ${bldppl}A ${bldblu}C ${bldylw}v$VERSION             ◄#${txtrst}";
echo -e $bldcya"#▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼#"$txtrst"  "

#-------------------ROMS To Be Built------------------#

PRODUCT=$1
BRNCHCMD=pac_"$PRODUCT"-userdebug
BUILDNME=$PRODUCT"_PAC_JB_4.2.2-v"$VERSION"_"$shell date +%Y%m%d-%H%M%S
OUTPTNME=$PRODUCT"_PAC_JB_4.2.2-v"$VERSION"_"$shell date +%Y%m%d-%H%M%S

# your build source code directory path
SAUCE=$DIR


# generate an MD5
echo -e "${bldblu}Please write to Generate MD5 or not followed by [ENTER] [y/n] ${txtrst}"
read MD5 

# sync repositories
echo -e "${bldblu}Please write to Sync with latest sources or not followed by [ENTER] [y/n] ${txtrst}"
read SYNC

# run make clobber after build
echo -e "${bldblu}Please write to clobber or not followed by [ENTER] [y/n] ${txtrst}"
read CLOBBER

#build threads
echo -e "${bldblu}Please write desired threads followed by [ENTER] ${txtrst}"
read THREADS

#---------------------Build Bot Code-------------------#

echo -n "Moving to source directory..."
cd $SAUCE
echo "done!"



if [ $SYNC = "y" ]; then
	echo -n "${bldblu}Fetching latest sources ${txtrst}"
	repo sync -j"$THREADS"
	echo "done!"
fi

# Download Prebuild Files
echo -e ""
echo -e "${bldblu}Downloading prebuilts ${txtrst}"
cd vendor/cm
./get-prebuilts
cd ./../..
echo -e ""

# PAC device dependencies
echo -e ""
echo -e "${bldblu}Looking for PAC product dependencies ${txtrst}${cya}"
./vendor/pac/tools/getdependencies.py $PRODUCT
echo -e "${txtrst}"


rm -f out/target/product/*/obj/KERNEL_OBJ/.version

	echo -n "Starting build..."
	. build/envsetup.sh && lunch $BRNCHCMD && brunch $BRNCHCMD -j"$THREADS"
	echo "done!"

	if [ $MD5 = "y" ]; then
		echo -n "Generating MD5..."
		md5sum $SAUCE/out/target/product/$PRODUCT/$BUILDNME".zip" | sed 's|'$SAUCE'/out/target/product/'$PRODUCT'/||g' > $SAUCE/out/target/product/$PRODUCT/$BUILDNME".md5sum.txt"
		echo "done!"
	fi

	if  [ $MOVE = "y" ]; then
		echo -n "Moving to cloud storage directory..."
		mv $SAUCE/out/target/product/$PRODUCT/$BUILDNME".zip" $STORAGE/$OUTPTNME".zip"
		if [ $MD5 = "y" ]; then
			mv $SAUCE/out/target/$PRODUCT/$BUILDNME".md5sum.txt" $STORAGE/$OUTPTNME".md5sum.txt"
		fi
		echo "done!"
	fi

cd $HOME

rm -f out/target/product/*/pac_*-ota-eng.*.zip

#----------------------Don't Be Messy--------------------#

if [ $CLOBBER = "y" ]; then
	echo -n "${bldblu}Cleaning intermediates and output files ${txtrst}"
	make clobber -j"$THREADS"
	echo "done!"
fi

# finished? get elapsed time
res2=$(date +%s.%N)
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"

echo "PacMan-ROM packages built!"
