include $(top_srcdir)/Makefile.decl

BUILT_SOURCES = cld.vala.stamp

lib_LTLIBRARIES = \
	libcld.la \
	$(NULL)

libcld_la_VALASOURCES = \
	calibration.vala \
	channel.vala \
	cld.vala \
	control.vala \
	daq.vala \
	device.vala \
	log.vala \
	pid.vala \
	xml.vala \
	$(NULL)

libcld_la_SOURCES = \
	cld.vala.stamp \
	$(libcld_la_VALASOURCES:.vala=.c) \
	$(NULL)

INCLUDES = \
	-include common.h \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DPKGDATADIR=\""$(pkgdatadir)"\" \
	-DPKGLIBDIR=\""$(pkglibdir)"\" \
	$(NULL)

libcld_la_VALAFLAGS = \
	-H cld.h --vapi cld-0.2.vapi \
	-h cld-internals.h -g -X -DDEBUG \
	--internal-vapi cld-internals-0.2.vapi \
	--library cld-0.2 --gir Cld-0.2.gir \
	--vapidir=$(srcdir)/../vapi --pkg config \
	--pkg glib-2.0 --pkg gee-1.0 --pkg libxml-2.0 \
	$(VALAFLAGS) \
	$(NULL)

libcld_la_CPPFLAGS = \
	$(GLIB_CFLAGS) \
	$(GTK_CFLAGS) \
	$(GEE_CFLAGS) \
	$(XML_CFLAGS) \
	$(NULL)

libcld_la_LIBADD = \
	$(GLIB_LIBS) \
	$(GTK_LIBS) \
	$(GEE_LIBS) \
	$(XML_LIBS) \
	$(NULL)

libcld_la_LDFLAGS = \
	$(NULL)

cldincludedir = $(includedir)/cld-0.1

cldinclude_HEADERS = \
	cld.h \
	$(NULL)

library_includedir = $(includedir)/cld-0.1/cld

library_include_HEADERS = \
	common.h \
	$(NULL)

vapidir = $(datadir)/vala/vapi

dist_vapi_DATA = \
	cld-0.1.vapi \
	$(NULL)

if HAVE_INTROSPECTION
girdir = @INTROSPECTION_GIRDIR@

gir_DATA = \
	Cld-0.1.gir \
	$(NULL)

typelibdir = @INTROSPECTION_TYPELIBDIR@
typelib_DATA = \
	Cld-0.1.typelib \
	$(NULL)

Cld-0.1.typelib: Cld-0.1.gir
	@INTROSPECTION_COMPILER@ --shared-library=libcld -o $@ $^
endif

Cld-0.1.gir cld-internals-0.1.vapi cld-0.1.vapi: libcld.la

CLEANFILES = \
	cld-0.1.vapi \
	cld-internals-0.1.vapi \
	Cld-0.1.typelib \
	Cld-0.1.gir \
	$(NULL)
