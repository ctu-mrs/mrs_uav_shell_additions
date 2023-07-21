#!/bin/bash

set -e

trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "$0: \"${last_command}\" command failed with exit code $?"' ERR

cd /tmp
rm -rf ppa

GIT_TAG=$(git describe --exact-match --tags HEAD || echo "")

if [ -z $GIT_TAG ]; then

  echo "$0: Git tag not recognized, pushing to unstable PPA"

  git clone https://$PUSH_TOKEN@github.com/ctu-mrs/ppa-unstable.git ppa

else

  echo "$0: Git tag recognized as '$GIT_TAG', building against stable PPA"

  $MY_PATH/add_ctu_mrs_stable_ppa.sh

  git clone https://$PUSH_TOKEN@github.com/ctu-mrs/ppa-stable.git ppa

fi

cd ppa

# TODO: will need to be reworked when we start building for ARM
ARCH=amd64

BRANCH=debs
git checkout $BRANCH

git config user.email github@github.com
git config user.name github

rm mrs-uav-shell-additions_*"$ARCH".deb || echo "$0: there are no older *.deb packages to remove"

cp $GITHUB_WORKSPACE/*.deb ./

GIT_STATUS=$(git status --porcelain)

if [ -n "$GIT_STATUS" ]; then

  git add -A
  git commit -m "Added new deb packages"

  # the upstream might have changed in the meantime, try to merge it first
  git fetch
  git merge origin/$BRANCH

  git push

  echo "$0: Package deployed to $PPA"

else

  echo "$0: Nothing to commit"

fi
