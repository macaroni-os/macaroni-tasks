# Author: Daniele Rondina, geaaru@macaronios.org
# Description: Execute purge of the repositories metadata to force updates
#              of the Cloudflare CDN.

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

  if [ -z "${CLOUDFLARE_TOKEN}" ] ; then
    echo "Missing CLOUDFLARE_TOKEN!"
    return 1
  fi

  if [ -z "${CLOUDFLARE_ZONEID}" ] ; then
    echo "Missing CLOUDFLARE_ZONEID!"
    return 1
  fi

  if [ -z "${CDN_FILES}" ] ; then
    echo "Missing CDN_FILES!"
    return 1
  fi

  if [ -z "${CDN_DOMAIN}" ] ; then
    echo "Missing CDN_DOMAIN!"
    return 1
  fi

  # Create the json payload
  rm -f ${tmp_yaml} || true
  touch ${tmp_yaml}

  local i=0
  for file in ${CDN_FILES} ; do
    yq w -i ${tmp_yaml} "files[${i}]" "https://${CDN_DOMAIN}${CDN_PREFIX}${NAMESPACE}/${file}"
    let i++
  done

  yq r ${tmp_yaml} -j > ${tmp_json}

  cat ${tmp_json}

  status_code=$(
    curl \
      -X POST \
      -H "Content-Type: application/json" \
      --header "Authorization: Bearer ${CLOUDFLARE_TOKEN}" \
      -w "%{http_code}" \
      -s \
      -k \
      -d @${tmp_json} \
      -o /dev/null \
      ${CDN_APIURL}/client/v4/zones/${CLOUDFLARE_ZONEID}/purge_cache
  )

  if [[ "$status_code" -ne 200 ]] && [[ $status_code -ne 201 ]] && [[ $status_code -ne 202 ]]; then
    echo "Error on purge files from CDN of the doamin ${CDN_DOMAIN} ($status_code)."
    return 1
  else
    echo "CDN files of the repo ${NAME} ($NAMESPACE) related to the ${CDN_DOMAIN} is been purged."
  fi

  #rm ${tmp_json} ${tmp_yaml}

  return 0
}


main
exit $?

