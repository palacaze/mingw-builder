PKG_ARCHIVE_EXT=tar.gz
PKG_URI="https://github.com/zeromq/czmq/releases/download/v${PKG_VERSION}/${PKG_ATOM}.${PKG_ARCHIVE_EXT}"

# czmq utilise cmake depuis la version 4.0
inherit cmake

# configuration & build
src_prepare() {
    # l'absence de ce fichier fait échouer la configuration
    touch "$PKG_SRC/src/CMakeLists-local.txt"
}

src_configure() {
    mycmakeargs=( BUILD_TESTING=OFF )
    cmake_src_configure
}

src_post_install() {
    compress_binaries "${PKG_DST}/bin/libczmq.dll"
}

