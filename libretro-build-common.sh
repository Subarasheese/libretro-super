#!/bin/bash

die() {
   echo $1
   #exit 1
}

if [ "${CC}" ] && [ "${CXX}" ]; then
   COMPILER="CC=\"${CC}\" CXX=\"${CXX}\""
else
   COMPILER=""
fi

echo "Compiler: ${COMPILER}"

[[ "${ARM_NEON}" ]] && echo '=== ARM NEON opts enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-neon"
[[ "${CORTEX_A8}" ]] && echo '=== Cortex A8 opts enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-cortexa8"
[[ "${CORTEX_A9}" ]] && echo '=== Cortex A9 opts enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-cortexa9"
[[ "${ARM_HARDFLOAT}" ]] && echo '=== ARM hardfloat ABI enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-hardfloat"
[[ "${ARM_SOFTFLOAT}" ]] && echo '=== ARM softfloat ABI enabled... ===' && export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-softfloat"
[[ "${X86}" ]] && echo '=== x86 CPU detected... ==='
[[ "${X86}" ]] && [[ "${X86_64}" ]] && echo '=== x86_64 CPU detected... ==='
[[ "${IOS}" ]] && echo '=== iOS =='

echo "${FORMAT_COMPILER_TARGET}"
echo "${FORMAT_COMPILER_TARGET_ALT}"

check_opengl() {
   if [ "${BUILD_LIBRETRO_GL}" ]; then
      if [ "${ENABLE_GLES}" ]; then
         echo '=== OpenGL ES enabled ==='
         export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-gles"
         export FORMAT_COMPILER_TARGET_ALT="${FORMAT_COMPILER_TARGET}"
      else
         echo '=== OpenGL enabled ==='
         export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}-opengl"
         export FORMAT_COMPILER_TARGET_ALT="${FORMAT_COMPILER_TARGET}"
      fi
   else
      echo '=== OpenGL disabled in build ==='
   fi
}



build_libretro_fba_full() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-fba' ]; then
		echo '=== Building Final Burn Alpha (Full) ==='
      cd libretro-fba/
      cd svn-current/trunk

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f makefile.libretro platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean Final Burn Alpha'
      fi
      "${MAKE}" -f makefile.libretro platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Final Burn Alpha'
      cp "fb_alpha_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Final Burn Alpha not fetched, skipping ...'
   fi
}

build_libretro_fba_cps1()
{
   cd $BASE_DIR
   if [ -d "libretro-fba" ]; then
      echo "=== Building Final Burn Alpha Cores (CPS1) ==="
      cd libretro-fba/
      cd svn-current/trunk
      cd fbacores/cps1

      if [ -z "${NOCLEAN}" ]; then
         make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Final Burn Alpha Cores CPS1"
      fi
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Final Burn Alpha Cores CPS1"
      cp fba_cores_cps1_libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR/fba_cores_cps1_libretro$FORMAT.${FORMAT_EXT}
   fi
}

build_libretro_fba_cps2()
{
   cd $BASE_DIR
   if [ -d "libretro-fba" ]; then
      echo "=== Building Final Burn Alpha Cores (CPS2) ==="
      cd libretro-fba/
      cd svn-current/trunk
      cd fbacores/cps2

      if [ -z "${NOCLEAN}" ]; then
         make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Final Burn Alpha Cores CPS2"
      fi
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Final Burn Alpha Cores CPS2"
      cp fba_cores_cps2_libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR/fba_cores_cps2_libretro$FORMAT.${FORMAT_EXT}
   fi
}

build_libretro_fba_neogeo()
{
   cd $BASE_DIR
   if [ -d "libretro-fba" ]; then
      echo "=== Building Final Burn Alpha Cores (NeoGeo) ==="
      cd libretro-fba/
      cd svn-current/trunk
      cd fbacores/neogeo

      if [ -z "${NOCLEAN}" ]; then
         make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS clean || die "Failed to clean Final Burn Alpha Cores NeoGeo"
      fi
      make -f makefile.libretro platform=$FORMAT_COMPILER_TARGET -j$JOBS || die "Failed to build Final Burn Alpha Cores NeoGeo"
      cp fba_cores_neo_libretro$FORMAT.${FORMAT_EXT} $RARCH_DIST_DIR/fba_cores_neo_libretro$FORMAT.${FORMAT_EXT}
   fi
}


build_libretro_pcsx_rearmed_interpreter() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-pcsx-rearmed' ]; then
      echo '=== Building PCSX ReARMed Interpreter ==='
      cd libretro-pcsx-rearmed

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile.libretro platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean PCSX ReARMed'
      fi
      "${MAKE}" -f Makefile.libretro USE_DYNAREC=0 platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build PCSX ReARMed'
      cp "pcsx_rearmed_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/pcsx_rearmed_interpreter${FORMAT}.${FORMAT_EXT}"
   else
      echo 'PCSX ReARMed not fetched, skipping ...'
   fi
}



# $1 is corename
# $2 is Makefile name
# $3 is preferred platform
build_libretro_generic_makefile() {
   cd "${BASE_DIR}"
   if [ -d "libretro-${1}" ]; then
      echo "=== Building ${1} ==="
      cd libretro-${1}
      cd ${2}

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f ${3} platform="${4}" ${COMPILER} "-j${JOBS}" clean || die "Failed to build ${1}"
      fi
      "${MAKE}" -f ${3} platform="${4}" ${COMPILER} "-j${JOBS}" || die "Failed to build ${1}"
      cp "${1}_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo "${1} not fetched, skipping ..."
   fi
}

build_libretro_prosystem() {
   build_libretro_generic_makefile "prosystem" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_o2em() {
   build_libretro_generic_makefile "o2em" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_virtualjaguar() {
   build_libretro_generic_makefile "virtualjaguar" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_tgbdual() {
   build_libretro_generic_makefile "tgbdual" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_nx() {
   build_libretro_generic_makefile "nxengine" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_picodrive() {
   build_libretro_generic_makefile "picodrive" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_tyrquake() {
   build_libretro_generic_makefile "tyrquake" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_2048() {
   build_libretro_generic_makefile "2048" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_vecx() {
   build_libretro_generic_makefile "vecx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_stella() {
   build_libretro_generic_makefile "stella" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_bluemsx() {
   build_libretro_generic_makefile "bluemsx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_handy() {
   build_libretro_generic_makefile "handy" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_fmsx() { 
   build_libretro_generic_makefile "fmsx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_vba_next() {
   build_libretro_generic_makefile "vba_next" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_vbam() {
   build_libretro_generic_makefile "vbam" "src/libretro" "Makefile" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_snes9x_next() {
   build_libretro_generic_makefile "snes9x_next" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_dinothawr() {
   build_libretro_generic_makefile "dinothawr" "." "Makefile" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_genesis_plus_gx() {
   build_libretro_generic_makefile "genesis_plus_gx" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_mame078() {
   build_libretro_generic_makefile "mame078" "makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_prboom() {
   build_libretro_generic_makefile "prboom" "." "Makefile" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_pcsx_rearmed() {
   build_libretro_generic_makefile "pcsx_rearmed" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_fceumm() {
   build_libretro_generic_makefile "fceumm" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_snes() {
   build_libretro_generic_makefile "mednafen_snes" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_lynx() {
   build_libretro_generic_makefile "mednafen_lynx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_wswan() {
   build_libretro_generic_makefile "mednafen_wswan" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_gba() {
   build_libretro_generic_makefile "mednafen_gba" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_ngp() {
   build_libretro_generic_makefile "mednafen_ngp" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_pce_fast() {
   build_libretro_generic_makefile "mednafen_pce_fast" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_vb() {
   build_libretro_generic_makefile "mednafen_vb" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_pcfx() {
   build_libretro_generic_makefile "mednafen_pcfx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_psx() {
   build_libretro_generic_makefile "mednafen_psx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_beetle_supergrafx() {
   build_libretro_generic_makefile "mednafen_supergrafx" "." "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_meteor() {
   build_libretro_generic_makefile "meteor" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_nestopia() {
   build_libretro_generic_makefile "meteor" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_gambatte() {
   build_libretro_generic_makefile "gambatte" "libgambatte" "Makefile.libretro" ${FORMAT_COMPILER_TARGET_ALT}
}

build_libretro_yabause() {
   build_libretro_generic_makefile "yabause" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_desmume() {
   build_libretro_generic_makefile "desmume" "desmume" "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_snes9x() {
   build_libretro_generic_makefile "snes9x" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_quicknes() {
   build_libretro_generic_makefile "quicknes" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_dosbox() {
   build_libretro_generic_makefile "dosbox" "." "Makefile.libretro" ${FORMAT_COMPILER_TARGET}
}

build_libretro_ffmpeg() {
   check_opengl
   build_libretro_generic_makefile "ffmpeg" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
   # reset check_opengl
   export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}"
}

build_libretro_3dengine() {
   check_opengl
   build_libretro_generic_makefile "3dengine" "." "Makefile" ${FORMAT_COMPILER_TARGET}
   # reset check_opengl
   export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}"
}

build_libretro_scummvm() {
   build_libretro_generic_makefile "scummvm" "backends/platform/libretro/build" "Makefile" ${FORMAT_COMPILER_TARGET}
}

build_libretro_ppsspp() {
   check_opengl
   build_libretro_generic_makefile "ppsspp" "libretro" "Makefile" ${FORMAT_COMPILER_TARGET}
   # reset check_opengl
   export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}"
}

build_libretro_bsnes_cplusplus98() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes-cplusplus98' ]; then
      echo '=== Building bSNES C++98 ==='
      cd libretro-bsnes-cplusplus98

      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" clean || die 'Failed to clean bSNES C++98'
      fi
      "${MAKE}" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}"
      cp "out/libretro.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_cplusplus98_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo 'bSNES C++98 not fetched, skipping ...'
   fi
}

build_libretro_mame() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mame' ]; then
      echo ''
      echo '=== Building MAME ==='
      cd libretro-mame

      if [ "$IOS" ]; then
        echo '=== Building MAME (iOS) ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
        "${MAKE}" -f Makefile.libretro "TARGET=mame" platform="osx" ${COMPILER} "NATIVE=1" buildtools "-j${JOBS}" || die 'Failed to build MAME buildtools'
        "${MAKE}" -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} emulator "-j${JOBS}" || die 'Failed to build MAME (iOS)'
      elif [ "$X86_64" = "true" ]; then
        echo '=== Building MAME64 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
        "${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      else
        echo '=== Building MAME32 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
        "${MAKE}" -f Makefile.libretro "TARGET=mame" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      fi
      cp "mame_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'MAME not fetched, skipping ...'
   fi
}

build_libretro_mess() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mame' ]; then
      echo ''
      echo '=== Building MESS ==='
      cd libretro-mame

      if [ "$X86_64" = "true" ]; then
        echo '=== Building MESS64 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
	"${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      else
        echo '=== Building MESS32 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
	"${MAKE}" -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      fi
      cp "mess_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'MAME not fetched, skipping ...'
   fi
}

rebuild_libretro_mess() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mame' ]; then
      echo ''
      echo '=== Building MESS ==='
      cd libretro-mame

      if [ "$X86_64" = "true" ]; then
        echo '=== Building MESS64 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mess" "PARTIAL=1" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
        "${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      else
        echo '=== Building MESS32 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" -f Makefile.libretro "TARGET=mess" "PARTIAL=1" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
	"${MAKE}" -f Makefile.libretro "TARGET=mess" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      fi
      cp "mess_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'MAME not fetched, skipping ...'
   fi
}

build_libretro_ume() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mame' ]; then
      echo ''
      echo '=== Building UME ==='
      cd libretro-mame

      if [ "$X86_64" = "true" ]; then
        echo '=== Building UME64 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
	"${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      else
        echo '=== Building UME32 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
	fi
        "${MAKE}" -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      fi
      cp "ume_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'MAME not fetched, skipping ...'
   fi
}

rebuild_libretro_ume() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-mame' ]; then
      echo ''
      echo '=== Building MESS ==='
      cd libretro-mame

      if [ "$X86_64" = "true" ]; then
        echo '=== Building UME64 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=ume" "PARTIAL=1" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
	"${MAKE}" PTR64=1 -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      else
        echo '=== Building UME32 ==='
        if [ -z "${NOCLEAN}" ]; then
           "${MAKE}" -f Makefile.libretro "TARGET=ume" "PARTIAL=1" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" clean || die 'Failed to clean MAME'
        fi
	"${MAKE}" -f Makefile.libretro "TARGET=ume" platform="${FORMAT_COMPILER_TARGET}" ${COMPILER} "-j${JOBS}" || die 'Failed to build MAME'
      fi
      cp "ume_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'MAME not fetched, skipping ...'
   fi
}

build_libretro_bsnes_mercury() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes-mercury/perf' ]; then
      echo '=== Building bSNES Mercury performance ==='
      cd libretro-bsnes-mercury/perf
      
      if [ -z "${NOCLEAN}" ]; then
        rm -f obj/*.{o,"${FORMAT_EXT}"}
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="${CXX11}" ui='target-libretro' profile='performance' "-j${JOBS}" || die 'Failed to build bSNES Mercury performance core'
      cp -f "out/bsnes_mercury_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_mercury_performance_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo 'bSNES Mercury performance not fetched, skipping ...'
   fi

   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes-mercury/balanced' ]; then
      echo '=== Building bSNES Mercury balanced ==='
      cd libretro-bsnes-mercury/balanced
      
      if [ -z "${NOCLEAN}" ]; then
        rm -f obj/*.{o,"${FORMAT_EXT}"}
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="${CXX11}" ui='target-libretro' profile='balanced' "-j${JOBS}" || die 'Failed to build bSNES Mercury balanced core'
      cp -f "out/bsnes_mercury_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_mercury_balanced_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo 'bSNES Mercury compat not fetched, skipping ...'
   fi

   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes-mercury' ]; then
      echo '=== Building bSNES Mercury accuracy ==='
      cd libretro-bsnes-mercury
      
      if [ -z "${NOCLEAN}" ]; then
        rm -f obj/*.{o,"${FORMAT_EXT}"}
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="${CXX11}" ui='target-libretro' profile='accuracy' "-j${JOBS}" || die 'Failed to build bSNES Mercury accuracy core'
      cp -f "out/bsnes_mercury_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_mercury_accuracy_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo 'bSNES Mercury accuracy not fetched, skipping ...'
   fi
}

build_libretro_bsnes() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes/perf' ]; then
      echo '=== Building bSNES performance ==='
      cd libretro-bsnes/perf
      
      if [ -z "${NOCLEAN}" ]; then
        rm -f obj/*.{o,"${FORMAT_EXT}"}
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="${CXX11}" ui='target-libretro' profile='performance' "-j${JOBS}" || die 'Failed to build bSNES performance core'
      cp -f "out/bsnes_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_performance_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo 'bSNES performance not fetched, skipping ...'
   fi

   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes/balanced' ]; then
      echo '=== Building bSNES balanced ==='
      cd libretro-bsnes/balanced
      
      if [ -z "${NOCLEAN}" ]; then
      	rm -f obj/*.{o,"${FORMAT_EXT}"}
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="${CXX11}" ui='target-libretro' profile='balanced' "-j${JOBS}" || die 'Failed to build bSNES balanced core'
      cp -f "out/bsnes_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_balanced_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo 'bSNES compat not fetched, skipping ...'
   fi

   cd "${BASE_DIR}"
   if [ -d 'libretro-bsnes' ]; then
      echo '=== Building bSNES accuracy ==='
      cd libretro-bsnes
      if [ -z "${NOCLEAN}" ]; then
      	rm -f obj/*.{o,"${FORMAT_EXT}"}
      fi
      "${MAKE}" -f Makefile platform="${FORMAT_COMPILER_TARGET}" compiler="${CXX11}" ui='target-libretro' profile='accuracy' "-j${JOBS}" || die 'Failed to build bSNES accuracy core'
      cp -f "out/bsnes_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bsnes_accuracy_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo 'bSNES accuracy not fetched, skipping ...'
   fi
}

build_libretro_bnes() {
   cd "${BASE_DIR}"
   if [ -d 'libretro-bnes' ]; then
      echo '=== Building bNES ==='
      cd libretro-bnes

      mkdir -p obj
      if [ -z "${NOCLEAN}" ]; then
         "${MAKE}" -f Makefile "-j${JOBS}" clean || die 'Failed to clean bNES'
      fi
      "${MAKE}" -f Makefile ${COMPILER} "-j${JOBS}" compiler="${CXX11}" || die 'Failed to build bNES'
      cp "libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}/bnes_libretro${FORMAT}.${FORMAT_EXT}"
   else
      echo 'bNES not fetched, skipping ...'
   fi
}

build_libretro_mupen64() {
   check_opengl
   cd "${BASE_DIR}"
   if [ -d 'libretro-mupen64plus' ]; then
      cd libretro-mupen64plus

      mkdir -p obj
      if [ "${X86}" ] && [ "${X86_64}" ]; then
         echo '=== Building Mupen 64 Plus (x86_64 dynarec) ==='
         if [ -z "${NOCLEAN}" ]; then
            "${MAKE}" WITH_DYNAREC='x86_64' platform="${FORMAT_COMPILER_TARGET_ALT}" "-j${JOBS}" clean || die 'Failed to clean Mupen 64 (x86_64 dynarec)'
         fi
         "${MAKE}" WITH_DYNAREC='x86_64' platform="${FORMAT_COMPILER_TARGET_ALT}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Mupen 64 (x86_64 dynarec)'
      elif [ "${X86}" ]; then
         echo '=== Building Mupen 64 Plus (x86 32bit dynarec) ==='
         if [ -z "${NOCLEAN}" ]; then
            "${MAKE}" WITH_DYNAREC='x86' platform="${FORMAT_COMPILER_TARGET_ALT}" "-j${JOBS}" clean || die 'Failed to clean Mupen 64 (x86 dynarec)'
         fi
         "${MAKE}" WITH_DYNAREC='x86' platform="${FORMAT_COMPILER_TARGET_ALT}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Mupen 64 (x86 dynarec)'
      elif [ "${CORTEX_A8}" ] || [ "${CORTEX_A9}" ] || [ "${IOS}" ]; then
         echo '=== Building Mupen 64 Plus (ARM dynarec) ==='
         if [ -z "${NOCLEAN}" ]; then
            "${MAKE}" WITH_DYNAREC='arm' platform="${FORMAT_COMPILER_TARGET_ALT}" "-j${JOBS}" clean || die 'Failed to clean Mupen 64 (ARM dynarec)'
         fi
	 "${MAKE}" WITH_DYNAREC='arm' platform="${FORMAT_COMPILER_TARGET_ALT}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Mupen 64 (ARM dynarec)'
      else
         echo '=== Building Mupen 64 Plus ==='
         if [ -z "${NOCLEAN}" ]; then
            "${MAKE}" "-j${JOBS}" clean || die 'Failed to clean Mupen 64'
         fi
	 "${MAKE}" platform="${FORMAT_COMPILER_TARGET_ALT}" ${COMPILER} "-j${JOBS}" || die 'Failed to build Mupen 64'
      fi
      cp "mupen64plus_libretro${FORMAT}.${FORMAT_EXT}" "${RARCH_DIST_DIR}"
   else
      echo 'Mupen64 Plus not fetched, skipping ...'
   fi
   # reset check_opengl
   export FORMAT_COMPILER_TARGET="${FORMAT_COMPILER_TARGET}"
}

create_dist_dir() {
   if [ -d "${RARCH_DIST_DIR}" ]; then
      echo "Directory ${RARCH_DIST_DIR} already exists, skipping creation..."
   else
      mkdir -p "${RARCH_DIST_DIR}"
   fi
}

create_dist_dir
