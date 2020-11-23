PKG_ARCHIVE_EXT=7z
PKG_DIR=${PKG_NAME}_${PKG_VERSION//./_}
PKG_URI="https://downloads.sourceforge.net/project/boost/${PKG_NAME}/${PKG_VERSION}/${PKG_DIR}.7z"

BOOST_OPTIONS="--build-dir=`to_win_path ${PKG_BUILD}` \
               --prefix=`to_win_path ${PKG_DST}` \
               --build-type=complete \
               --layout=versioned \
               --without-python \
               --without-mpi \
               toolset=gcc \
               address-model=${ARCH} \
               variant=release \
               threading=multi \
               threadapi=win32 \
               link=shared \
               pch=off \
               define=BOOST_LOG_WITHOUT_EVENT_LOG \
               define=BOOST_LOG_WITHOUT_SYSLOG \
               define=BOOST_USE_WINDOWS_H \
               -j${JOBS}"

src_prepare() {
    # Compilation de bjam, l'outil de build
    ./bootstrap.bat gcc
}

src_workdir() {
    # apparemment c'est important d'être dans le dossier source pour lancer la commande
    cd ${PKG_SRC}
}

src_compile() {
    ./bjam ${BOOST_OPTIONS} stage || non_fatal "Certaines librairies ont échoué"
}

src_install() {
    ./bjam ${BOOST_OPTIONS} install || non_fatal "Certaines librairies ont échoué"
}

src_post_install() {
    # les dll ont leur place dans bin
    mkdir -p "${PKG_DST}/bin"
    mv "${PKG_DST}"/lib/libboost*.dll "${PKG_DST}/bin"
    compress_binaries "${PKG_DST}"/bin/libboost*.dll
}

