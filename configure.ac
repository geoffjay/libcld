dnl ---------------------------------------------------------------------------
dnl configure.ac
dnl process this file with autoconf to produce a configure script
dnl ---------------------------------------------------------------------------

AC_INIT([libcld], [0.2.0], [geoff.jay@gmail.com], [libcld])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADER(config.h)
AC_CONFIG_MACRO_DIR(m4)
AM_INIT_AUTOMAKE(cld, 0.2.0)

LIBCLD_VERSION="0:2:0"
AC_SUBST(LIBCLD_LT_VERSION)

dnl ---------------------------------------------------------------------------
dnl Programs
dnl ---------------------------------------------------------------------------
AC_PROG_CC
AM_PROG_CC_C_O
dnl AC_PROG_CPP
dnl AC_PROG_INSTALL
dnl AC_PROG_LN_S
dnl AC_PROG_MAKE_SET
AC_DISABLE_STATIC
AC_PROG_LIBTOOL
IT_PROG_INTLTOOL([0.35])

AM_PROG_VALAC([0.7.0])
AC_SUBST(VALAC)

dnl ---------------------------------------------------------------------------
dnl Declare Variables
dnl ---------------------------------------------------------------------------
AC_SUBST(VALAFLAGS,"")
AC_SUBST(CLD_CFLAGS,"")
AC_SUBST(CLD_LIBS,"")
dnl AC_SUBST(CLD_PACKAGES,"")

dnl ---------------------------------------------------------------------------
dnl Mandatory Libraries
dnl ---------------------------------------------------------------------------
PKG_CHECK_MODULES([GLIB], [glib-2.0 >= 2.2 gobject-2.0 >= 2.2 gthread-2.0 >= 2.2],,
	[AC_MSG_ERROR([glib-2.2 is required])])
AC_SUBST(GLIB_CFLAGS)
AC_SUBST(GLIB_LIBS)

PKG_CHECK_MODULES([GTK], [gtk+-2.0 > 2.2.0],,
	[AC_MSG_ERROR([gtk-2.2 is required])])
AC_SUBST(GTK_CFLAGS)
AC_SUBST(GTK_LIBS)

PKG_CHECK_MODULES([GEE], [gee-1.0],,
	[AC_MSG_ERROR([gee-1.0 is required])])
AC_SUBST(GEE_CFLAGS)
AC_SUBST(GEE_LIBS)

PKG_CHECK_MODULES([XML], [libxml-2.0],,
	[AC_MSG_ERROR([libxml2 is required])])
AC_SUBST(XML_CFLAGS)
AC_SUBST(XML_LIBS)

GOBJECT_INTROSPECTION_CHECK([0.9.0])

dnl ---------------------------------------------------------------------------
dnl libc Features
dnl ---------------------------------------------------------------------------
AC_HEADER_STDC
AC_CHECK_HEADERS( \
	stdlib.h \
	time.h \
	string.h \
	unistd.h \
	glib.h
)

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
AC_ARG_ENABLE(debug,
	AS_HELP_STRING([--enable-debug],
		[enable debugging (default: disabled)]),,
	enable_debug=no)

if test "x$enable_debug" = xyes; then
	AM_CFLAGS="$AM_CFLAGS -DDEBUG"
fi

AC_ARG_ENABLE(test,
	AS_HELP_STRING([--enable-test],
		[build the test programs (default: disabled)]),,
	enable_test=no)

if test "x$enable_test" = xyes; then
	CLD_CFLAGS="$CLD_CFLAGS -Icld/"
fi

AM_CONDITIONAL(ENABLE_TEST, test "x$enable_test" = xyes)

dnl ---------------------------------------------------------------------------
dnl Checks for typedefs, structures, and compiler characteristics
dnl ---------------------------------------------------------------------------
AC_C_CONST
AC_TYPE_SIZE_T

AC_CONFIG_FILES([
	Makefile
	cld-0.2.pc
	cld/Makefile
	vapi/Makefile
])
AC_OUTPUT
