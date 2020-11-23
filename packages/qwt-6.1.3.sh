PKG_ARCHIVE_EXT=tar.bz2
PKG_URI="https://sourceforge.net/projects/qwt/files/qwt/${PKG_VERSION}/${PKG_ATOM}.tar.bz2"

# on doit modifier les fichiers de qwt, le build system n'est pas configurable
src_prepare() {
    # on ne compile que release, et évite build_all pour avoir à stripper la dll
    sed -i -e 's/\+=  *debug_and_release/\+= release/' \
           -e '/build_all/d' \
        "${PKG_SRC}/qwtbuild.pri"

    # on installe dans le même répertoire que Qt car qwt dépend de Qt
    export QWT_DST="`qt_dist`"
    dst="`to_qt_path "${QWT_DST}"`"

    # on change le dossier d'installation, des sources et entêtes et désactive certaines options
    sed -i -e "s,\(^  *QWT_INSTALL_PREFIX\).*,\1 \= "$dst"," \
           -e 's,^QWT_INSTALL_HEADERS.*,QWT_INSTALL_HEADERS \= \$\$\{QWT_INSTALL_PREFIX\}/include/qwt,' \
           -e 's/\(^QWT_CONFIG.*Qwt\(Svg\|OpenGL\|Designer\|MathML\|Examples\|Playground\)$\)/#\1/' \
        "${PKG_SRC}/qwtconfig.pri"
}

src_configure() {
    "${QWT_DST}/bin/qmake" -spec win32-g++ `to_qt_path "${PKG_SRC}/qwt.pro"`
}

src_post_install() {
    # les dll ont leur place dans bin
    mkdir -p "${QWT_DST}/bin"
    mv "${QWT_DST}/lib/qwt.dll" "${QWT_DST}/bin"
    compress_binaries "${QWT_DST}/bin/qwt.dll"
}

