PKG_ARCHIVE_EXT=tar.gz
PKG_DIR="${PKG_NAME}-c-cpp-${PKG_VERSION}"
PKG_URI="https://github.com/msgpack/msgpack-c/archive/cpp-${PKG_VERSION}.${PKG_ARCHIVE_EXT}"

# cereal est une librairie d'entêtes
src_compile() {
    return 0
}

src_install() {
    cp -R "${PKG_SRC}"/include/* "${COMMON_INCLUDE_DIR}"
}

