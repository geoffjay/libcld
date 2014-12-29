include $(top_srcdir)/Makefile.decl

lib_LTLIBRARIES = \
	libcld-0.3.la \
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

libcld_0_3_la_SOURCES = \
	abstractchannel.vala \
	abstractcontainer.vala \
	abstractcontroller.vala \
	abstractdevice.vala \
	abstractfilter.vala \
	abstractlog.vala \
	abstractmodule.vala \
	abstractobject.vala \
	abstractport.vala \
	abstracttask.vala \
	aichannel.vala \
	aochannel.vala \
	acquisitioncontroller.vala \
	automationcontroller.vala \
	brabendermodule.vala\
	builder.vala \
	calibration.vala \
	channel.vala \
	circularbuffer.vala \
	cld.vala \
	coefficient.vala \
	connector.vala \
	container.vala \
	context.vala \
	control.vala \
	controller.vala \
	csvlog.vala \
	daq.vala \
	dataseries.vala \
	device.vala \
	dichannel.vala \
	dochannel.vala \
	entry.vala \
	filter.vala \
	functions.vala \
	heidolphmodule.vala \
	licormodule.vala \
	log.vala \
	logcolumn.vala \
	logcontroller.vala \
	mathchannel.vala \
	module.vala \
	object.vala \
	parkermodule.vala \
	pid.vala \
	port.vala \
	serialport.vala \
	simplecontainer.vala \
	socketport.vala \
	sqlitelog.vala \
	task.vala \
	vchannel.vala \
	velmexmodule.vala \
	xmlconfig.vala \
	$(COMEDI_SOURCES) \
	$(MODBUS_SOURCES) \
	$(NULL)

INCLUDES = \
	-include common.h \
	-DG_LOG_DOMAIN='"Cld"' \
	-DPKGDATADIR=\""$(pkgdatadir)"\" \
	-DPKGLIBDIR=\""$(pkglibdir)"\" \
	$(NULL)

libcld_0_3_la_VALAFLAGS = \
	-H cld.h --vapi cld-0.3.vapi \
	-h cld-internals.h -g -X -DDEBUG \
	--internal-vapi cld-internals-0.3.vapi \
	--library cld-0.3 --gir Cld-0.3.gir \
	--vapidir=$(srcdir)/../vapi --pkg config \
	@VALA_PACKAGES@ --pkg linux --pkg posix --pkg libmatheval --pkg gsl \
	$(VALAFLAGS) \
	$(NULL)

libcld_0_3_la_CPPFLAGS = \
	$(GLIB_CFLAGS) \
	$(GEE_CFLAGS) \
	$(GIO_CFLAGS) \
	$(XML_CFLAGS) \
	$(JSON_CFLAGS) \
	$(MODBUS_CFLAGS) \
	$(COMEDI_CFLAGS) \
	$(MATH_CFLAGS) \
	$(GSL_CFLAGS) \
	$(SQLITE_CFLAGS) \
	$(NULL)

libcld_0_3_la_LIBADD = \
	$(GLIB_LIBS) \
	$(GEE_LIBS) \
	$(GIO_LIBS) \
	$(XML_LIBS) \
	$(JSON_LIBS) \
	$(MODBUS_LIBS) \
	$(COMEDI_LIBS) \
	$(MATH_LIBS) \
	$(GSL_LIBS) \
	$(SQLITE_LIBS) \
	$(NULL)

libcld_0_3_la_LDFLAGS = \
	-version-info $(LIBCLD_LT_VERSION) \
	-no-undefined \
	$(NULL)

cldincludedir = $(includedir)/cld-0.3

cldinclude_HEADERS = \
	cld.h \
	$(NULL)

library_includedir = $(includedir)/cld-0.3/cld

library_include_HEADERS = \
	common.h \
	$(NULL)

vapidir = $(datadir)/vala/vapi

dist_vapi_DATA = \
	cld-0.3.vapi \
	$(NULL)

if HAVE_INTROSPECTION
girdir = @INTROSPECTION_GIRDIR@
gir_DATA = \
	Cld-0.3.gir \
	$(NULL)

typelibdir = @INTROSPECTION_TYPELIBDIR@
typelib_DATA = \
	Cld-0.3.typelib \
	$(NULL)

Cld-0.3.typelib: Cld-0.3.gir
	@INTROSPECTION_COMPILER@ --debug --verbose \
		--includedir=$(srcdir) --includedir=. \
		--shared-library=libcld-0.3.so $^ -o $@
endif

Cld-0.3.gir cld-internals-0.3.vapi cld-0.3.vapi: libcld-0.3.la

CLEANFILES = \
	cld-0.3.vapi \
	cld-internals-0.3.vapi \
	Cld-0.3.typelib \
	Cld-0.3.gir \
	$(NULL)
