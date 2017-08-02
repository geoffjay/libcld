#!/usr/bin/env bash

set -e
set -o pipefail

mesontest -C build --wrapper valgrind --print-errorlogs -v
DESTDIR=$(mktemp -d) ninja -C build -v install
