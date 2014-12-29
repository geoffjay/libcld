#!/bin/bash

#
# Comedi setup that I end up doing manually over and over.
#

#
# Basic script usage.
#
function usage()
{
  echo $"Usage: $0 {deps|dkms|udev|entest|addtest}"
  exit 1
}

#
# TODO: Implement/test more than just Fedora/RedHat based distributions.
#
function install_deps()
{
  if [ -f /etc/redhat-release ]; then
    yum -y install automake autoconf libtool git dkms \
      kernel-devel kernel-headers comedilib comedilib-devel
  fi
}

#
# DKMS steps.
#
# FIXME: Library version should be pulled from the project files.
#
function build_dkms()
{
  cd /usr/src/
  git clone git://comedi.org/git/comedi/comedi.git comedi-0.7.76+20120626git-1.nodist
  dkms add -m comedi -v 0.7.76+20120626git-1.nodist
  cd comedi-0.7.76+20120626git-1.nodist && ./autogen.sh && cd ..
  dkms build -m comedi -v 0.7.76+20120626git-1.nodist
  dkms install -m comedi -v 0.7.76+20120626git-1.nodist
}

#
# Enable the Comedi test devices temporarily.
#
function enable_test()
{
  modprobe comedi comedi_num_legacy_minors=4
  modprobe comedi_test
  comedi_config /dev/comedi0 comedi_test
}

#
# Permanently configure the Comedi test devices.
#
# TODO: Implement/test more than just Fedora/RedHat based distributions.
#
function add_test()
{
  cat <<- EOF > /etc/sysconfig/modules/comedi.modules
#!/bin/sh

if [ ! -c /dev/comedi0 ] ; then
  exec /sbin/modprobe comedi comedi_num_legacy_minors=4 >/dev/null 2>&1
  exec /sbin/modprobe comedi_test
  exec /usr/sbin/comedi_config /dev/comedi0 comedi_test
fi
EOF
}

# Everything here needs to be done as root
if [ $EUID -ne 0 ]; then
    echo "This script must be run as root, exiting." 1>&2
    exit 1
else
  if [ $# -gt 0 ]; then
    usage
  else
    case $1 in
      deps)
        install_deps
        ;;
      dkms)
        build_dkms
        ;;
      udev)
        udev_rule
        ;;
      entest)
        enable_test
        ;;
      addtest)
        add_test
        ;;
      *)
        usage
        ;;
    esac
  fi
fi
