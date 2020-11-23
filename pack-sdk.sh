#!/usr/bin/env sh

# Ce script sert juste à faire une archive du dossier pour distribution.
# On retire le contenu de certains dossiers inutiles

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# l'architecture, le compilateur, les paths...
source "${ROOT}/../${SCRIPTS}/build-env.sh"

DSTFILE="SDK-$(date '+%F_%H%M%S').7z"
DIR="`basename "${ROOT}"`"
cd "${ROOT}/.."

# winpty tar -cJv --exclude="${DIR}"'/build/*' --exclude="${DIR}"'/tools/toolchains/*' -f "${DSTFILE}" "${DIR}"
winpty 7z a -t7z "${DSTFILE}" "${DIR}" \
    -xr!"${DIR}/build/*" \
    -xr!"${DIR}/tools/toolchains/*"
