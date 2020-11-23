#!/usr/bin/env bash

# ce script execute les consignes de compilation et d'installation du paquet
# donné en argument

# Le chemin vers le dossier scripts
SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# configuration et fonctions utiles
source "${SCRIPTS}/build-funcs.sh"
source "${SCRIPTS}/build-env.sh"

PKG_DEF="$1"
PKG_ATOM="`basename "${PKG_DEF/%.sh}"`"
PKG_NAME="${PKG_ATOM%-*}"
PKG_VERSION="${PKG_ATOM#*-}"

# dossier contenu directement dans l'archive de sources
PKG_DIR="${PKG_ATOM}"

# l'extension de l'archive, les extensions reconnues par unpack() sont gérées
PKG_ARCHIVE_EXT=

# l'url pour télécharger les sources
PKG_URI=

# dossier de compilation
PKG_BUILD="${BUILD}/build-${PKG_ATOM}_gcc-${GCCVER}_${ARCH}"

# dossier de destination
PKG_DST="${DIST}"

# fonction permettant de sourcer des eclass, qui ajoutent des fonctionnalités
# et proposent en plus d'écraser les implémentations par défaut des fonctions
# de phases, on les retient pour les utiliser potentiellement plus tard
function inherit() {
    for eclass in ${@}; do
        source "$SCRIPTS/eclasses/${eclass}.eclass" || die "eclass inconnue"
    done
    export INHERIT_LIST="${@}"
}

# lecture des instuctions de compilation du package
# un certain nombre de variables et de fonctions peuvent être (re-)définies
# dans ce script:
# - les variable PKG_DIR et PKG_ARCHIVE
# - les fonctions qui exécutent les instructions de compilation:
#   - src_fetch : récupérer le code source depuis internet et le placer dans $ARCHIVES
#   - src_unpack : décompresser les sources dans $BUILD
#   - src_prepdir : déplacement dans le dossier de travail ($PKG_SRC par défaut)
#   - src_prepare : typiquement patcher les sources
#   - src_workdir : déplacement dans le dossier de travail ($PKG_BUILD par défaut)
#   - src_configure : configurer le package
#   - src_compile : compiler
#   - src_pre_install : préparer l'installation
#   - src_install : installer
#   - src_post_install : post installer (stipper, l'exécutable, retirer certains fichiers...)
source "${PKG_DEF}"

# nom complet de l'archive source
if [ -z ${PKG_ARCHIVE} ]; then
    PKG_ARCHIVE="${PKG_DIR}"
fi

if [ -n "$PKG_ARCHIVE_EXT" ]; then
    PKG_ARCHIVE="${PKG_ARCHIVE}.${PKG_ARCHIVE_EXT}"
fi

# dossier de sources
PKG_SRC="${BUILD}/${PKG_DIR}"

# Récupère les sources du net, en utilisant $PKG_URI et $PKG_ARCHIVE
# TODO il faudrait aussi vérifier la somme de contrôle
function src_fetch_default() {
    if [ -e "${ARCHIVES}/${PKG_ARCHIVE}" ]; then
        return
    fi

    if [ -n "${PKG_URI}" ]; then
        winpty curl -L -o "${ARCHIVES}/${PKG_ARCHIVE}" "${PKG_URI}"
    fi
}

# Extrait les sources d'un programme si pas déjà le cas, soit en utilisant
# Les variable $PKG_ARCHIVE et $PKG_DIR doivent exister
function src_unpack_default() {
    if [ -d "${PKG_SRC}" ]; then
        return
    fi

    file="${ARCHIVES}/${PKG_ARCHIVE}"

    if [ -e "${file}" ]; then
        pushd "${BUILD}" > /dev/null
        unpack "${file}" ${NO_UNPACK[@]}
        popd > /dev/null
    else
        die "Archive ${PKG_ARCHIVE} absente"
    fi
}

function src_prepdir_default() {
    /usr/bin/mkdir -p "${PKG_SRC}"
    cd "${PKG_SRC}"
}

function src_prepare_default() {
    return 0
}

function src_workdir_default() {
    /usr/bin/rm -rf "${PKG_BUILD}"
    /usr/bin/mkdir -p "${PKG_BUILD}"
    cd "${PKG_BUILD}"
}

function src_configure_default() {
    return 0
}

function src_compile_default() {
    $MAKE -j${JOBS}
}

function src_pre_install_default() {
    return 0
}

function src_install_default() {
    $MAKE install
}

function src_post_install_default() {
    return 0
}

mkdir -p "${COMMON_INCLUDE_DIR}"
mkdir -p "${BUILD}"

# exécution des instructions
for step in fetch unpack prepdir prepare workdir configure compile pre_install install post_install; do
    func=src_$step
    enotice "\tPhase $step"
    if function_exists "$func"; then
        $func || die "erreur dans $func"
    else
        ok=false
        for inh in $INHERIT_LIST; do
            if function_exists "${inh}_${func}"; then
                "${inh}_${func}" || die "erreur dans ${inh}_${func}"
                ok=true
                break
            fi
        done
        if [ "$ok" = false ]; then
            ${func}_default || die "erreur dans ${func}"
        fi
    fi
done

