#!/usr/bin/bash

# libhif-rust utility script
# -------------------------------
# Pavel Odvody <podvody@redhat.com>
#
# This scripts copies libhif, libsov and librepo shared objects
# built (or downloaded) during the image creation into `build/`
# directory
#
# The image is then executed to get libhif bindings for Rust
# and the output is saved into libhif.rs
# 
# Licensed under GPLv2

set -e

echo "- Building image, this may take a while"
  docker build -t rust-libhif . \
    | grep -e '^ --->' -e '^Step'
echo " Build complete, continuing ..."

mkdir -p build/

echo "- Collecting build artifacts"
  docker run -v $(pwd)/build:/build:Z \
    rust-libhif \
    sh -c "for lib in 'libhif*.so' 'librepo*.so' 'libsolv*.so'; \
             do (cp \$(find /usr/lib64 -name \${lib}) /build 2>/dev/null); \
           done"
find build/ -type f -exec echo " - {}" \;

echo "- Generating Rust bindings"
  docker run -v $(pwd)/build:/build:Z \
    rust-libhif \
    bindgen -l '/build/*' -match 'hif' /usr/local/include/libhif/libhif.h \
    > libhif.rs
echo "Done!"
