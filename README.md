# Spectrecoin Blockchain Bootstrap Updater

This repository contains helper scripts to create a bootstrapped
[Spectrecoin](https://spectreproject.io/) blockchain, based on the wallet  
version running on the machine, where the helper scripts where executed.

The created archive will contains the following:
* `blk0001.dat` - Main blockchain data file
* `txleveldb/*` - Folder txleveldb with the transaction database

## Requirements
* Spectrecoin wallet already running and in sync
* Used account with sudo permission to stop and start the wallet

