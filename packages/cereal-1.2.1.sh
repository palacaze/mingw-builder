PKG_ARCHIVE_EXT=tar.gz
PKG_URI="https://github.com/USCiLab/cereal/archive/v${PKG_VERSION}.${PKG_ARCHIVE_EXT}"

inherit cmake

src_configure() {
    local mycmakeargs=(
        JUST_INSTALL_CEREAL=ON
        WITH_WERROR=OFF
    )

    cmake_src_configure
}

