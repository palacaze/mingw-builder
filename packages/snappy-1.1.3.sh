PKG_ARCHIVE_EXT=tar.gz
PKG_URI="https://github.com/google/snappy/releases/download/${PKG_VERSION}/${PKG_ATOM}.${PKG_ARCHIVE_EXT}"

# snappy ne builde pas out-of-source, alors on nettoie
# d'une fois à l'autre
src_prepare() {
    $MAKE clean || non_fatal
}

src_workdir() {
    cd "${PKG_SRC}"
}

src_configure() {
    ./configure --prefix="${PKG_DST}" --disable-shared
}

src_post_install() {
    rm "${PKG_DST}/lib/libsnappy.la"
}

