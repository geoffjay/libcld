include $(top_srcdir)/Makefile.decl

noinst_PROGRAMS = $(EXAMPLE_PROGS)

EXAMPLE_PROGS += \
	builder \
	$(NULL)

### Shared build flags and dependencies

example_DEPENDENCIES = \
	$(top_srcdir)/cld/cld-0.2.vapi \
	$(NULL)

example_VALAFLAGS = \
	--basedir $(top_srcdir) \
	--vapidir $(top_srcdir)/cld \
	--pkg cld-0.2 --pkg gee-1.0 --pkg libxml-2.0 \
	$(NULL)

example_CPPFLAGS = \
	-I$(top_srcdir)/cld \
	$(GLIB_CFLAGS) \
	$(GEE_CFLAGS) \
	$(XML_CFLAGS) \
	$(NULL)

example_LDADD = \
	../cld/libcld-0.2.la \
	$(GLIB_LIBS) \
	$(GEE_LIBS) \
	$(XML_LIBS) \
	$(NULL)

### individual example applications

builder_SOURCES = \
	builder.vala \
	$(NULL)

builder_DEPENDENCIES = $(example_DEPENDENCIES)
builder_VALAFLAGS = $(example_VALAFLAGS)
builder_CPPFLAGS = $(example_CPPFLAGS)
builder_LDADD = $(example_LDADD)
