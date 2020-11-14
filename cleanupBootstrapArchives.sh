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

# Backup where we came from
callDir=$(pwd)
ownLocation="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
scriptName=$(basename $0)

currentDate=$(date +%Y-%m-%d)
cd || exit

testnetSuffix=''

# Check if testnet bootstrap should be created
if [[ $1 = '-t' ]] ; then
    shift
    echo "Cleanup bootstrap archives for TESTNET"
    testnetSuffix='-Testnet'
else
    echo "Cleanup bootstrap archives"
fi

cd /var/www/html/files/bootstrap || exit 1
#cd /tmp/bootstrap-cleanup-test || exit 1

echo "Wipe out current bootstrap content"
previousBootstrapPartsIndex=$(readlink BootstrapChainParts${testnetSuffix}.previous.txt)
latestBootstrapPartsIndex=$(readlink BootstrapChainParts${testnetSuffix}.txt)

if [[ -e ${previousBootstrapPartsIndex} ]] && [[ -e ${latestBootstrapPartsIndex} ]] ; then
    if [[ $latestBootstrapPartsIndex == *"$currentDate"* ]] ; then
        echo "Latest bootstrap archive is from today, nothing to cleanup"
    elif [[ "${previousBootstrapPartsIndex}" = "${latestBootstrapPartsIndex}" ]] ; then
        echo "Current and previous bootstrap link pointing to the same index file, nothing to cleanup"
    else
        # shellcheck disable=SC2162,SC2034
        while read hash filename ; do
            rm -f "${filename}"
        done < "${previousBootstrapPartsIndex}"
        rm -f "${previousBootstrapPartsIndex}"

        echo "Rotating latest bootstrap"
        rm -f BootstrapChainParts${testnetSuffix}.previous.txt && ln -s "${latestBootstrapPartsIndex}" BootstrapChainParts${testnetSuffix}.previous.txt
    fi
else
    echo "Current a/o previous bootstrap index not found, nothing to cleanup"
fi
