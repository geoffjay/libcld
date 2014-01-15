include $(top_srcdir)/Makefile.decl

lib_LTLIBRARIES = \
	libcld-0.2.la \
	$(NULL)

#if USE_COMEDI
COMEDI_SOURCES = \
	comedidevice.vala \
	comeditask.vala \
	$(NULL)
#endif

#if USE_MODBUS
MODBUS_SOURCES = \
	modbusport.vala \
	$(NULL)
#endif

libcld_0_2_la_SOURCES = \
	abstractchannel.vala \
	abstractcontainer.vala \
	abstractdevice.vala \
	abstractfilter.vala \
	abstractmodule.vala \
	abstractobject.vala \
	abstractport.vala \
	abstracttask.vala \
	aichannel.vala \
	aochannel.vala \
	brabendermodule.vala\
	builder.vala \
	calibration.vala \
	channel.vala \
	cld.vala \
	coefficient.vala \
	container.vala \
	control.vala \
	daq.vala \
	device.vala \
	dichannel.vala \
	dochannel.vala \
	filter.vala \
	heidolphmodule.vala \
	licormodule.vala \
	log.vala \
	module.vala \
	object.vala \
	parkermodule.vala \
	pid.vala \
	port.vala \
	serialport.vala \
	socketport.vala \
	task.vala \
	vchannel.vala \
	velmexmodule.vala \
	xmlconfig.vala \
	$(COMEDI_SOURCES) \
	$(MODBUS_SOURCES) \
	$(NULL)

INCLUDES = \
	-include common.h \
	-DPKGDATADIR=\""$(pkgdatadir)"\" \
	-DPKGLIBDIR=\""$(pkglibdir)"\" \
	$(NULL)

libcld_0_2_la_VALAFLAGS = \
	-H cld.h --vapi cld-0.2.vapi \
	-h cld-internals.h -g -X -DDEBUG \
	--internal-vapi cld-internals-0.2.vapi \
	--library cld-0.2 --gir Cld-0.2.gir \
	--vapidir=$(srcdir)/../vapi --pkg config \
	@VALA_PACKAGES@ --pkg linux --pkg posix \
	$(NULL)

libcld_0_2_la_CPPFLAGS = \
	$(GLIB_CFLAGS) \
	$(GEE_CFLAGS) \
	$(GIO_CFLAGS) \
	$(XML_CFLAGS) \
	$(JSON_CFLAGS) \
	$(MODBUS_CFLAGS) \
	$(COMEDI_CFLAGS) \
	$(NULL)

libcld_0_2_la_LIBADD = \
	$(GLIB_LIBS) \
	$(GEE_LIBS) \
	$(GIO_LIBS) \
	$(XML_LIBS) \
	$(JSON_LIBS) \
	$(MODBUS_LIBS) \
	$(COMEDI_LIBS) \
	$(NULL)

libcld_0_2_la_LDFLAGS = \
	-version-info $(LIBCLD_LT_VERSION) \
	-no-undefined \
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

if HAVE_INTROSPECTION
girdir = @INTROSPECTION_GIRDIR@

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

Cld-0.2.gir cld-internals-0.2.vapi cld-0.2.vapi: libcld-0.2.la

CLEANFILES = \
	cld-0.2.vapi \
	cld-internals-0.2.vapi \
	Cld-0.2.typelib \
	Cld-0.2.gir \
	$(NULL)
