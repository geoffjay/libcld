include $(top_srcdir)/Makefile.decl

noinst_PROGRAMS = $(EXAMPLE_PROGS)

EXAMPLE_PROGS += \
	async-acquisition \
	build-from-xml \
	context-validation \
	ndev-async-acquisition \
	pid-mathchannel \
	polling-acquisition \
	soup-server \
	$(NULL)

### Shared build flags and dependencies

example_SOURCES = \
	example.vala \
	$(NULL)

example_DEPENDENCIES = \
	$(top_srcdir)/cld/cld-0.3.vapi \
	$(NULL)

example_VALAFLAGS = \
	$(VALAFLAGS) \
	--basedir $(top_srcdir) \
	--vapidir $(top_srcdir)/cld \
	--pkg cld-0.3 --pkg comedi --pkg gee-0.8 \
	--pkg libxml-2.0 --pkg posix --pkg gsl \
	$(NULL)

example_CPPFLAGS = \
	-I$(top_srcdir)/cld \
	$(GLIB_CFLAGS) \
	$(GEE_CFLAGS) \
	$(XML_CFLAGS) \
	$(JSON_CFLAGS) \
	$(COMEDI_CFLAGS) \
	$(NULL)

example_LDADD = \
	../cld/libcld-0.3.la \
	$(GLIB_LIBS) \
	$(GEE_LIBS) \
	$(XML_LIBS) \
	$(JSON_LIBS) \
	$(COMEDI_LIBS) \
	$(NULL)

### individual example applications

async_acquisition_SOURCES = async-acquisition.vala $(example_SOURCES)
async_acquisition_DEPENDENCIES = $(example_DEPENDENCIES)
async_acquisition_VALAFLAGS = $(example_VALAFLAGS)
async_acquisition_CPPFLAGS = $(example_CPPFLAGS)
async_acquisition_LDADD = $(example_LDADD)

build_from_xml_SOURCES = build-from-xml.vala $(example_SOURCES)
build_from_xml_DEPENDENCIES = $(example_DEPENDENCIES)
build_from_xml_VALAFLAGS = $(example_VALAFLAGS)
build_from_xml_CPPFLAGS = $(example_CPPFLAGS)
build_from_xml_LDADD = $(example_LDADD)

context_validation_SOURCES = context-validation.vala $(example_SOURCES)
context_validation_DEPENDENCIES = $(example_DEPENDENCIES)
context_validation_VALAFLAGS = $(example_VALAFLAGS)
context_validation_CPPFLAGS = $(example_CPPFLAGS)
context_validation_LDADD = $(example_LDADD)

ndev_async_acquisition_SOURCES = ndev-async-acquisition.vala $(example_SOURCES)
ndev_async_acquisition_DEPENDENCIES = $(example_DEPENDENCIES)
ndev_async_acquisition_VALAFLAGS = $(example_VALAFLAGS)
ndev_async_acquisition_CPPFLAGS = $(example_CPPFLAGS)
ndev_async_acquisition_LDADD = $(example_LDADD)

pid_mathchannel_SOURCES = pid-mathchannel.vala $(example_SOURCES)
pid_mathchannel_DEPENDENCIES = $(example_DEPENDENCIES)
pid_mathchannel_VALAFLAGS = $(example_VALAFLAGS)
pid_mathchannel_CPPFLAGS = $(example_CPPFLAGS)
pid_mathchannel_LDADD = $(example_LDADD)

polling_acquisition_SOURCES = polling-acquisition.vala $(example_SOURCES)
polling_acquisition_DEPENDENCIES = $(example_DEPENDENCIES)
polling_acquisition_VALAFLAGS = $(example_VALAFLAGS)
polling_acquisition_CPPFLAGS = $(example_CPPFLAGS)
polling_acquisition_LDADD = $(example_LDADD)

soup_server_SOURCES = soup-server.vala $(example_SOURCES)
soup_server_DEPENDENCIES = $(example_DEPENDENCIES)
soup_server_VALAFLAGS = $(example_VALAFLAGS) --pkg libsoup-2.4 --pkg json-glib-1.0
soup_server_CPPFLAGS = $(example_CPPFLAGS) -I/usr/include/libsoup-2.4 -I/usr/include/json-glib-1.0
soup_server_LDADD = $(example_LDADD) -lsoup-2.4 -ljson-glib-1.0


