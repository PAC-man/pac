Project Mayhem
===============

Getting started
---------------
First you must initialize a repository with our sources:

    repo init -u git://github.com/toyes/manifest.git -b jb-mr1

Then sync it up (This will take a while, so get a cup of coffee and some snickers):

    repo sync


Building Project Mayhem
------------------------

    ./rom-build.sh -device-

example:
    ./rom-build.sh skyrocket


This will make a signed zip located on out/target/product/-device-.
