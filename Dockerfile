# Test install libcld on Fedora 29
#
# docker build --tag=libcld-fedora29 .
#

FROM fedora:29

# Install dependencies
RUN dnf install -y git                         \
                   meson                       \
                   ninja-build                 \
                   gnome-common                \
                   intltool                    \
                   gcc                         \
                   vala                        \
                   libgee-devel                \
                   json-glib-devel             \
                   gsl-devel                   \
                   libxml2-devel               \
                   libmatheval-devel           \
                   comedilib-devel

COPY . libcld

WORKDIR /libcld
RUN rm -rf _build
RUN meson _build
RUN ninja -C _build install
