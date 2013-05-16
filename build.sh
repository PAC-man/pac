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

echo -e $bldgrn"#  __________      .__.__       .___ "$txtrst" "$bldcya"   _________            .__        __           #"$txtrst"  "
echo -e $bldgrn"#  \______   \__ __|__|  |    __| _/ "$txtrst" "$bldcya"  /   _____/ ___________|__|______/  |_  ______ #"$txtrst"  "
echo -e $bldgrn"#   |    |  _/  |  \  |  |   / __ | "$txtrst" "$bldcya"   \_____  \_/ ___\_  __ \  \____ \   __\/  ___/ #"$txtrst"  "
echo -e $bldgrn"#   |    |   \  |  /  |  |__/ /_/ | "$txtrst" "$bldcya"   /        \  \___|  | \/  |  |_> >  |  \___ \  #"$txtrst"  "
echo -e $bldgrn"#   |______  /____/|__|____/\____ | "$txtrst" "$bldcya"  /_______  /\___  >__|  |__|   __/|__| /____  > #"$txtrst"  "
echo -e $bldgrn"#          \/                    \/ "$txtrst" "$bldcya"          \/     \/         |__|             \/  #"$txtrst"  "

#-------------------ROMS To Be Built------------------#

PRODUCT=$1
BRNCHCMD=pac_"$PRODUCT"-userdebug
BUILDNME=$PRODUCT_PAC_JB_4.2.2-v$(VERSION)_$(shell date +%Y%m%d-%H%M%S)
OUTPUTNME=$PRODUCT_PAC_JB_4.2.2-v$(VERSION)_$(shell date +%Y%m%d-%H%M%S)

#---------------------Build Settings------------------#

# should they be moved out of the output folder
# like a dropbox or other cloud storage folder
# or any other folder you want
# also required for FTP upload
MOVE=y

# folder they should be moved to
if [ $MOVE = "y" ]; then
   mkdir cloud
	STORAGE=cloud
fi

# your build source code directory path
SAUCE=$DIR

# number for the -j parameter
J=9

# generate an MD5
MD5=n

# sync repositories
SYNC=y

# run make clobber first
CLOBBER=y

#build threads
THREADS=9

#----------------------SFTP Settings--------------------#

# set "SFTP=y" if you want to enable FTP uploading
# must have moving to storage folder enabled first
SFTP=y

HOST[0]=upload.goo.im
USER[0]=pacman
PASSWORD[0]=????
FTPDIR[0]=public_html/$PRODUCT

HOST[2]=basketbuild.com
USER[2]=u71569905-pacman
PASSWORD[2]=????
FTPDIR[2]=$PRODUCT

#---------------------Build Bot Code-------------------#

echo -n "Moving to source directory..."
cd $SAUCE
echo "done!"

if [ $SYNC = "y" ]; then
	echo -n "Running repo sync..."
	repo sync
	echo "done!"
fi

if [ $CLOBBER = "y" ]; then
	echo -n "Running make clobber..."
	make clobber -j"$THREADS"
	echo "done!"
fi

# Download Prebuild Files
echo -e ""
echo -e "${bldblu}Downloading prebuilts ${txtrst}"
cd vendor/cm
./get-prebuilts
cd ./../..
echo -e ""

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
		mv $SAUCE/out/target/product/$PRODUCT/$BUILDNME".zip" $STORAGE/$OUTPUTNME".zip"
		if [ $MD5 = "y" ]; then
			mv $SAUCE/out/target/$PRODUCT/$BUILDNME".md5sum.txt" $STORAGE/$OUTPUTNME".md5sum.txt"
		fi
		echo "done!"
	fi

cd $HOME

#----------------------FTP Upload Code--------------------#

if  [ $FTP = "y" ]; then
	echo "Initiating FTP connection..."

	cd $STORAGE
	ATTACHROM=`for file in *"-"$DATE".zip"; do echo -n -e "put ${file}\n"; done`
	if [ $MD5 = "y" ]; then
		ATTACHMD5=`for file in *"-"$DATE".md5sum.txt"; do echo -n -e "put ${file}\n"; done`
		ATTACH=$ATTACHROM"/n"$ATTACHMD5
	else
		ATTACH=$ATTACHROM
	fi

# Uploading It :D

for VAL in "${!HOST[@]}"
do
	cd $STORAGE
	echo -e "Connecting to ${HOST[$VAL]} with user ${USER[$VAL]}..."
	sftp ${HOST[$VAL]}
	cd ${FTPDIR[$VAL]}
	$ATTACH
	exit
done

#----------------------Don't Be Messy--------------------#
if [ $MOVE = "y" ]; then
	cd $HOME
	rm -r cloud
fi

# finished? get elapsed time
res2=$(date +%s.%N)
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"

echo "All Done! :D"
