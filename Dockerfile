FROM fedora:23
MAINTAINER Pavel Odvody <podvody@redhat.com>

# download dependencies
RUN dnf install -y clang cmake file gcc git gtk-doc libsolv-tools make python-sphinx redhat-rpm-config \
                   {check,clang,expat,glib2,gobject-introspection,librepo,libsolv,python,python3,rpm,zlib}-devel

# clone libhif
RUN git clone https://github.com/rpm-software-management/libhif

# build and install libhif
RUN (mkdir -p /libhif/build \
 &&  cd /libhif/build \
 &&  cmake .. \
 &&  make && make install)

# install rust & bindgen
RUN curl -O -sSf https://static.rust-lang.org/rustup.sh \
 && chmod +x rustup.sh \
 && ./rustup.sh --disable-sudo \
 && cargo install bindgen

# append `.cargo/bin` to `PATH`
ENV PATH /root/.cargo/bin:\\$PATH

# copy `glibconfig.h` to `glib-2.0` include path
RUN cp /usr/lib64/glib-2.0/include/glibconfig.h /usr/include/glib-2.0/

# prepend `glib-2.0/` to all includes starting with `g`
RUN find /usr/include/{librepo,glib-2.0} /usr/local/include/libhif \
         -name '*.h' -exec sed -i "s,<g,<glib-2.0/g,g" {} +

# run bindgen
CMD ["bindgen", "/usr/local/include/libhif/libhif.h"]
