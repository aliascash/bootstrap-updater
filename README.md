# Alias Blockchain Bootstrap Updater

## Licensing

- SPDX-FileCopyrightText: © 2020 Alias Developers
- SPDX-FileCopyrightText: © 2016 SpectreCoin Developers

SPDX-License-Identifier: MIT

## Content

This repository contains helper scripts to create a bootstrapped
[Alias](https://alias.cash/) blockchain, based on the wallet
version running on the machine, where the helper scripts where executed.

The created archive will contains the following:
* `blk0001.dat` - Main blockchain data file
* `txleveldb/*` - Folder txleveldb with the transaction database

Additionally a split archive will be created, where each chunk is 50M in
size. This is used for bootstrapping on mobile phones, where the connection
might drop. With this approach only the file with the connection drop
needs to be downloaded again.

## Requirements
* Alias wallet already running and in sync
* Used account with sudo permission to stop and start the wallet

