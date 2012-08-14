include $(top_srcdir)/Makefile.decl
AUTOMAKE_OPTIONS = subdir-objects
ACLOCAL_AMFLAGS = -I m4

if ENABLE_DOC
DOC_SUBDIR = \
	doc \
	$(NULL)
endif

SUBDIRS = \
	cld \
	po \
	tests \
	vapi \
	$(DOC_SUBDIR) \
	$(NULL)

cld_configdir = $(libdir)/cld-0.2/include
cld_config_DATA = config.h

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = cld-0.2.pc

dist-hook: gen-ChangeLog

gen_start_date = 2011-07-11
.PHONY: gen-ChangeLog
gen-ChangeLog:
	if test -d .git; then \
	  $(top_srcdir)/gitlog-to-changelog \
		--since=$(gen_start_date) > $(distdir)/cl-t; \
	  rm -f $(distdir)/ChangeLog; \
	  mv $(distdir)/cl-t $(distdir)/ChangeLog; \
	fi

EXTRA_DIST += \
	gitlog-to-changelog \
	MAINTAINERS \
	cld-0.2.pc.in \
	intltool-extract.in \
	intltool-merge.in \
	intltool-update.in \
	$(NULL)

DISTCLEANFILES = \
	intltool-extract \
	intltool-merge \
	intltool-update \
	$(NULL)
