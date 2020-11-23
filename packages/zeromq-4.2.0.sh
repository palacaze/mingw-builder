PKG_ARCHIVE_EXT=tar.gz
PKG_URI="https://github.com/zeromq/libzmq/releases/download/v${PKG_VERSION}/${PKG_ATOM}.${PKG_ARCHIVE_EXT}"

# zeromq utilise cmake depuis la version 4.2
inherit cmake

src_configure() {
    mycmakeargs=(
        WITH_PERF_TOOL=OFF
        ZMQ_BUILD_TESTS=OFF
    )

    cmake_src_configure
}

src_post_install() {
    compress_binaries "${PKG_DST}/bin/libzmq.dll"
}

