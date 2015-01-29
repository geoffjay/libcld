include $(top_srcdir)/Makefile.decl

noinst_PROGRAMS = $(TEST_PROGS)

TEST_PROGS += tests

tests_SOURCES = \
	testaichannel.vala \
	testaochannel.vala \
	testbuildable.vala \
	testbuilder.vala \
	testcalibration.vala \
	testcase.vala \
	testchannel.vala \
	testcoefficient.vala \
	testcontrol.vala \
	testcsvlog.vala \
	testdevice.vala \
	testdichannel.vala \
	testdochannel.vala \
	testfilter.vala \
	testflowsensor.vala \
	testmain.vala \
	testobject.vala \
	testpid.vala \
	testport.vala \
	testsensor.vala \
	testserialport.vala \
	testvchannel.vala \
	testxmlconfig.vala \
	$(NULL)

tests_DEPENDENCIES = \
	$(top_srcdir)/cld/cld-0.3.vapi \
	$(NULL)

tests_VALAFLAGS = \
	$(VALAFLAGS) \
	--basedir $(top_srcdir) \
	--vapidir $(top_srcdir)/cld --vapidir=$(srcdir)/../vapi \
	--pkg cld-0.3 @VALA_PACKAGES@ --pkg libmatheval --pkg posix \
	$(NULL)

tests_CPPFLAGS = \
	-I$(top_srcdir)/cld \
	$(GLIB_CFLAGS) \
	$(GEE_CFLAGS) \
	$(XML_CFLAGS) \
	$(JSON_CFLAGS) \
	$(MATH_CFLAGS) \
	$(GSL_CFLAGS) \
	$(SQLITE_CFLAGS) \
	$(NULL)

tests_LDADD = \
	../cld/libcld-0.3.la \
	$(GLIB_LIBS) \
	$(GEE_LIBS) \
	$(XML_LIBS) \
	$(JSON_LIBS) \
	$(MATH_LIBS) \
	$(GSL_LIBS) \
	$(SQLITE_LIBS) \
	$(NULL)
