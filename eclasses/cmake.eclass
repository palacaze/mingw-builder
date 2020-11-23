# simplification de la gestion de cmake
ECLASS=cmake

# nom du binaire
: ${CMAKE_BINARY:=cmake}

# type de build
: ${CMAKE_BUILD_TYPE:=Release}

# générateur à utiliser, make ou ninja
: ${CMAKE_GENERATOR:=ninja}

# Si on veut une compilation verbeuse
: ${CMAKE_VERBOSE:=OFF}

# Dossier à utiliser par rapport à la racine des sources comme cible de l'appel
# à cmake, si le CMakeLists.txt est dans un dossier spécifique
# CMAKE_USE_DIR

# Dossier d'installation
# CMAKE_INSTALL_PREFIX, on utiliser PKG_DST par défaut


cmake_generator() {
    local generator_name

    case ${CMAKE_GENERATOR} in
        ninja)
            generator_name="Ninja"
            ;;
        emake)
            generator_name="MinGW Makefiles"
            ;;
        *)
            die "Generateur ${CMAKE_GENERATOR} non supporté"
            ;;
    esac

    echo ${generator_name}
}

# configuration, il faut définir les arguments spécifiques dans le tableau
# mycmakeargs avant d'appeler cmake_src_configure
cmake_src_configure() {
    : ${CMAKE_USE_DIR:=${PKG_SRC}}
    : ${CMAKE_INSTALL_PREFIX:=${PKG_DST}}

    local cmakeargs=(
        -G "$(cmake_generator)"
        -DCMAKE_INSTALL_PREFIX="${CMAKE_INSTALL_PREFIX}"
        -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}"
        "${mycmakeargs[@]/#/-D}"
    )

    echo "Run ${CMAKE_BINARY}" "${cmakeargs[@]}" "${CMAKE_USE_DIR}"
    "${CMAKE_BINARY}" "${cmakeargs[@]}" "${CMAKE_USE_DIR}" || die "cmake failed"
}

cmake_src_compile() {
    "${CMAKE_BINARY}" --build .
}

cmake_src_install() {
    "${CMAKE_GENERATOR}" install
}

