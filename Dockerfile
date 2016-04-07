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
 &&  cmake .. -DCMAKE_INSTALL_PREFIX:PATH=/usr \
 &&  make && make install)

# install rust & bindgen
RUN curl -O -sSf https://static.rust-lang.org/rustup.sh \
 && chmod +x rustup.sh \
 && ./rustup.sh --disable-sudo \
 && cargo install bindgen

# append `.cargo/bin` to `PATH`
ENV PATH /root/.cargo/bin:\\$PATH

# generate bindings
CMD sh -c 'bindgen -override-enum-type sint -builtins $(pkg-config --libs libhif) $(pkg-config --cflags libhif) /usr/include/libhif/libhif.h'
