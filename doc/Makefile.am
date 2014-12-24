include $(top_srcdir)/Makefile.decl

SRC_DIR = $(top_srcdir)/cld

vapidir=/usr/share/vala-`valac --version | sed -n 's/Vala.\([0-9]\.[0-9][0-9]\).*/\1/p'`/vapi
docdir=$(datadir)/devhelp/references/cld-0.3
innerdocdir=$(datadir)/devhelp/references/cld-0.3/cld-0.3
imgdir=$(datadir)/devhelp/references/cld-0.3/cld-0.3/img

doc_data = \
	cld-0.3/*.css \
	cld-0.3/*.png \
	$(NULL)

doc_DATA = \
	cld-0.3/index.html \
	$(doc_data) \
	$(NULL)

innerdoc_DATA = \
	cld-0.3/cld-0.3/index.htm \
	cld-0.3/cld-0.3/*.html \
	$(NULL)

img_DATA = \
	cld-0.3/cld-0.3/img/*.png \
	$(NULL)

$(doc_data) $(innerdoc_DATA) $(img_DATA): cld-0.3/index.html

cld-0.3/index.html:
	$(VALADOC) -o cld-0.3/ --wiki ./ --force -b $(top_srcdir) $(SRC_DIR)/*.vala --pkg=gee-1.0 --pkg=libxml-2.0 --pkg=json-glib-1.0 --pkg=linux --pkg=posix --pkg=comedi --pkg=libmodbus --pkg=libmatheval --pkg=gsl --pkg=config --pkg=sqlite3 --vapidir=$(vapidir) --vapidir=../vapi

EXTRA_DIST += \
	index.wiki \
	$(NULL)
