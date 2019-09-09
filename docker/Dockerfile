# Generate a Debian package and upload it to packagecloud

FROM debian:buster

RUN apt-get update -qq && apt-get install --no-install-recommends -qq -y \
    debhelper \
    gcc  \
    valac \
    meson \
    bison \
    cmake \
    flex \
    gettext \
    python3-pip \
    valac \
    locales \
    devscripts \
    build-essential \
    lintian \
    ruby-dev \
    rubygems

RUN apt-get install --no-install-recommends -qq -y \
    libgee-0.8-dev \
    libglib2.0-dev \
    libgirepository1.0-dev \
    libxml2-dev \
    libjson-glib-dev \
    libgsl-dev \
    libmatheval-dev \
    libcomedi-dev

RUN gem install rake -v '12.3.1'

RUN gem install package_cloud

# Locale for our build
RUN locale-gen C.UTF-8 && /usr/sbin/update-locale LANG=C.UTF-8
ENV LANG=C.UTF-8 LANGUAGE=C.UTF-8 LC_ALL=C.UTF-8

# package cloud token
ARG pc_token=xxx
ENV PACKAGECLOUD_TOKEN=$pc_token

RUN useradd -ms /bin/bash user

USER user
WORKDIR /home/user

COPY --chown=user:user . libcld

RUN tar -zcvf libcld_1.0.orig.tar.gz ./libcld

WORKDIR /home/user/libcld

RUN debuild

WORKDIR /home/user
RUN package_cloud push --skip-errors coanda/public/debian/buster *.deb
