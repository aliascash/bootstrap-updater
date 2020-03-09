#!/bin/bash
# ============================================================================
#
# FILE:         updateBootstrap.sh
#
# DESCRIPTION:  Helper script to update bootstrap data automatically
#
# AUTHOR:       HLXEasy
# PROJECT:      https://spectreproject.io/
#               https://github.com/spectrecoin/bootstrap-updater
#
# ============================================================================

currentDate=$(date +%Y-%m-%d)
cd

echo "Wipe out current bootstrap content"
rm -f ~/Spectrecoin-Blockchain-*.zip
rm -rf ~/bootstrap-data
mkdir -p ~/bootstrap-data/txleveldb
echo "Done"

echo "Stop Spectrecoin daemon"
sudo systemctl stop spectrecoind
echo "Done"

echo "Copy current blockchain and transaction db"
cp ~/.spectrecoin/blk0001.dat ~/bootstrap-data/
cp ~/.spectrecoin/txleveldb/*.ldb ~/.spectrecoin/txleveldb/*.log ~/.spectrecoin/txleveldb/CURRENT ~/.spectrecoin/txleveldb/MANIFEST-* ~/bootstrap-data/txleveldb/
echo "Done"

echo "Start Spectrecoin daemon"
sudo systemctl start spectrecoind
echo "Done"

echo "Create bootstrap archive"
cd ~/bootstrap-data
zip ~/Spectrecoin-Blockchain-${currentDate}.zip -r .
cd - >/dev/null
echo "Done"

if [[ $1 = '-u' ]] ; then
    shift
    scp ~/Spectrecoin-Blockchain-${currentDate}.zip jenkins@download.spectreproject.io:/var/www/html/files/bootstrap/
fi
