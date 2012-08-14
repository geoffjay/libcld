include $(top_srcdir)/Makefile.decl

noinst_PROGRAMS = $(TEST_PROGS)

TEST_PROGS += tests

tests_SOURCES = \
	testcase.vala \
	testmain.vala \
	testobject.vala \
	$(NULL)

tests_DEPENDENCIES = \
	$(top_srcdir)/cld/cld-0.2.vapi \
	$(NULL)

tests_VALAFLAGS = \
	--basedir $(top_srcdir) \
	--vapidir $(top_srcdir)/cld \
	--pkg cld-0.2 \
	$(NULL)

tests_CPPFLAGS = \
	-I$(top_srcdir)/cld \
	$(GLIB_CFLAGS) \
	$(NULL)

tests_LDADD = \
	$(GLIB_LIBS) ../cld/libcld.la \
	$(NULL)
