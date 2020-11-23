#!/usr/bin/env bash

# Quelques fonctions et variables génériques utiles
S_RESET="\033[0m"
S_BOLD="\033[1m"
SF_RED="\033[1;31m"
SF_GREEN="\033[1;32m"
SF_YELLOW="\033[1;33m"
SF_BLUE="\033[1;34m"

function echoerr() {
    echo "$@" 1>&2;
}

function enotice() {
    echo -e "${SF_BLUE} *${S_RESET} $@"
}

function einfo() {
    echo -e "${SF_GREEN} *${S_RESET} ${S_BOLD}$@${S_RESET}"
}

function ewarn() {
    echo -e "${SF_YELLOW} *${S_RESET} ${S_BOLD}$@${S_RESET}"
}

function eerror() {
    echo -e "${SF_RED} *${S_RESET} ${S_BOLD}$@${S_RESET}"
}

# arrête un processus en cas d'erreur
function die() {
    eerror "$@"
    exit 1
}

# marque une erreur comme non fatale
function non_fatal() {
    ewarn "$@"
    return 0
}

# compresse les binaires passés en argument avec upx
function compress_binaries() {
    /usr/bin/winpty upx -9 --all-methods "$@"
}

# extraction d'archive
# $1: l'archive
# $2 et suivant: une liste optionnelle de fichiers à ne pas extraire
function unpack() {
    file="$1"
    shift
    skip=("${@}")

    if [ -f "${file}" ]; then
        case "${file}" in
            *.tar|*.tar.bz2|*tar.gz|*.tbz2|*.tgz)
                if [ -n "$1" ]; then
                    skip="${skip[@]/#/--exclude\=}"
                fi
                eval "/usr/bin/tar xf \"${file}\" ${skip}"
                ;;
            *.bz2)
                /usr/bin/bunzip2 -q "${file}"
                ;;
            *.gz)
                /usr/bin/gunzip -q "${file}"
                ;;
            *.zip)
                if [ -n "$1" ]; then
                    skip="-x "${skip[@]/%/\/\*}""
                fi
                /usr/bin/unzip -q "${file}" ${skip}
                ;;
            *.7z)
                if [ -n "$1" ]; then
                    skip="${skip[@]/#/-xr\!}"
                fi
                7z x "${file}" ${skip}
                ;;
            *)
                die "'${file}' ne peut pas être extrait"
                ;;
        esac
    else
        die "'${file}' n'est pas un fichier"
    fi
}

# conversion en chemins /c/Users/pal...
function to_unix_path() {
    /usr/bin/cygpath -u "$1"
}

# conversion en chemins C:\Users\pal...
function to_win_path() {
    /usr/bin/cygpath -w "$1"
}

# conversion en chemins C:/Users/pal...
function to_qt_path() {
    /usr/bin/cygpath -m "$1"
}

# teste l'existence d'une fonction
function function_exists() {
    declare -f -F $1 > /dev/null
    return $?
}

