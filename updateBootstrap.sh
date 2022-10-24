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
if [[ -f ~/.aliaswallet${testnet1}/blk0002.dat ]] ; then
    cp ~/.aliaswallet${testnet1}/blk0002.dat ~/bootstrap-data${testnet3}/
fi
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
zip ~/Alias${testnet2}-Blockchain-"${currentDate}".part.zip -r -s 50m .
cd ~ || exit 1
for i in Alias"${testnet2}"-Blockchain-"${currentDate}".part.z* ; do sha256sum "$i" | tee -a ~/Alias${testnet2}-Blockchain-"${currentDate}".part.txt ; done

cd - >/dev/null || exit
echo "Done"

if [[ $1 = '-u' ]] ; then
    shift

    echo "Cleanup previous bootstrap on download server"
    "${ownLocation}"/cleanupBootstrapArchives.sh ${testnet4}

    echo "Installing bootstrap archive"
    mv ~/Alias${testnet2}-Blockchain-"${currentDate}".zip /var/www/html/files/bootstrap/

    echo "Remove old archive and update download link"
    "${ownLocation}"/cleanupAndRecreateLinks.sh ${testnet4}

    echo "Installing split bootstrap archives"
    mv ~/Alias${testnet2}-Blockchain-"${currentDate}".part.* /var/www/html/files/bootstrap/

    echo "Updating index link for split archives"
    cd /var/www/html/files/bootstrap/ || exit 1
    rm -f BootstrapChainParts${testnet2}.txt && ln -s Alias${testnet2}-Blockchain-"${currentDate}".part.txt BootstrapChainParts${testnet2}.txt
    cd - >/dev/null || exit

    echo "Done"
fi
