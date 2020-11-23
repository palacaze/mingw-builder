PKG_ARCHIVE_EXT=tar.gz
PKG_URI="https://github.com/facebook/zstd/archive/v${PKG_VERSION}.${PKG_ARCHIVE_EXT}"

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
    cp libzstd.a "${PKG_DST}/lib"
    cp zstd.h common/zbuff.h dictBuilder/zdict.h "${PKG_DST}/include"
}
