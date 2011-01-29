#!/bin/bash
# autogen.sh
# - generate all make files, etc.

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

DIE=0

if [ `test -f $srcdir/configure.ac` ]; then
    echo -en "**Error**: "$srcdir" does not look like the top-level"
    echo -en " package directory\n"
    exit 1
fi

# check that the necessary applications are installed
##

# ... nothing yet

# if any of the checks failed exit
if [ $DIE -eq 1 ]; then
    exit 1
fi

libtoolize --force \
&& aclocal \
&& autoheader \
&& automake --gnu --add-missing \
&& autoconf
