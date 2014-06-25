include $(top_srcdir)/Makefile.decl

noinst_PROGRAMS = $(EXAMPLE_PROGS)

EXAMPLE_PROGS += \
	build-from-xml \
	async-acquisition \
	context-validation \
	$(NULL)

### Shared build flags and dependencies

example_SOURCES = \
	example.vala \
	$(NULL)

example_DEPENDENCIES = \
	$(top_srcdir)/cld/cld-0.2.vapi \
	$(NULL)

example_VALAFLAGS = \
	--basedir $(top_srcdir) \
	--vapidir $(top_srcdir)/cld \
	--pkg cld-0.2 --pkg comedi --pkg gee-1.0 --pkg libxml-2.0 --pkg posix --pkg gsl \
	$(NULL)

example_CPPFLAGS = \
	-I$(top_srcdir)/cld \
	$(GLIB_CFLAGS) \
	$(GEE_CFLAGS) \
	$(XML_CFLAGS) \
	$(JSON_CFLAGS) \
	$(NULL)

example_LDADD = \
	../cld/libcld-0.2.la \
	$(GLIB_LIBS) \
	$(GEE_LIBS) \
	$(XML_LIBS) \
	$(JSON_LIBS) \
	$(NULL)

### individual example applications

build_from_xml_SOURCES = build-from-xml.vala $(example_SOURCES)
build_from_xml_DEPENDENCIES = $(example_DEPENDENCIES)
build_from_xml_VALAFLAGS = $(example_VALAFLAGS)
build_from_xml_CPPFLAGS = $(example_CPPFLAGS)
build_from_xml_LDADD = $(example_LDADD)

async_acquisition_SOURCES = async-acquisition.vala $(example_SOURCES)
async_acquisition_DEPENDENCIES = $(example_DEPENDENCIES)
async_acquisition_VALAFLAGS = $(example_VALAFLAGS)
async_acquisition_CPPFLAGS = $(example_CPPFLAGS)
async_acquisition_LDADD = $(example_LDADD)

context_validation_SOURCES = context-validation.vala $(example_SOURCES)
context_validation_DEPENDENCIES = $(example_DEPENDENCIES)
context_validation_VALAFLAGS = $(example_VALAFLAGS)
context_validation_CPPFLAGS = $(example_CPPFLAGS)
context_validation_LDADD = $(example_LDADD)

