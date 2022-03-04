#!/bin/bash
# Author: Daniele Rondina, geaaru@funtoo.org
# Description: Execute purge of the repositories metadata to
#              force updates.

cdn_dir=$(dirname ${BASH_SOURCE[0]})/..
tmp_yaml=/tmp/cdn-purge.yaml
tmp_json=/tmp/cdn-purge.json

CDN_PREFIX="${CDN_PREFIX:-/www/mottainai/}"
CDN_IMAGESFILE="${CDN_IMAGESFILE:-${cdn_dir}/cdn-images.values}"
CDN_APIURL="https://api.cdn77.com/v3"
NAMESPACE="${NAMESPACE:-macaroni-funtoo}"

main () {

  if [ -z "${NAMESPACE}" ] ; then
    echo "Missing NAMESPACE!"
    return 1
  fi

  if [ -z "${CDN_TOKEN}" ] ; then
    echo "Missing CDN_TOKEN!"
    return 1
  fi

  namespace_data=$(yq r ${CDN_IMAGESFILE} -j | jq ".values.namespaces[] | select(.name == \"${NAMESPACE}\") " )
  # Create the json payload
  rm -f ${tmp_yaml} || true
  touch ${tmp_yaml}
  files=$(echo ${namespace_data} | jq '.purgefiles.paths | length')

  if [ "${files}" == "0" ] ; then
    echo "No files to purge. Exiting."
    return 0
  fi

  for ((i=0; i<${files}; i++)) ; do
    file=$(echo "${namespace_data}" | jq ".purgefiles.paths[${i}]" -r)
    yq w -i ${tmp_yaml} "paths[${i}]" "${CDN_PREFIX}${NAMESPACE}/${file}"
  done

  yq r ${tmp_yaml} -j > ${tmp_json}

  # Retrieve cdn resource id
  cdnid=$(yq r ${CDN_IMAGESFILE} -j | jq ".values.namespaces[] | select(.name == \"${NAMESPACE}\") | .cdnid " -r)

  status_code=$(
    curl \
      -X POST \
      -H "Content-Type: application/json" \
      --header "Authorization: Bearer ${CDN_TOKEN}" \
      -w "%{http_code}" \
      -s \
      -k \
      -d @${tmp_json} \
      -o /dev/null \
      ${CDN_APIURL}/cdn/${cdnid}/job/purge
  )

  if [[ "$status_code" -ne 200 ]] && [[ $status_code -ne 201 ]] && [[ $status_code -ne 202 ]]; then
    echo "Error on purge files from CDN ($status_code)."
    return 1
  else
    echo "CDN files of the repo ${NAMESPACE} completed."
  fi

  rm ${tmp_json} ${tmp_yaml}

  return 0
}


main
exit $?

