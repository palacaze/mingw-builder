#!/usr/bin/env sh

# On appelle qtbinpatcher dans chaque installation de Qt pour corriger
# certains chemins hardcodés dans la distribution binaire
# On suppose ici que le dossier contenant les installations est organisé
# par versions de gcc, puis par architecture et enfin par version de qt

# En argument: le dossier de distribution à patcher, si vide on utilise
# le dossier par défaut

# l'architecture, le compilateur, les paths...
SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS}/build-env.sh"

WORKDIR="${1:-${ROOT}/dist}"

find "${WORKDIR}/" -maxdepth 3 -type d -path '*gcc-*/win*/qt-*' -exec qtbinpatcher --nobackup --qt-dir={} \;

