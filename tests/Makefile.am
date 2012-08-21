include $(top_srcdir)/Makefile.decl

noinst_PROGRAMS = $(TEST_PROGS)

TEST_PROGS += tests

tests_SOURCES = \
	testaichannel.vala \
	testaochannel.vala \
	testbuilder.vala \
	testcalibration.vala \
	testcase.vala \
	testchannel.vala \
	testcoefficient.vala \
	testcontrol.vala \
	testdaq.vala \
	testdevice.vala \
	testdichannel.vala \
	testdochannel.vala \
	testfilter.vala \
	testlog.vala \
	testmain.vala \
	testobject.vala \
	testpid.vala \
	testport.vala \
	testserialport.vala \
	testvchannel.vala \
	testxmlconfig.vala \
	$(NULL)

tests_DEPENDENCIES = \
	$(top_srcdir)/cld/cld-0.2.vapi \
	$(NULL)

tests_VALAFLAGS = \
	--basedir $(top_srcdir) \
	--vapidir $(top_srcdir)/cld \
	--pkg cld-0.2 --pkg gee-1.0 --pkg libxml-2.0 \
	$(NULL)

tests_CPPFLAGS = \
	-I$(top_srcdir)/cld \
	$(GLIB_CFLAGS) \
	$(GEE_CFLAGS) \
	$(XML_CFLAGS) \
	$(JSON_CFLAGS) \
	$(NULL)

tests_LDADD = \
	../cld/libcld-0.2.la \
	$(GLIB_LIBS) \
	$(GEE_LIBS) \
	$(JSON_LIBS) \
	$(NULL)
