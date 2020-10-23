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

## Requirements
* Alias wallet already running and in sync
* Used account with sudo permission to stop and start the wallet

