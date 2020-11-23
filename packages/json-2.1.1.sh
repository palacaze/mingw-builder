JSON_HDR="json.hpp"
PKG_ARCHIVE=${JSON_HDR}
PKG_URI="https://github.com/nlohmann/json/releases/download/v${PKG_VERSION}/${JSON_HDR}"

# pas d'archive
src_unpack() {
    return 0
}

# json est une librairie d'entêtes
src_compile() {
    return 0
}

src_install() {
    mkdir -p "${COMMON_INCLUDE_DIR}/nlohmann"
    cp "${ARCHIVES}/${JSON_HDR}" "${COMMON_INCLUDE_DIR}/nlohmann"
}

