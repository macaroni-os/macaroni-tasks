#!/bin/bash
# Description: In order to have the right blos file name in the
#              distfiles directory of the CDN we need to create
#              an hardlink to the file *.blob and rename it without
#              the extension because Portage doesn't use the extention.

metatools_workspace=${metatools_workspace:-${HOME}/repo_tmp}
metatools_blosdir=${metatools_workspace}/stores/blos

# Note: metatools blos directory MUST be in the same filesystem
#       of the CDN local directory. We use hardlink.
cdn77_localsyncdir=${HOME}/cdn77/blos/

mkdir -p ${cdn77_localsyncdir}

pushd ${metatools_blosdir}

for blosfile in $(find . -name *.blob) ; do
  dir=$(dirname ${blosfile})
  blos=$(basename ${blosfile})

  mkdir -p ${cdn77_localsyncdir}/${dir} 2>/dev/null
  #echo ${dir} ${blos/.blob}
  sourcepath=$(realpath ${metatools_blosdir}/${dir}/${blos})
  targetpath=$(realpath ${cdn77_localsyncdir}/${dir}/${blos/.blob})

  echo ${targetpath}
  if [ ! -e ${targetpath} ] ; then
    ln ${sourcepath} ${targetpath}
  fi

done

echo "[structure]
0=content-hash SHA512 8:8:8
1=flat" > ${cdn77_localsyncdir}/layout.conf


popd
