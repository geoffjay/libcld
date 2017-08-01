Name:           cld-1.0
Version:        0.4.1
Release:        1%{?dist}
Summary:        GObject Configuration Library

Group:          System Environment/Libraries
License:        LGPLv3+
URL:            https://github.com/geoffjay/libcld
Source0:        %{url}/archive/v%{version}.tar.gz

BuildRequires:  pkgconfig(glib-2.0)
BuildRequires:  pkgconfig(libgee-0.8)
BuildRequires:  pkgconfig(json-glib-1.0)
BuildRequires:  pkgconfig(libxml-2.0)
BuildRequires:  pkgconfig(libmatheval)
BuildRequires:  pkgconfig(gsl)
BuildRequires:  pkgconfig(sqlite3)
BuildRequires:  pkgconfig(comedi)
BuildRequires:  pkgconfig(libmodbus)
BuildRequires:  meson
BuildRequires:  ninja-build
%if 0%{?epel}
%else
BuildRequires:  python3-sphinx
%endif
BuildRequires:  vala
BuildRequires:  vala-tools
BuildRequires:  valadoc

%description
libcld is a library for creating GObject-based configurations and classes for
loading and working with XML and JSON files.

Libcld is written in Vala and can be used like any GObject-based C library.

%package        devel
Summary:        Development files for %{name}
Group:          Development/Libraries
Requires:       cld-1.0

%description    devel
The %{name}-devel package contains libraries and header files for
developing applications that use %{name}.

%prep
%autosetup -n cld-%{version}

%build
%meson
%meson_build

%install
%meson_install

%check
%meson_test

%files
%doc README.md COPYING
%{_libdir}/*
%exclude %{_libdir}/pkgconfig/*

%files devel
%{_includedir}/*
%{_libdir}/pkgconfig/*
%{_datadir}/vala/*

%changelog
