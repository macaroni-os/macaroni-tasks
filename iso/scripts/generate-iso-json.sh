#!/bin/bash
# Author: Daniele Rondina, geaaru@funtoo.org
# Description: This script permit to generate the JSON
#              with the list of the ISOs available in Mottainai.

MOTTAINAI_CLI_PROFILE=${MOTTAINAI_CLI_PROFILE:-funtoo}
ISO_JSONFILE=${ISO_JSONFILE:-/tmp/isos.json}

isospec_dir=$(dirname ${BASH_SOURCE[0]})/..
ISOS=$(yq r ${isospec_dir}/iso-images.values 'values.isos' -l)

isotmp_yaml="${isotmp_yaml:-/tmp/isos.yaml}"

touch ${isotmp_yaml}

export MOTTAINAI_CLI_PROFILE

iso=0
# Creating a YAML file with all ISOs availables
for ((i=0;i<$ISOS;i++))
do
  name=$(yq r ${isospec_dir}/iso-images.values "values.isos[$i].name")

  echo "Processing data of ISO ${name}..."

  # Download iso-meta.yaml from Mottainai
  if [ -n "${DEBUG}" ] ; then
    mottainai-cli namespace download "iso-${name}" iso -f '.yaml$'
  else
    mottainai-cli namespace download "iso-${name}" iso -f '.yaml$' 2>&1 > /dev/null
  fi

  if [ -e iso/iso-meta.yaml ] ; then

    isoname=$(yq r iso/iso-meta.yaml "iso")
    isosha=$(yq r iso/iso-meta.yaml "sha256")
    date=$(yq r iso/iso-meta.yaml "date")
    size=$(yq r iso/iso-meta.yaml "size")

    yq w -i ${isotmp_yaml} "isos[${iso}].name" "${name}"
    yq w -i ${isotmp_yaml} "isos[${iso}].iso" "${isoname}"
    yq w -i ${isotmp_yaml} "isos[${iso}].sha256" "${isosha}"
    yq w -i ${isotmp_yaml} "isos[${iso}].date" "${date}"
    yq w -i ${isotmp_yaml} "isos[${iso}].size" "${size}"

    iso=$((iso+1))

    rm -rf iso/

  else

    echo "Skipping ISO ${name}!"

  fi

done

# Generate JSON from yaml
yq r ${isotmp_yaml} -j > ${ISO_JSONFILE}

rm ${isotmp_yaml}

cat ${ISO_JSONFILE} | jq
