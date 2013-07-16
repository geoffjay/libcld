dnl ---------------------------------------------------------------------------
dnl configure.ac
dnl process this file with autoconf to produce a configure script
dnl ---------------------------------------------------------------------------

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

dnl ---------------------------------------------------------------------------
dnl Programs
dnl ---------------------------------------------------------------------------
AC_PROG_CC
AM_PROG_CC_C_O
AC_DISABLE_STATIC
AC_PROG_LIBTOOL

AM_PROG_VALAC([0.14.0])
AC_SUBST(VALAC)
AC_SUBST(VALAFLAGS)

dnl ---------------------------------------------------------------------------
dnl Mandatory Libraries
dnl ---------------------------------------------------------------------------
GLIB_REQUIRED=2.32.0
PKG_CHECK_MODULES([GLIB], glib-2.0 >= $GLIB_REQUIRED gobject-2.0 >= $GLIB_REQUIRED gthread-2.0 >= $GLIB_REQUIRED,
	[AC_DEFINE(HAVE_GLIB232, [], [GLib 2.32 available])],
	[PKG_CHECK_MODULES([GLIB], [glib-2.0 gobject-2.0 gthread-2.0],,
		[AC_MSG_ERROR(glib-2.12 is required)])
	])
AC_SUBST(GLIB_CFLAGS)
AC_SUBST(GLIB_LIBS)

PKG_CHECK_MODULES([GEE], gee-0.8,,
	AC_MSG_ERROR(gee-0.8 is required))
AC_SUBST(GEE_CFLAGS)
AC_SUBST(GEE_LIBS)

PKG_CHECK_MODULES([GIO], gio-2.0,,
	AC_MSG_ERROR(gio-2.0 is required))
AC_SUBST(GIO_CFLAGS)
AC_SUBST(GIO_LIBS)

PKG_CHECK_MODULES([XML], libxml-2.0,,
	AC_MSG_ERROR(libxml2 is required))
AC_SUBST(XML_CFLAGS)
AC_SUBST(XML_LIBS)

PKG_CHECK_MODULES([JSON], json-glib-1.0,,
	AC_MSG_ERROR(json-glib-1.0 is required))
AC_SUBST(JSON_CFLAGS)
AC_SUBST(JSON_LIBS)

dnl libmodbus support
AC_ARG_WITH(modbus,
[  --with-modbus         Use Modbus library],
	[use_modbus=$withval],
	[use_modbus=no])
AC_MSG_RESULT(checking whether libmodbus support was selected... $use_modbus)

if test "x$use_modbus" != "xno" ; then
	PKG_CHECK_MODULES([MODBUS], [libmodbus],,
		[AC_MSG_ERROR([libmodbus is required])])
	AC_DEFINE(USE_MODBUS, [1], ["Modbus Library"])
fi

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

dnl ---------------------------------------------------------------------------
dnl Checks for typedefs, structures, and compiler characteristics
dnl ---------------------------------------------------------------------------
dnl AC_C_CONST
dnl AC_TYPE_SIZE_T

GOBJECT_INTROSPECTION_CHECK([0.9.0])

AC_OUTPUT([Makefile
           cld-0.2.pc
           cld/Makefile
           doc/Makefile
           examples/Makefile
           tests/Makefile
           vapi/Makefile])
