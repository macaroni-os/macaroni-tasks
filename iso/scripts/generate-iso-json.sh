#!/bin/bash
# Author: Daniele Rondina, geaaru@funtoo.org
# Description: This script permit to generate the JSON
#              with the list of the ISOs available in Mottainai.

MOTTAINAI_CLI_PROFILE=${MOTTAINAI_CLI_PROFILE:-funtoo}
ISO_JSONFILE=${ISO_JSONFILE:-/tmp/isos.json}

isospec_dir=$(dirname ${BASH_SOURCE[0]})/..
ISOS=$(yq r ${isospec_dir}/iso-images.values 'values.isos' -l)
RELEASES=$(yq r ${isospec_dir}/iso-images.values 'values.releases' -l)

isotmp_yaml="${isotmp_yaml:-/tmp/isos.yaml}"

touch ${isotmp_yaml}

export MOTTAINAI_CLI_PROFILE

parse_iso_metadata() {
  local iso=$1
  local name=$2
  local isoname=$(yq r iso/iso-meta.yaml "iso")
  local isosha=$(yq r iso/iso-meta.yaml "sha256")
  local date=$(yq r iso/iso-meta.yaml "date")
  local size=$(yq r iso/iso-meta.yaml "size")

  yq w -i ${isotmp_yaml} "isos[${iso}].name" "${name}"
  yq w -i ${isotmp_yaml} "isos[${iso}].iso" "${isoname}"
  yq w -i ${isotmp_yaml} "isos[${iso}].sha256" "${isosha}"
  yq w -i ${isotmp_yaml} "isos[${iso}].date" "${date}"
  yq w -i ${isotmp_yaml} "isos[${iso}].size" "${size}"

  return 0
}

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

    parse_iso_metadata "${iso}" "${name}"

    iso=$((iso+1))

    rm -rf iso/

  else

    echo "Skipping ISO ${name}!"

  fi

  # Parse every release namespace if available
  j=0
  for ((j=0;j<$RELEASES;j++))
  do

    release=$(yq r ${isospec_dir}/iso-images.values "values.releases[$j]")
    echo "Analyzing ${name}-${release}..."

    # Download iso-meta.yaml from Mottainai
    if [ -n "${DEBUG}" ] ; then
      mottainai-cli namespace download "iso-${name}-${release}" iso -f '.yaml$'
    else
      mottainai-cli namespace download "iso-${name}-${release}" iso -f '.yaml$' 2>&1 > /dev/null
    fi

    if [ -e iso/iso-meta.yaml ] ; then

      parse_iso_metadata "${iso}" "${name}-${release}"

      iso=$((iso+1))

      rm -rf iso/

    else

      echo "Skipping ISO ${name}-${release}!"

    fi

  done
done

# Generate JSON from yaml
yq r ${isotmp_yaml} -j > ${ISO_JSONFILE}

rm ${isotmp_yaml}

cat ${ISO_JSONFILE} | jq
