============
Installation
============

Requirements
============

* Linux is the only tested OS
* The Vala compiler
* Libraries:

  * modbus
  * comedi
  * gee
  * libxml
  * json-glib
  * matheval
  * gsl
  * sqlite3

Building from Source
====================

General Instructions
--------------------

The library is hosted at GitHub, to clone the repository:

    git clone https://github.com/geoffjay/libcld.git

Install all dependencies. Using Fedora this can be done using yum::

    yum install -y libmodbus-devel comedilib-devel libgee-devel libxml2-devel \
    json-glib-devel libmatheval-devel gsl-devel libsqlite3x-devel

At this time you'll probably want to use the ``develop`` branch, but that will
hopefully not be the case for much longer. Next generate all the necessary files
to build and compile:

    ./autogen.sh --with-comedi --with-modbus
    make

You can now install libcld system-wide by:

    sudo make install

If you get an error stating something like ``libcld.so`` not found, you will
probably need to run ``ldconfig`` (as root).
