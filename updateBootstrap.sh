#!/bin/bash
# ============================================================================
#
# FILE:         updateBootstrap.sh
#
# SPDX-FileCopyrightText: © 2020 Alias Developers
# SPDX-FileCopyrightText: © 2016 SpectreCoin Developers
# SPDX-License-Identifier: MIT
#
# DESCRIPTION:  Helper script to update bootstrap data automatically
#
# AUTHOR:       HLXEasy
# PROJECT:      https://alias.cash/
#               https://github.com/aliascash/bootstrap-updater
#
# ============================================================================

# Backup where we came from
callDir=$(pwd)
ownLocation="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
scriptName=$(basename $0)

currentDate=$(date +%Y-%m-%d)
cd || exit

testnet1=''
testnet2=''
testnet3=''
testnet4=''

# Check if testnet bootstrap should be created
if [[ $1 = '-t' ]] ; then
    shift
    echo "Creating bootstrap for TESTNET"
    testnet1='/testnet'
    testnet2='-Testnet'
    testnet3='-testnet'
    testnet4='-t'
fi

echo "Wipe out current bootstrap content"
rm -f ~/Alias${testnet2}-Blockchain-*.z*
rm -f ~/Alias${testnet2}-Blockchain-*.txt
rm -rf ~/bootstrap-data${testnet3}
mkdir -p ~/bootstrap-data${testnet3}/txleveldb
echo "Done"

echo "Stop Alias daemon"
sudo systemctl stop aliaswalletd${testnet3}
echo "Done"

echo "Copy current blockchain and transaction db"
cp ~/.aliaswallet${testnet1}/blk0001.dat ~/bootstrap-data${testnet3}/
cp ~/.aliaswallet${testnet1}/txleveldb/*.ldb ~/.aliaswallet${testnet1}/txleveldb/*.log ~/.aliaswallet${testnet1}/txleveldb/CURRENT ~/.aliaswallet${testnet1}/txleveldb/MANIFEST-* ~/bootstrap-data${testnet3}/txleveldb/
echo "Done"

echo "Start Alias daemon"
sudo systemctl start aliaswalletd${testnet3}
echo "Done"

echo "Create bootstrap archive"
cd ~/bootstrap-data${testnet3} || exit 1

# Create one big archive
zip ~/Alias${testnet2}-Blockchain-"${currentDate}".zip -r .

# Create split archive and index file
zip ~/Alias${testnet2}-Blockchain-"${currentDate}".part.zip -r -s 100m .
cd ~ || exit 1
for i in Alias"${testnet2}"-Blockchain-"${currentDate}".part.z* ; do sha256sum "$i" | tee -a ~/Alias${testnet2}-Blockchain-"${currentDate}".part.txt ; done

cd - >/dev/null || exit
echo "Done"

if [[ $1 = '-u' ]] ; then
    shift

    echo "Cleanup previous bootstrap on download server"
    scp "${ownLocation}"/cleanupBootstrapArchives.sh jenkins@download.alias.cash:/home/jenkins/ || exit 1
    # shellcheck disable=SC2029
    ssh jenkins@download.alias.cash "/home/jenkins/cleanupBootstrapArchives.sh ${testnet4}"

    echo "Upload bootstrap archive"
    scp ~/Alias${testnet2}-Blockchain-"${currentDate}".zip jenkins@download.alias.cash:/var/www/html/files/bootstrap/ || exit 1

    echo "Remove old archive and update download link"
    # shellcheck disable=SC2029
    ssh jenkins@download.alias.cash "cd /var/www/html/files/bootstrap/ && rm -f \$(readlink BootstrapChain${testnet2}.zip) && rm -f BootstrapChain${testnet2}.zip && ln -s Alias${testnet2}-Blockchain-${currentDate}.zip BootstrapChain${testnet2}.zip"

    echo "Upload split bootstrap archives"
    scp ~/Alias${testnet2}-Blockchain-"${currentDate}".part.* jenkins@download.alias.cash:/var/www/html/files/bootstrap/ || exit 1

    echo "Updating index link for split archives"
    ssh jenkins@download.alias.cash "cd /var/www/html/files/bootstrap/ && rm -f BootstrapChainParts${testnet2}.txt && ln -s Alias${testnet2}-Blockchain-${currentDate}.part.txt BootstrapChainParts${testnet2}.txt"

    echo "Done"
fi
