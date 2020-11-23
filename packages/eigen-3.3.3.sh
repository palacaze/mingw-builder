PKG_ARCHIVE_EXT=tar.bz2
PKG_URI="http://bitbucket.org/${PKG_NAME}/${PKG_NAME}/get/${PKG_VERSION}.${PKG_ARCHIVE_EXT}"
PKG_DIR="eigen-eigen-67e894c6cd8f"

inherit cmake

src_install() {
    MOD_PATH="${PKG_DST}/share/cmake/Modules"
    mkdir -p "$MOD_PATH"
    cp "${PKG_SRC}/cmake/FindEigen3.cmake" "$MOD_PATH"

    cmake_src_install
}

