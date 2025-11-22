#!/usr/bin/env bash
set -ex

# Set variables
APP_NAME="orcaslicer"
INSTALL_DIR="/opt/${APP_NAME}"
ICON_FILE="${INSTALL_DIR}/resources/OrcaSlicer.svg"
DESKTOP_FILENAME="OrcaSlicer.desktop"
RELEASE_URL=$(curl -sX GET "https://api.github.com/repos/SoftFever/OrcaSlicer/releases/latest"     | awk '/url/{print $4;exit}' FS='[""]') && \
DOWNLOAD_URL=$(curl -sX GET "${RELEASE_URL}" | awk '/browser_download_url.*Ubuntu2404/{print $4;exit}' FS='[""]') && \

# Install
echo "**** install packages ****"
curl -o /tmp/${APP_NAME}.app -L "${DOWNLOAD_URL}"
cd /tmp && chmod +x ${APP_NAME}.app
./${APP_NAME}.app --appimage-extract
mv squashfs-root ${INSTALL_DIR}

echo "**** launcher ****"
cat > "/usr/bin/${APP_NAME}" <<EOL
#!/usr/bin/env bash
export APPDIR=${INSTALL_DIR}
xterm -e ${INSTALL_DIR}/AppRun \"\${@}\"
EOL


#echo "#!/bin/bash" > /usr/bin/${APP_NAME}
#echo "xterm -e ${INSTALL_DIR}/AppRun \"\${@}\"" >> /usr/bin/${APP_NAME}
#chmod +x /usr/bin/${APP_NAME}

sed -i 's@^Exec=.*@Exec=/usr/bin/'"${APP_NAME}"'@g' ${INSTALL_DIR}/${DESKTOP_FILENAME}
sed -i 's@^Icon=.*@Icon='"${ICON_FILE}"'@g' ${INSTALL_DIR}/${DESKTOP_FILENAME}
cp ${INSTALL_DIR}/${DESKTOP_FILENAME}  $HOME/Desktop/${DESKTOP_FILENAME}
cp ${INSTALL_DIR}/${DESKTOP_FILENAME} /usr/share/applications/${DESKTOP_FILENAME}
# Desktop icon
chmod +x $HOME/Desktop/${DESKTOP_FILENAME}
# Menu icon
chmod +x /usr/share/applications/${DESKTOP_FILENAME}

# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /config/.cache \
    /config/.launchpadlib \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
fi

echo "Done."