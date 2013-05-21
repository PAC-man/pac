PAC-man
===============

Getting started
---------------
First you must initialize a repository with our sources:

    repo init -u git://github.com/PAC-man/android.git -b cm-10.1

Then sync it up (This will take a while, so get a cup of coffee and some snickers):

    repo sync


Building P.A.C
------------------------

For building P.A.C you must cd to the working directory.
Make sure you have your device tree sources, located on

    cd device/-manufacturer-/-device-

Now you can run our build script:

    ./build-pac.sh


There are also a few parameters that you can use in the script:
Ability to Enter our Custom THREADS For Building
Can Generate md5sum's and upload them if wanted
Can Upload the same ROM to Infinite SFTP Channels if entered into the script
Make Clobber if needed
Repo sync if needed
Downloads Prebuild Files
Has a Awesome ASCII Art
Looks for PAC product dependencies
Deletes out/target/product/*/obj/KERNEL_OBJ/.version Before Building
Deletes out/target/product/*/pac_*-ota-eng.*.zip After Building
Is Not Messy At All
Shows Elapsed Time
Best For Servers and Local PC's
And Will Be Updated By Me Frequently
Can Be Used For Logging the Builds too using ./build-pac.sh >> pac-build-log.txt


This will make a signed zip located on out/target/product/-device-.
