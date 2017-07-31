# libcld

[![Documentation Status](https://readthedocs.org/projects/libcld/badge/?version=latest)](https://readthedocs.org/projects/libcld/?badge=latest)

[![Build Status](https://travis-ci.org/geoffjay/libcld.svg?branch=master)](https://travis-ci.org/geoffjay/libcld)

A library for creating custom data acquisition systems. The end goal is
something that allows you to create custom systems that can use either or both
polling and asynchronous acquisitions. Data received can be logged using flat
CSV files or a database (currently SQLite3 only). This is still a complete work
in progress.

## Install

```bash
meson _build
ninja -C _build
sudo ninja -C _build install
```
