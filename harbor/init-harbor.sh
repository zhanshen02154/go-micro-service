#!/bin/bash

DEV_DATA_PATH=/dev-data

if [ ! -d $DEV_DATA_PATH ]; then
	mkdir -p $DEV_DATA_PATH
fi

cd $DEV_DATA_PATH

echo "Downloading offline installer..."
wget --no-check-certificate https://github.com/goharbor/harbor/releases/download/v1.8.6/harbor-offline-installer-v1.8.6.tgz
echo "Harbor offline installer was downloaded"
echo "Extracting files..."
tar -zxvf harbor-offline-installer-v1.8.6.tgz
echo "Files were extracted"
mv harbor-offline-installer-v1.8.6 harbor
cd harbor
echo "Installing harbor..."
sh install.sh
echo "Harbor was installed"