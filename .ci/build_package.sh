#!/bin/bash

set -e

trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "$0: \"${last_command}\" command failed with exit code $?"' ERR

echo "$0: building the package"

ARTIFACTS_FOLDER=$1

sudo apt-get install dpkg-dev

echo "$0: building the package into '$ARTIFACTS_FOLDER'"

mkdir -p $ARTIFACTS_FOLDER

dpkg-deb --build --root-owner-group package
dpkg-name package.deb

mv *.deb $ARTIFACTS_FOLDER
