#!/usr/bin/env bash

# ce script, à sourcer, configure les variables utiles pour simplifier
# et harmoniser la mise en place de l'environnement de travail.

# architecture 32 ou 64 bits
ARCH=${ARCH:-32}

# version du compilateur
GCCVER=${GCCVER:-6.2.0}

# threads de compilation
JOBS=${JOBS:-6}

if [ "$ARCH" -ne 32 -a "$ARCH" -ne 64 ]; then
    echo "Mauvaise architecture"
    exit
fi

# les softs basés sur autotools ont besoin de cette variable,
# sinon ils appellent 'make', qui n'existe pas
export MAKE=mingw32-make
export CC=gcc

# Le chemin vers le dossier scripts
SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Le chemin vers la racine du SDK, en supposant que scripts soit dans $ROOT/tools
ROOT="`realpath "${SCRIPTS}/../.."`"

# dossier de compilation
BUILD="${ROOT}/build"

# dossier d'archives
ARCHIVES="${ROOT}/archives"

# outils
TOOLS="${ROOT}/tools"

# dossiers de destination des softs compilés, dépend le ARCH et GCCVER
DIST="${ROOT}/dist/gcc-${GCCVER}/win${ARCH}"

# dossier d'include commun
COMMON_INCLUDE_DIR="${ROOT}/dist/include"

# les outils sont dans 'tools':
# Git for Windows est supposé être dans 'git', on utilise son perl
# les toolchains MinGW contiennet Python 2.7
# les versions de gcc sont dans toolchains, organisés par version
PERLPATH="${TOOLS}/git/usr/bin"
PYTHONPATH="${TOOLS}/toolchains/gcc-${GCCVER}/mingw${ARCH}/opt/bin"
GCCPATH="${TOOLS}/toolchains/gcc-${GCCVER}/mingw${ARCH}/bin"

# on ajoute GCC au path, à priori on en a tout le temps besoin
# on fait pareil pour les petits outils dans tools/bin
export PATH="${GCCPATH}:${TOOLS}/bin:${TOOLS}/cmake/bin:${DIST}/bin:${PATH}"

# autres variables utiles
export LDPATH="${DIST}/lib"
export LIBRARY_PATH="${DIST}/bin:${DIST}/lib"
export C_INCLUDE_PATH="${DIST}/include"
export CPLUS_INCLUDE_PATH="${C_INCLUDE_PATH}:${COMMON_INCLUDE_DIR}"

# trouve le dossier d'installation de Qt
# on le fait en cherchant directement dans $DIST le numéro le plus élevé
function qt_dist() {
    find "${DIST}/" -maxdepth 1 -iname 'qt-*' | sort | tail -n1
}

