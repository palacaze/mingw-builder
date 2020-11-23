PKG_ARCHIVE_EXT=7z
PKG_DIR=qt-everywhere-opensource-src-${PKG_VERSION}
PKG_URI="https://download.qt.io/official_releases/qt/${PKG_VERSION%.*}/${PKG_VERSION}/single/${PKG_DIR}.7z"

DISABLE=(openssl qml-debug openvg incredibuild-xge dbus angle icu fontconfig freetype iconv harfbuzz)
SKIP=(3d activeqt androidextras canvas3d charts connectivity datavis3d declarative gamepad location
      macextras multimedia purchasing quickcontrols quickcontrols2 script scxml sensors serialbus
      translations virtualkeyboard wayland webchannel webengine websockets webview x11extras)

NO_UNPACK=( "${SKIP[@]/#/qt}" )  # inutile de décompresser ces dossiers

src_prepare() {
    export PATH="${PKG_SRC}/qtbase/bin:${PKG_SRC}/gnuwin32/bin:${PATH}"

    # désactive webp, inutile et pose problème dans le shell (chemins trop longs à cause
    # de l'option qmake CONFIG += object_parallel_to_source)
    echo "SUBDIRS -= webp" >> "${PKG_SRC}/qtimageformats/src/plugins/imageformats/imageformats.pro"
    sed -i -e 's/\(qtCompileTest(libwebp)\)/#\1/' "${PKG_SRC}/qtimageformats/qtimageformats.pro"
}

# D'une version à l'autre de Qt, des options de configure peuvent changer. Ici on ne compile que les modules
# utiles et skip tout le reste (les sous-dossiers qtmachin correspondent aux modules dispos).
# Pour voir toutes les options il faut lancer configure.bat avec uniquement -platform win32-g++ -h
src_configure() {
    "${PKG_SRC}/configure.bat" \
        -platform win32-g++ \
        -opensource \
        -confirm-license \
        -release \
        -c++std c++14 \
        -ltcg \
        -prefix "${PKG_DST}/${PKG_ATOM}" \
        -nomake tools -nomake examples \
        -qt-sql-odbc -qt-sql-sqlite -plugin-sql-odbc -plugin-sql-sqlite \
        -opengl desktop \
        -strip \
        ${DISABLE[@]/#/-no-}
        # ${SKIP[@]/#/-skip qt} pas décompressés donc pas besoin de les skipper
}

src_post_install() {
    # j'évite de compresser QtCore car qtbinpatcher risquerait d'échouer
    dlls=`find "${PKG_DST}/${PKG_ATOM}/bin/" -maxdepth 1 ! -iname "qt5core*.dll" -iname "qt5*.dll"`
    compress_binaries ${dlls}

    # Qt s'attend à la présence des librairies debug (avec un suffixe 'd'
    # Comme nous ne les compilons pas, ça empêche la compilation en mode debug.
    # On désactive cette "fonctionnalité"
    sed -i -e '/win32: return($${suffix}d)/d' "${PKG_DST}/${PKG_ATOM}/mkspecs/features/qt_functions.prf"
}

