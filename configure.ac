# configure.ac
# process this file with autoconf to produce a configure script

AC_INIT([libcld], [0.2.3], [geoff.jay@gmail.com], [libcld])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADER(config.h)
AC_CONFIG_MACRO_DIR(m4)
AM_INIT_AUTOMAKE(dist-bzip2)
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

m4_define([package_major_version], [0])
m4_define([package_minor_version], [2])
m4_define([package_micro_version], [3])
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

AM_PROG_VALAC([0.14.0])
AC_SUBST(VALAC)

dnl ---------------------------------------------------------------------------
dnl Mandatory Libraries
dnl ---------------------------------------------------------------------------

VALA_PACKAGES=""

GLIB_REQUIRED=2.32.0
PKG_CHECK_MODULES([GLIB], [glib-2.0 >= $GLIB_REQUIRED gobject-2.0 >= $GLIB_REQUIRED gthread-2.0 >= $GLIB_REQUIRED],
	[AC_DEFINE(HAVE_GLIB232, [], [GLib 2.32 available])],
	[PKG_CHECK_MODULES([GLIB], [glib-2.0 gobject-2.0 gthread-2.0],,
		[AC_MSG_ERROR(glib-2.12 is required)])
	])

PKG_CHECK_MODULES([GEE], [gee-1.0],
    [VALA_PACKAGES="$VALA_PACKAGES --pkg gee-1.0"],
	[AC_MSG_ERROR(gee-1.0 is required)])

PKG_CHECK_MODULES([GIO], [gio-2.0],
    [VALA_PACKAGES="$VALA_PACKAGES --pkg gio-2.0"],
	[AC_MSG_ERROR(gio-2.0 is required)])

PKG_CHECK_MODULES([XML], [libxml-2.0],
    [VALA_PACKAGES="$VALA_PACKAGES --pkg libxml-2.0"],
	[AC_MSG_ERROR(libxml-2.0 is required)])

PKG_CHECK_MODULES([JSON], [json-glib-1.0],
    [VALA_PACKAGES="$VALA_PACKAGES --pkg json-glib-1.0"],
	[AC_MSG_ERROR(json-glib-1.0 is required)])

PKG_CHECK_MODULES([MATH], libmatheval,
    [VALA_PACKAGES="$VALA_PACKAGES --pkg libmatheval"],
	[AC_MSG_ERROR(libmatheval is required)])

PKG_CHECK_MODULES([GSL], gsl,
    [VALA_PACKAGES="$VALA_PACKAGES --pkg gsl"],
	[AC_MSG_ERROR(gsl is required)])

PKG_CHECK_MODULES([SQLITE], sqlite3,
    [VALA_PACKAGES="$VALA_PACKAGES --pkg sqlite3"],
	[AC_MSG_ERROR(sqlite3 is required)])

dnl libmodbus support
AC_ARG_WITH(modbus,
[  --with-modbus         Use Modbus library],
	[use_modbus=$withval],
	[use_modbus=no])
AC_MSG_RESULT(checking whether libmodbus support was selected... $use_modbus)

if test "x$use_modbus" != "xno" ; then
	PKG_CHECK_MODULES([MODBUS], [libmodbus],
        [VALA_PACKAGES="$VALA_PACKAGES --pkg libmodbus"],
		[AC_MSG_ERROR([libmodbus is required])])
	AC_DEFINE(USE_MODBUS, [1], ["Modbus Library"])
fi

dnl Comedi
AC_ARG_WITH(comedi,
[  --with-comedi         Use Comedi drivers],
	[use_comedi=$withval],
	[use_comedi=no])
AC_MSG_RESULT(checking whether Comedi drivers were selected... $use_comedi)

if test "x$use_comedi" != "xno" ; then
	PKG_CHECK_MODULES([COMEDI], [comedi],
        [VALA_PACKAGES="$VALA_PACKAGES --pkg comedi"],
		[AC_MSG_ERROR([Comedi is required])])
	AC_DEFINE(USE_COMEDI, [1], ["Comedi Drivers"])
fi

AC_SUBST(VALA_PACKAGES)

dnl ---------------------------------------------------------------------------
dnl CFLAGS
dnl ---------------------------------------------------------------------------
dnl if test x$GCC = xyes
dnl then
dnl CLD_CHECK_FLAG([-g])
dnl CLD_CHECK_FLAG([-Wall])
dnl CLD_CHECK_FLAG([-Wextra])
dnl CLD_CHECK_FLAG([-Wno-deprecated-declarations])
dnl CLD_CHECK_FLAG([-Wmissing-prototypes])
dnl CLD_CHECK_FLAG([-Wshadow])
dnl CLD_CHECK_FLAG([-Wpointer-arith])
dnl CLD_CHECK_FLAG([-Wstrict-prototypes])
dnl CLD_CHECK_FLAG([-Wcast-qual])
dnl CLD_CHECK_FLAG([-Wwrite-strings])
dnl CLD_CHECK_FLAG([-pedantic])
dnl fi

dnl ---------------------------------------------------------------------------
dnl Build Options
dnl ---------------------------------------------------------------------------

dnl Debugging
AC_ARG_ENABLE(debug,
	AS_HELP_STRING([--enable-debug],
		[Enable debugging (default: disabled)]),,
	enable_debug=no)

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
