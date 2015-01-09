dnl Process this file with autoconf to produce a configure script
AC_PREREQ([2.64])
AC_INIT([libcld], m4_esyscmd([build-aux/git-version-gen .tarball-version]))

AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_SRCDIR([cld/cld.vala])
AC_CONFIG_HEADER([config.h])
AC_CONFIG_MACRO_DIR([m4])

m4_define([package_major_version], [0])
m4_define([package_minor_version], [3])
m4_define([package_micro_version], [0])
m4_define([package_version], [package_major_version.package_minor_version.package_micro_version])

dnl Make sure the right substitution is done
[LIBCLD_MAJOR_VERSION]=package_major_version
[LIBCLD_MINOR_VERSION]=package_minor_version
[LIBCLD_MICRO_VERSION]=package_micro_version
AC_SUBST([LIBCLD_MAJOR_VERSION])
AC_SUBST([LIBCLD_MINOR_VERSION])
AC_SUBST([LIBCLD_MICRO_VERSION])

dnl For libtool current:revision:age where age <= current
LIBCLD_LT_VERSION=0:3:0
AC_SUBST(LIBCLD_LT_VERSION)

dnl Initialize automake
AM_INIT_AUTOMAKE([1.11.1 foreign no-dist-gzip dist-xz -Wno-portability])
AM_MAINTAINER_MODE([enable])

dnl Initialize libtool
LT_PREREQ([2.2.6])
LT_INIT([dlopen disable-static])

GOBJECT_INTROSPECTION_REQUIRE([0.9.0])

dnl Enable silent rules if available
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

PACKAGE_SUFFIX=-0.3

AC_SUBST(PACKAGE_SUFFIX)
AC_DEFINE_UNQUOTED(PACKAGE_SUFFIX, "$PACKAGE_SUFFIX", [Define to the suffix of this package])

AC_SUBST(pkgdatadir, [${datadir}/cld${PACKAGE_SUFFIX}])

dnl Programs
AC_PROG_CC
AM_PROG_CC_C_O
AC_DISABLE_STATIC
AC_PROG_LIBTOOL

AM_PROG_VALAC([0.14.0])
AC_SUBST(VALAC)

dnl Library checks
VALA_PACKAGES=""
VALAFLAGS="--enable-deprecated --target-glib=2.38 $VALAFLAGS"

PKG_CHECK_MODULES([GLIB], [glib-2.0 gobject-2.0 gthread-2.0],,
    [AC_MSG_ERROR(glib-2.12 is required)])

PKG_CHECK_MODULES([GEE], [gee-0.8],
    [VALA_PACKAGES="$VALA_PACKAGES --pkg gee-0.8"],
	[AC_MSG_ERROR(gee-0.8 is required)])

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
	[use_modbus=yes])
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
	[use_comedi=yes])
AC_MSG_RESULT(checking whether Comedi drivers were selected... $use_comedi)

if test "x$use_comedi" != "xno" ; then
	PKG_CHECK_MODULES([COMEDI], [comedi],
        [VALA_PACKAGES="$VALA_PACKAGES --pkg comedi"],
		[AC_MSG_ERROR([Comedi is required])])
	AC_DEFINE(USE_COMEDI, [1], ["Comedi Drivers"])
fi

AC_SUBST(VALA_PACKAGES)
AC_SUBST(VALAFLAGS)

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

dnl Debugging
AC_ARG_ENABLE(debug,
	AS_HELP_STRING([--enable-debug],
		[Enable debugging (default: disabled)]),,
	enable_debug=no)

if test "x$enable_debug" = xyes; then
	AM_CFLAGS="$AM_CFLAGS -DDEBUG"
fi

dnl Documentation
AC_ARG_ENABLE(doc,
	AS_HELP_STRING([--enable-doc],
		[Enable documentation generation]), enable_doc=$enableval,
	enable_doc=no)
AM_CONDITIONAL(ENABLE_DOC, test x$enable_doc = xyes)

AS_IF([test "x$enable_doc" != xno],
	[AC_PATH_PROG(VALADOC, valadoc, :)
	 AC_SUBST(VALADOC)
	 AS_IF([test "$VALADOC" = :],
		[AC_MSG_ERROR([valadoc not found])])])

dnl Examples
AC_ARG_ENABLE(examples,
	AS_HELP_STRING([--enable-examples],
		[Enable example programs generation]), enable_examples=$enableval,
	enable_examples=no)
AM_CONDITIONAL(ENABLE_EXAMPLES, test x$enable_examples = xyes)

AC_OUTPUT([Makefile
           cld-0.3.pc
           cld/Makefile
           docs/Makefile
           data/Makefile
           data/device/Makefile
           examples/Makefile
           tests/Makefile
           vapi/Makefile])

dnl Generate build report
AC_MSG_NOTICE([

    $PACKAGE $VERSION
    =============================================================

    CFLAGS:                         ${CFLAGS}
    VALAFLAGS:                      ${VALAFLAGS}

    ... more to come ...

    $PACKAGE will be installed in $libdir
])
