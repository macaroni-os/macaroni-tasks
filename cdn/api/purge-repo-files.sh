#!/bin/bash
# Author: Daniele Rondina, geaaru@macaronios.org
# Description: Execute purge of the repositories metadata to
#              force updates.

cdn_dir=$(dirname ${BASH_SOURCE[0]})/..
tmp_yaml=/tmp/cdn-purge.yaml
tmp_json=/tmp/cdn-purge.json

CDN_IMAGESFILE="${CDN_IMAGESFILE:-${cdn_dir}/cdn-images.values}"
NAME="${NAME:-}"

if [ -n "${DEBUG}" ] ; then
  set -x
fi

main () {

  if [ -z "${NAME}" ] ; then
    echo "Missing NAME!"
    return 1
  fi

  namespace_data=$(yq r ${CDN_IMAGESFILE} -j | jq ".values.namespaces[] | select(.name == \"${NAME}\") " )

  if [ -z "${namespace_data}" ] ; then
    echo "No entry found in ${CDN_IMAGESFILE} to purge. Exiting."
    return 0
  fi

  nfiles=$(echo ${namespace_data} | jq '.purgefiles.paths | length')
  if [ "${nfiles}" == "0" ] ; then
    echo "No files to purge. Exiting."
return 0
  fi
  files=$(echo ${namespace_data} | jq '.purgefiles.paths[]' -r)

  nservices=$(echo ${namespace_data} | jq '.cdn_services | length')
  services=$(echo ${namespace_data} | jq '.cdn_services')
  namespace=$(echo ${namespace_data} | jq ".namespace" -r)

  if [ "${nservices}" == 0 ] ; then
    echo "No CDN Services available. Exiting."
    return 0
  fi

  local cdntype=""
  local domain=""
  local cdnid=""
  local cdnprefix=""
  local repopath=""
  local script=""
  local
  for ((i=0; i<${nservices};i++)) ; do
    cdntype=$(echo ${services} | jq -r ".[${i}].type")
    cdnprefix=$(echo ${services} | jq -r ".[${i}].cdnprefix")
    domain=$(echo ${services} | jq -r ".[${i}].domain")
    repopath=$(echo ${services} | jq -r ".[${i}].repopath")

    if [ "${repopath}" == "null" ] ; then
      repopath="${namespace}"
    fi

    echo "Purging service ${cdntype} for domain ${domain}..."
    if [ "$cdntype" = "cdn77" ] ; then
      cdnid=$(echo ${services} | jq -r ".[${i}].cdnid")
      script=$(dirname ${BASH_SOURCE[0]})/purge-cdn77-repo-files.sh

    else
      # POST: Cloudflare CDN
      script=$(dirname ${BASH_SOURCE[0]})/purge-cloudflare-repo-files.sh
      cdnid=""
    fi

    NAME=${NAME} CDN_FILES="${files}" \
      NAMESPACE="${repopath}" \
      CDN_DOMAIN="${domain}" \
      CDN_PREFIX="${cdnprefix}" \
      CDN_ID="${cdnid}" \
      $script || {
        echo "Error on purge domain ${domain} of type ${cdntype}"
        exit 1
      }
  done

  return 0
}


main
exit $?

