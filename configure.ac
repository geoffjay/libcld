# configure.ac
# process this file with autoconf to produce a configure script

AC_INIT([libcld], [0.2.2], [geoff.jay@gmail.com], [libcld])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADER(config.h)
AC_CONFIG_MACRO_DIR(m4)
AM_INIT_AUTOMAKE(dist-bzip2)
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

m4_define([package_major_version], [0])
m4_define([package_minor_version], [2])
m4_define([package_micro_version], [2])
m4_define([package_version], [package_major_version.package_minor_version.package_micro_version])

# Make sure the right substitution is done
[LIBCLD_MAJOR_VERSION]=package_major_version
[LIBCLD_MINOR_VERSION]=package_minor_version
[LIBCLD_MICRO_VERSION]=package_micro_version
AC_SUBST([LIBCLD_MAJOR_VERSION])
AC_SUBST([LIBCLD_MINOR_VERSION])
AC_SUBST([LIBCLD_MICRO_VERSION])

dnl For libtool current:revision:age where age <= current
LIBCLD_LT_VERSION=0:2:0
AC_SUBST(LIBCLD_LT_VERSION)

# checks for programs
AC_PROG_CC
AC_PROG_CPP
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
dnl AM_PROG_LIBTOOL
AM_PROG_VALAC([0.7.0])
AC_PROG_LIBTOOL

LIBCLD_VERSION="0:1:0"
AC_SUBST(LIBCLD_VERSION)

AC_SUBST(VALAFLAGS)
AC_SUBST(CFLAGS)
AC_SUBST(CPPFLAGS)
AC_SUBST(LDFLAGS)

# checks for libraries
pkg_modules="glib-2.0 >= 2.0.0 gee-1.0 >= 0.1.0 libxml-2.0 >= 2.0.0"
CLD_PACKAGES="--pkg glib-2.0 --pkg gee-1.0 --pkg libxml-2.0"
PKG_CHECK_MODULES(CLD, [$pkg_modules])
AC_SUBST(CLD_CFLAGS)
AC_SUBST(CLD_LIBS)
AC_SUBST(CLD_PACKAGES)

# checks for header files
AC_HEADER_STDC
AC_CHECK_HEADERS(   \
    stdlib.h          \
    time.h            \
    string.h          \
    unistd.h          \
    glib.h
)

# checks for typedefs, structures, and compiler characteristics
AC_C_CONST
AC_TYPE_SIZE_T

GETTEXT_PACKAGE=libcld
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [Gettext Package])
AC_SUBST(GETTEXT_PACKAGE)
AM_GNU_GETTEXT_VERSION([1.11])
AM_GLIB_GNU_GETTEXT

AC_CONFIG_FILES([
	Makefile
	cld-0.2.pc
	po/Makefile.in
	cld/Makefile
	vapi/Makefile
])
AC_OUTPUT
