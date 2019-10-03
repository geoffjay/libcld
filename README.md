# Cld

[![Documentation Status](https://readthedocs.org/projects/libcld/badge/?version=latest)](https://readthedocs.org/projects/libcld/?badge=latest)

[![Build Status](https://travis-ci.org/geoffjay/libcld.svg?branch=master)](https://travis-ci.org/geoffjay/libcld)

A library for creating custom data acquisition systems. The end goal is
something that allows you to create custom systems that can use either or both
polling and asynchronous acquisitions. Data received can be logged using flat
CSV files or a database (currently SQLite3 only). This is still a complete work
in progress.

## Authors

Geoff Johnson <geoff.jay@gmail.com>
Stephen Roy <sroy1966@gmail.com>

## Valadoc

```bash
valadoc --directory=cld-1.0           \
        --verbose --pkg gee-0.8       \
        --pkg libxml-2.0              \
        --pkg glib-2.0                \
        --pkg gio-2.0                 \
        --pkg comedi                  \
        --pkg gsl                     \
        --pkg linux                   \
        --pkg posix                   \
        --pkg json-glib-1.0           \
        --pkg libmatheval             \
        --vapidir=./vapi src/*.vala
```

## Install

### Fedora 30 from source
```bash
# Install dependencies
sudo dnf install -y git                         \
                    meson                       \
                    ninja-build                 \
                    gnome-common                \
                    intltool                    \
                    gcc                         \
                    vala                        \
                    libgee-devel                \
                    json-glib-devel             \
                    gsl-devel                   \
                    libxml2-devel               \
                    libmatheval-devel           \
                    comedilib-devel

git clone git@github.com:geoffjay/libcld.git
cd libcld
meson _build
ninja -C _build
sudo ninja -C _build install
```

### Debian 10
```bash
# Install dependencies
sudo apt install  -y git        \
                     meson      \
                     gcc        \
                     valac
                     libgee-0.8-dev \
                     libglib2.0-dev \
                     libgirepository1.0-dev \
                     libxml2-dev \
                     libjson-glib-dev \
                     libgsl-dev \
                     libmatheval-dev \
                     libcomedi-dev

git clone git@github.com:geoffjay/libcld.git
cd libcld
meson _build
sudo ninja -C _build install
```

### Debian 10 (packagecloud)

Alternatively, it can be installed as a Debian package which is hosted on packagecloud.

```bash
# set the packagecloud token environment variable

sudo apt update
sudo apt install --no-install-recommends -qq -y curl ca-certificates
curl -s https://packagecloud.io/install/repositories/coanda/public/script.deb.sh | sudo bash

# devel
apt install libcld-1.0-dev -y

# library
RUN apt install libcld-1.0-0 -y
```
