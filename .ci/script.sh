#!/usr/bin/env bash

set -e
set -o pipefail

PKG_CONFIG_PATH=./deps/ ./autogen.sh
make
