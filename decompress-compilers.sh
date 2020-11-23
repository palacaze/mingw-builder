#!/usr/bin/env sh

# On réduit la taille du SDK en ne gardant que les archives
# Ce script les décompresse au bon endroit, en supposant
# que les différentes versions des compilateurs soient
# initialement dans $base/src/tools/toolchains,
# avec un nom arch-ver-release-posix-exceptions-rt.*.7z

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# l'architecture, le compilateur, les paths...
source "${SCRIPTS}/build-env.sh"
source "${SCRIPTS}/build-funcs.sh"

SRC="${ARCHIVES}/tools/toolchains"
DST="${TOOLS}/toolchains"

find "${SRC}/" -maxdepth 1 -type f | while read -r i; do
    name="`basename "$i"`"
    ver=`echo "$name" | cut -d'-' -f2`
    dst="${DST}/gcc-${ver}"
    mkdir -p "${dst}"
    cd "${dst}"
    echo "Extraction de $i dans ${dst}"
    unpack "$i"
done

