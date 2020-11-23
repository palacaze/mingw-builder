PKG_ARCHIVE_EXT=tar.gz
PKG_URI="https://github.com/zeromq/zeromq4-1/releases/download/v${PKG_VERSION}/${PKG_ATOM}.${PKG_ARCHIVE_EXT}"

# czmq ne builde pas out-of-source, alors on nettoie
# d'une fois à l'autre
src_prepare() {
    $MAKE clean || non_fatal
}

src_workdir() {
    cd "${PKG_SRC}"
}

# zeromq utilise configure avant la version 4.2, mais peu testé sur Windows
# cela explique la bidouille de configuration
src_configure() {
    CF="-DDLL_EXPORT -DFD_SETSIZE=4096"
    CFLAGS="$CF" CXXFLAGS="$CF" ./configure --prefix="${PKG_DST}" --disable-static
}

src_post_install() {
    compress_binaries "${PKG_DST}/bin/libzmq.dll"
    rm "${PKG_DST}/lib/libzmq.la"
    mv "${PKG_DST}/lib/libzmq.dll.a" "${PKG_DST}/lib/libzmq.a"
}

