#!/usr/bin/env bash
set -ex

# Install
echo "**** install packages ****"
DOWNLOAD_URL=$(curl -sX GET "https://api.github.com/repos/FreeCAD/FreeCAD/releases/latest" \
  | awk -F '(": "|")' '/browser.*Linux-x86_64-py311.AppImage/ {print $3;exit}')
curl -o /tmp/freecad.app -L "${DOWNLOAD_URL}"
cd /tmp && chmod +x freecad.app
./freecad.app --appimage-extract
mv squashfs-root /opt/freecad

echo "**** launcher ****"
echo "#!/bin/bash" > /usr/bin/freecad
echo "xterm -e /opt/freecad/AppRun \"\${@}\"" >> /usr/bin/freecad
chmod +x /usr/bin/freecad

echo "**** cleanup ****"
apt-get autoclean
rm -rf \
  /config/.cache \
  /var/lib/apt/lists/* \
  /var/tmp/* \
  /tmp/*

echo "Done."

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