include $(top_srcdir)/Makefile.decl

NULL = 

BUILT_SOURCES = cld.vala.stamp

lib_LTLIBRARIES = \
	libcld.la \
	$(NULL)

libcld_ladir = $(includedir)/cld-0.1

INCLUDES = $(CLD_CFLAGS)

library_includedir = $(includedir)/cld-0.1/cld

library_include_HEADERS = \
	common.h \
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

cldincludedir = $(includedir)/cld-0.1

cldinclude_HEADERS = \
	cld.h \
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
	$(CLD_LIBS) \
	$(NULL)

#libcld_la_LDFLAGS = 

vapidir = $(datadir)/vala/vapi

dist_vapi_DATA = \
	cld-0.1.vapi \
	$(NULL)

girdir = $(datadir)/gir-1.0

dist_gir_DATA = \
	Cld-0.1.gir \
	$(NULL)

EXTRA_DIST += $(libcld_la_VALASOURCES) cld-0.1.vapi Cld-0.1.gir cld.vala.stamp
