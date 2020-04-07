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

testnet1=''
testnet2=''
testnet3=''

# Check if testnet bootstrap should be created
if [[ $1 = '-t' ]] ; then
    shift
    echo "Creating bootstrap for TESTNET"
    testnet1='/testnet'
    testnet2='-Testnet'
    testnet3='-testnet'
fi

echo "Wipe out current bootstrap content"
rm -f ~/Spectrecoin${testnet2}-Blockchain-*.zip
rm -rf ~/bootstrap-data${testnet3}
mkdir -p ~/bootstrap-data${testnet3}/txleveldb
echo "Done"

echo "Stop Spectrecoin daemon"
sudo systemctl stop spectrecoind${testnet3}
echo "Done"

echo "Copy current blockchain and transaction db"
cp ~/.spectrecoin${testnet1}/blk0001.dat ~/bootstrap-data${testnet3}/
cp ~/.spectrecoin${testnet1}/txleveldb/*.ldb ~/.spectrecoin${testnet1}/txleveldb/*.log ~/.spectrecoin${testnet1}/txleveldb/CURRENT ~/.spectrecoin${testnet1}/txleveldb/MANIFEST-* ~/bootstrap-data${testnet3}/txleveldb/
echo "Done"

echo "Start Spectrecoin daemon"
sudo systemctl start spectrecoind${testnet3}
echo "Done"

echo "Create bootstrap archive"
cd ~/bootstrap-data${testnet3}
zip ~/Spectrecoin${testnet2}-Blockchain-${currentDate}.zip -r .
cd - >/dev/null
echo "Done"

if [[ $1 = '-u' ]] ; then
    shift
    echo "Upload bootstrap archive"
    scp ~/Spectrecoin${testnet2}-Blockchain-${currentDate}.zip jenkins@download.spectreproject.io:/var/www/html/files/bootstrap/
    echo "Updating download link"
    ssh jenkins@download.spectreproject.io "cd /var/www/html/files/bootstrap/ && rm -f BootstrapChain${testnet2}.zip && ln -s Spectrecoin${testnet2}-Blockchain-${currentDate}.zip BootstrapChain${testnet2}.zip"
    echo "Done"
fi
