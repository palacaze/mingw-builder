PKG_ARCHIVE_EXT=tar.gz
PKG_URI="https://github.com/gabime/spdlog/archive/v${PKG_VERSION}.${PKG_ARCHIVE_EXT}"

inherit cmake

src_configure() {
    local mycmakeargs=(
        SPDLOG_BUILD_TESTING=OFF
        SPDLOG_BUILD_EXAMPLES=OFF
    )

    cmake_src_configure
}

