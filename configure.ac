dnl ---------------------------------------------------------------------------
dnl configure.ac
dnl process this file with autoconf to produce a configure script
dnl ---------------------------------------------------------------------------

AC_INIT([libcld], [0.2.0], [geoff.jay@gmail.com], [libcld])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADER(config.h)
AC_CONFIG_MACRO_DIR(m4)
AM_INIT_AUTOMAKE(dist-bzip2)
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

LIBCLD_LT_VERSION="0:2:0"
AC_SUBST(LIBCLD_LT_VERSION)

dnl ---------------------------------------------------------------------------
dnl Programs
dnl ---------------------------------------------------------------------------
AC_PROG_CC
AM_PROG_CC_C_O
AC_DISABLE_STATIC
AC_PROG_LIBTOOL
IT_PROG_INTLTOOL([0.35])

AC_PATH_PROG(VALAC, valac, valac)
AC_SUBST(VALAC)
AC_SUBST(VALAFLAGS)

dnl ---------------------------------------------------------------------------
dnl Mandatory Libraries
dnl ---------------------------------------------------------------------------
GLIB_REQUIRED=2.12.0
PKG_CHECK_MODULES(GLIB, glib-2.0 >= $GLIB_REQUIRED gobject-2.0 >= $GLIB_REQUIRED gthread-2.0 >= $GLIB_REQUIRED,,
	AC_MSG_ERROR(glib-2.2 is required))
AC_SUBST(GLIB_CFLAGS)
AC_SUBST(GLIB_LIBS)

PKG_CHECK_MODULES(GEE, gee-1.0,,
	AC_MSG_ERROR(gee-1.0 is required))
AC_SUBST(GEE_CFLAGS)
AC_SUBST(GEE_LIBS)

PKG_CHECK_MODULES(XML, libxml-2.0,,
	AC_MSG_ERROR(libxml2 is required))
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

dnl Debugging
AC_ARG_ENABLE(debug,
	AS_HELP_STRING([--enable-debug],
		[enable debugging (default: disabled)]),,
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

dnl ---------------------------------------------------------------------------
dnl Checks for typedefs, structures, and compiler characteristics
dnl ---------------------------------------------------------------------------
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
	tests/Makefile
	vapi/Makefile
])
AC_OUTPUT
