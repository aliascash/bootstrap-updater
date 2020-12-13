#!/bin/bash
# ============================================================================
#
# FILE:         cleanupBootstrapArchives.sh
#
# SPDX-FileCopyrightText: © 2020 Alias Developers
# SPDX-License-Identifier: MIT
#
# DESCRIPTION:  Helper script to remove outdated bootstrap archives
#
# AUTHOR:       HLXEasy
# PROJECT:      https://alias.cash/
#               https://github.com/aliascash/bootstrap-updater
#
# ============================================================================

currentDate=$(date +%Y-%m-%d)
testnetSuffix=''

# Check if testnet bootstrap should be created
if [[ $1 = '-t' ]] ; then
    shift
    testnetSuffix='-Testnet'
fi

cd /var/www/html/files/bootstrap || exit 1

previousBootstrapArchive=$(readlink BootstrapChain${testnetSuffix}.zip)

if [[ $previousBootstrapArchive == *"$currentDate"* ]] ; then
    echo "Linked bootstrap archive is from today, skipping link recreation"
else
    rm -f "${previousBootstrapArchive}" && rm -f BootstrapChain${testnetSuffix}.zip && ln -s Alias${testnetSuffix}-Blockchain-"${currentDate}".zip BootstrapChain${testnetSuffix}.zip
fi
