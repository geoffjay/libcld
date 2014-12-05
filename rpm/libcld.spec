Name:           libcld
Version:        %{ver}
Release:        %{rel}%{?dist}
Summary:        GObject Configuration Library

Group:          System Environment/Libraries
License:        LGPLv3+
URL:            http://github.com/geoffjay/libcld
#VCS:           git:git://github.com/geoffjay/libcld
Source0:        %{name}-%{version}-%{rel}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{rel}

BuildRequires:  glib2-devel
BuildRequires:  libgee-devel
BuildRequires:  json-glib-devel
BuildRequires:  libxml2-devel
BuildRequires:  gobject-introspection-devel
# Bootstrap requirements
BuildRequires:  autoconf automake libtool
BuildRequires:  vala >= 0.23.2

%description
libcld is a library for creating GObject-based configurations and classes for
loading and working with XML and JSON files.

Libcld is written in Vala and can be used like any GObject-based C library.

%package        devel
Summary:        Development files for %{name}
Group:          Development/Libraries
Requires:       %{name} = %{version}-%{release}

%description    devel
The %{name}-devel package contains libraries and header files for
developing applications that use %{name}.

%prep
%setup -q -n %{name}-%{version}-%{rel}

%build
(if ! test -x configure; then
    NOCONFIGURE=1 ./autogen.sh;
    CONFIGFLAGS=--enable-gtk-doc;
 fi;
 %configure --disable-static $CONFIGFLAGS
)
make %{?_smp_mflags}

%check
make check

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
find $RPM_BUILD_ROOT -name '*.la' -exec rm -f {} ';'

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%doc AUTHORS COPYING MAINTAINERS NEWS README
%{_libdir}/*.so.*
%dir %{_libdir}/girepository-1.0
%{_libdir}/girepository-1.0/Cld-0.1.typelib

%files devel
%{_includedir}/*
%{_libdir}/*.so
%{_libdir}/pkgconfig/cld-0.1.pc
%dir %{_datadir}/gir-1.0
%{_datadir}/gir-1.0/Cld-0.1.gir
%dir %{_datadir}/vala
%dir %{_datadir}/vala/vapi
%{_datadir}/vala/vapi/cld-0.1.vapi

%clean
rm -rf %{buildroot}

%changelog
