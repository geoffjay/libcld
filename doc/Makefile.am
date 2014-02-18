include $(top_srcdir)/Makefile.decl

SRC_DIR = $(top_srcdir)/cld

vapidir=/usr/share/vala-`valac --version | sed -n 's/Vala.\([0-9]\.[0-9][0-9]\).*/\1/p'`/vapi
docdir=$(datadir)/devhelp/references/cld-0.2
innerdocdir=$(datadir)/devhelp/references/cld-0.2/cld-0.2
imgdir=$(datadir)/devhelp/references/cld-0.2/cld-0.2/img

doc_data = \
	cld-0.2/*.css \
	cld-0.2/*.png \
	$(NULL)

doc_DATA = \
	cld-0.2/index.html \
	$(doc_data) \
	$(NULL)

innerdoc_DATA = \
	cld-0.2/cld-0.2/index.htm \
	cld-0.2/cld-0.2/*.html \
	$(NULL)

img_DATA = \
	cld-0.2/cld-0.2/img/*.png \
	$(NULL)

$(doc_data) $(innerdoc_DATA) $(img_DATA): cld-0.2/index.html

cld-0.2/index.html:
	$(VALADOC) -o cld-0.2/ --wiki ./ --force -b $(top_srcdir) $(SRC_DIR)/*.vala --pkg=gee-1.0 --pkg=libxml-2.0 --pkg=json-glib-1.0 --pkg=linux --pkg=posix --pkg=comedi --pkg=libmodbus --pkg=config --vapidir=$(vapidir) --vapidir=../vapi

EXTRA_DIST += \
	index.wiki \
	$(NULL)
