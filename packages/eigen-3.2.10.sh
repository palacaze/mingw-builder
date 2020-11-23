PKG_ARCHIVE_EXT=tar.bz2
PKG_URI="http://bitbucket.org/${PKG_NAME}/${PKG_NAME}/get/${PKG_VERSION}.${PKG_ARCHIVE_EXT}"
PKG_DIR="eigen-eigen-b9cd8366d4e8"

# cereal est une librairie d'entêtes
src_compile() {
    return 0
}

src_install() {
    cp -R "${PKG_SRC}/Eigen" "${COMMON_INCLUDE_DIR}"
}

