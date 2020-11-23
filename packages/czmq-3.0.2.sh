PKG_ARCHIVE_EXT=tar.gz
PKG_URI="https://github.com/zeromq/czmq/releases/download/v${PKG_VERSION}/${PKG_ATOM}.${PKG_ARCHIVE_EXT}"

# czmq ne builde pas out-of-source, alors on nettoie
# d'une fois à l'autre
src_prepare() {
    $MAKE clean || non_fatal
}

src_workdir() {
    cd "${PKG_SRC}"
}

# czmq utilise configure avant la version 4, mais peu testé sur Windows
# cela explique la bidouille de configuration
src_configure() {
    CF="-Wall -Wno-pedantic-ms-format -DLIBCZMQ_EXPORTS -DZMQ_DEFINED_STDINT"
    LF="-lws2_32 -liphlpapi -lrpcrt4 -lzmq"
    CFLAGS="${CF}" LDFLAGS="${LF}" ./configure --prefix="${PKG_DST}" --disable-static
}

src_post_install() {
    compress_binaries "${PKG_DST}/bin/libczmq.dll"
    rm "${PKG_DST}/lib/libczmq.la"
    mv "${PKG_DST}/lib/libczmq.dll.a" "${PKG_DST}/lib/libczmq.a"
}

