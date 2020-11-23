PKG_ARCHIVE_EXT=tar.gz
PKG_URI="https://github.com/lz4/lz4/archive/v${PKG_VERSION}.${PKG_ARCHIVE_EXT}"

# lz4 ne builde pas out-of-source...
src_prepare() {
    cd "${PKG_SRC}/lib"
    $MAKE clean || non_fatal
}

src_workdir() {
    cd "${PKG_SRC}/lib"
}

# installe à la main, pas supporté par le makefile pour Mingw
# (penser à vérifier les entêtes à copier dans le makefile)
src_install() {
    cp liblz4.a "${PKG_DST}/lib"
    cp lz4.h lz4hc.h lz4frame.h "${PKG_DST}/include"
}

