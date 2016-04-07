# rust-libhif
Generate Rust bindings for libhif

# Requirements

docker, findutils, rustc 1.8.0+ (earlier versions don't support univariant enums which is needed by GLib)

# Description
First an image tagged `rust-libhif` is built using `Fedora:23` as base. During the build, `libhif` is compiled from git master and latest stable version of `rustc`, `cargo` and `rust-bindgen` is fetched from upstream. The bindings are generated when the container is run and are outputted to `libhif.rs`.
