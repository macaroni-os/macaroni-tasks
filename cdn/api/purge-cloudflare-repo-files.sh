# Author: Daniele Rondina, geaaru@gmail.com
# Description: Execute purge of the repositories metadata to force updates.

cdn_dir=$(dirname ${BASH_SOURCE[0]})/..
tmp_yaml=/tmp/cdn-purge.yaml
tmp_json=/tmp/cdn-purge.json

CDN_IMAGESFILE="${CDN_IMAGESFILE:-${cdn_dir}/cdn-images.values}"
CDN_APIURL="https://api.cloudflare.com"

NAME="${NAME:-}"

main () {

  if [ -z "${NAME}" ] ; then
    echo "Missing NAME!"
    return 1
  fi

  if [ -z "${CDN_TOKEN}" ] ; then
    echo "Missing CDN_TOKEN!"
    return 1
  fi

  if [ -z "${CLOUDFLARE_ZONEID}" ] ; then
    echo "Missing CLOUDFLARE_ZONEID!"
    return 1
  fi

  namespace_data=$(yq r ${CDN_IMAGESFILE} -j | jq ".values.namespaces[] | select(.name == \"${NAME}\") " )

  if [ -z "${namespace_data}" ] ; then
    echo "No entry found in ${CDN_IMAGESFILE} to purge. Exiting."
    return 0
  fi

  # Create the json payload
  rm -f ${tmp_yaml} || true
  touch ${tmp_yaml}
  files=$(echo ${namespace_data} | jq '.purgefiles.paths | length')

  if [ "${files}" == "0" ] ; then
    echo "No files to purge. Exiting."
    return 0
  fi

  DOMAIN="$(echo ${namespace_data} | jq '.domain' -r)"
  NAMESPACE="$(echo ${namespace_data} | jq '.namespace' -r)"
  CDN_PREFIX="$(echo ${namespace_data} | jq '.cdnprefix' -r)"

  for ((i=0; i<${files}; i++)) ; do
    file=$(echo "${namespace_data}" | jq ".purgefiles.paths[${i}]" -r)
    yq w -i ${tmp_yaml} "files[${i}]" "https://${DOMAIN}${CDN_PREFIX}${NAMESPACE}/${file}"
  done

  yq r ${tmp_yaml} -j > ${tmp_json}

  cat ${tmp_json}

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
      ${CDN_APIURL}/client/v4/zones/${CLOUDFLARE_ZONEID}/purge_cache
  )

  if [[ "$status_code" -ne 200 ]] && [[ $status_code -ne 201 ]] && [[ $status_code -ne 202 ]]; then
    echo "Error on purge files from CDN ($status_code)."
    return 1
  else
    echo "CDN files of the repo ${NAME} ($NAMESPACE) purged."
  fi

  rm ${tmp_json} ${tmp_yaml}

  return 0
}


main
exit $?

