#!/usr/bin/env bash
set -ex

# Install Solvespace
pwd
ls -alh
tar -xvf $INST_SCRIPTS/solvespace/solvespace.tgz -C /

# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
fi