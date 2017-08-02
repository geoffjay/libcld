#!/usr/bin/env bash

set -e
set -o pipefail

mesontest -C _build --wrapper valgrind --print-errorlogs -v
DESTDIR=$(mktemp -d) ninja -C _build -v install
