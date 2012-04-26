include $(top_srcdir)/Makefile.decl

lib_LTLIBRARIES = \
	libcld.la \
	$(NULL)

libcld_la_SOURCES = \
	builder.vala \
	calibration.vala \
	channel.vala \
	cld.vala \
	control.vala \
	daq.vala \
	device.vala \
	interfaces.vala \
	log.vala \
	pid.vala \
	xml.vala \
	$(NULL)

INCLUDES = \
	-include common.h \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DPKGDATADIR=\""$(pkgdatadir)"\" \
	-DPKGLIBDIR=\""$(pkglibdir)"\" \
	$(NULL)

AM_VALAFLAGS = \
	-H cld.h --vapi cld-0.1.vapi \
	-h cld-internals.h -g \
	--internal-vapi cld-internals-0.1.vapi \
	--library cld-0.1 --gir Cld-0.1.gir \
	--vapidir=$(srcdir)/../vapi --pkg config \
	--pkg glib-2.0 --pkg gee-1.0 --pkg libxml-2.0 \
	$(VALAFLAGS) \
	$(NULL)

cld-0.1.vapi cld.vala.stamp: $(libcld_la_VALASOURCES)
	$(VALAC) -C $(AM_VALAFLAGS) $^
	touch $@

libcld_la_LIBADD = \
	$(GLIB_LIBS) \
	$(GEE_LIBS) \
	$(XML_LIBS) \
	$(NULL)

libcld_la_LDFLAGS = \
	$(NULL)

cldincludedir = $(includedir)/cld-0.2

cldinclude_HEADERS = \
	cld.h \
	$(NULL)

library_includedir = $(includedir)/cld-0.2/cld

library_include_HEADERS = \
	common.h \
	$(NULL)

vapidir = $(datadir)/vala/vapi

dist_vapi_DATA = \
	cld-0.2.vapi \
	$(NULL)

girdir = $(datadir)/gir-1.0

gir_DATA = \
	Cld-0.2.gir \
	$(NULL)

typelibdir = @INTROSPECTION_TYPELIBDIR@
typelib_DATA = \
	Cld-0.2.typelib \
	$(NULL)

Cld-0.2.typelib: Cld-0.2.gir
	@INTROSPECTION_COMPILER@ --shared-library=libcld -o $@ $^
endif

Cld-0.2.gir cld-internals-0.2.vapi cld-0.2.vapi: libcld.la

CLEANFILES = \
	cld-0.2.vapi \
	cld-internals-0.2.vapi \
	Cld-0.2.typelib \
	Cld-0.2.gir \
	$(NULL)
