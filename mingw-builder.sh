#!/usr/bin/env bash

package_sets=()
packages_to_build=()

for i in "$@"; do
    case $i in
        --jobs=*)
            export JOBS="${i#*=}"
            shift ;;
        --arch=*)
            export ARCH="${i#*=}"
            shift ;;
        --gcc=*)
            export GCCVER="${i#*=}"
            shift ;;
        --set=*)
            package_sets+=("${i#*=}")
            shift ;;
        -p|--pretend)
            PRETEND=1
            shift ;;
        -h|--help)
            HELP=1
            shift ;;
        -C|--list-compilers)
            LIST_COMPILERS=1
            shift ;;
        -L|--list-packages)
            LIST_PACKAGES=1
            shift ;;
        -S|--list-sets)
            LIST_SETS=1
            shift ;;
        *)
            packages_to_build+=("$i")
            shift ;;
    esac
done

# Le chemin vers le dossier scripts
SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Le dossier de définition des packages
PACKAGE_DEFS="${SCRIPTS}/packages"
PACKAGE_SETS="${SCRIPTS}/sets"

source "${SCRIPTS}/build-funcs.sh"

if [ -n "$HELP" ]; then
    echo -e "mingw-builder, un utilitaire pour compiler des paquets avec MinGW.\n"
    echo -e "Utilisation:"
    echo -e "${SF_GREEN}\tbuilder [options] paquet1 paquet2 ...${S_RESET}\n"
    echo -e "Options:"
    echo -e "\t${S_BOLD}--jobs=N${S_RESET} \t\t le nombre de threads de compilation"
    echo -e "\t${S_BOLD}--arch=32/64${S_RESET} \t\t l'architecture cible en bits"
    echo -e "\t${S_BOLD}--gcc=X.Y.Z${S_RESET} \t\t la version du compilateur GCC à utiliser"
    echo -e "\t${S_BOLD}--set=nom_du_set${S_RESET} \t\t un set de paquets à installer"
    echo -e "\t${S_BOLD}-p | --pretend${S_RESET} \t\t montre les actions qui seraient effectuées"
    echo -e "\t${S_BOLD}-C | --list-compilers${S_RESET} \t liste des compilateurs disponibles"
    echo -e "\t${S_BOLD}-L | --list-packages${S_RESET} \t liste des paquets disponibles\n"
    echo -e "\t${S_BOLD}-S | --list-sets${S_RESET} \t liste les sets disponibles\n"
    echo -e "Les paquets à compiler sont spécifiés sous la forme d'atomes."
    echo -e "Un atome est soit un nom de paquet, par exemple 'qt', soit un nom associé à "
    echo -e "un numéro de version spécifique, sous la forme nom-version, par exemple 'qt-5.7.0'."
    echo -e "En l'absence de version, la plus récente (numéro de version le plus élevé) "
    echo -e "parmis les disponible est utilisé.\n"
    echo -e "Un set est une liste de paquets prédéfinis, disponibles dans le sous-dossier 'sets'.\n"
    exit
fi

if [ -n "$LIST_COMPILERS" ]; then
    einfo "Liste des compilateurs installés: "
    find "${SCRIPTS}/../toolchains/" -mindepth 4 -maxdepth 4 -type f -ipath '*/bin/gcc.exe' | while read -r comp; do
        ver=`"${comp}" -dumpversion`
        arch=`"${comp}" -dumpmachine | grep "i686" > /dev/null && echo "32" || echo 64`
        desc=`"${comp}" --version | head -n1`
        enotice "\tGCC $ver $arch bits [${desc}]"
    done
    exit
fi

if [ -n "$LIST_PACKAGES" ]; then
    einfo "Liste des paquets disponibles: "
    for i in "${PACKAGE_DEFS}/"*; do
        enotice "\t`basename "${i%\.sh}"`"
    done
    exit
fi

if [ -n "$LIST_SETS" ]; then
    einfo "Liste des sets disponibles: "
    for i in "${PACKAGE_SETS}/"*; do
        einfo "\t`basename "${i%\.set}"`"
        while read line; do
            enotice "\t\t $line"
        done <<< "`cat "${i}" | grep -ve " *#"`"
    done
    exit
fi

# Fonction qui prend une chaine qui décrit un package
# Les formes acceptés sont $name et $name-$version
# Si le numéro de version est omis
function find_package() {
    if [ -e "${PACKAGE_DEFS}/$1.sh" ]; then
        echo "${PACKAGE_DEFS}/$1.sh"
    else
        echo `find "${PACKAGE_DEFS}" -iname "$1-*.sh" -type f | sort -n | tail -n1`
    fi
}

DEFS=

# ajout des sets éventuels
for s in "${package_sets[@]}"; do
    [[ -e "${PACKAGE_SETS}/${s}.set" ]] || die "Le set ${s} n'existe pas"
    while read line; do
        packages_to_build+=("$line")
    done <<< "`cat "${PACKAGE_SETS}/${s}.set" | grep -ve " *#"`"
done

for p in "${packages_to_build[@]}"; do
    def="`find_package $p`"

    if [ -z "$def" ]; then
        die "Paquet $p inconnu"
    else
        if [ -n "$PRETEND" ]; then
            DEFS+="`basename "${def%\.sh}"` "
        else
            einfo "Installe le paquet $p"
            "${SCRIPTS}/build-package.sh" "$def" || die "Erreur d'installation de $p"
        fi
    fi
done

if [ -n "$PRETEND" ]; then
    einfo "paquets qui seraient installés: $DEFS"
fi

