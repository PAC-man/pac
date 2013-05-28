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

    ./build-pac.sh -device-

example:
    ./build-pac.sh urushi


There are also a few parameters that you can use when the script is executed:

* threads: Allows to choose a number of threads for syncing operation
* clean: Removes intermediates and output files
* sync: Sync the repo before building
* And many more


This will make a signed zip located on out/target/product/-device-.
