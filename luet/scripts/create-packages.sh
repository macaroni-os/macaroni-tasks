#!/bin/bash
# Description: Create the pipeline of the tasks to build Macaroni OS packages.
#              This script works only for Mottainai based workflow.
# Author: Daniele Rondina, geaaru@funtoo.org

set -e

if [ -n "$DEBUG" ] ; then set -x ; fi

luet_dir=$(dirname ${BASH_SOURCE[0]}})/..
luet_values=${luet_dir}/luet-repo.values
luet_trees_opts=""

ENABLE_DOCKER_HOST=${ENABLE_DOCKER_HOST:-true}
ENABLE_BUILDKIT=${ENABLE_BUILDKIT:-false}
PUSH_IMAGES=${PUSH_IMAGES:-false}
FIRE_TASK=${FIRE_TASK:-0}
TREE_VERSION=${TREE_VERSION:-v1}

TEMPLATES_DIR=${luet_dir}/templates

LUET_REPOSITORY=${LUET_REPOSITORY:-""}
TREE="${TREE:-packages}"
MOTTAINAI_CLI_PROFILE="${MOTTAINAI_CLI_PROFILE:-funtoo}"
LUET_REPODEVKIT_OPTS="${LUET_REPODEVKIT_OPTS:---build-ordered --build-ordered-with-resolve}"
LUET_REPODEVKIT_FILTER="${LUET_REPODEVKIT_FILTER:-}"

tmp_packages_files="/tmp/packages.yaml"

if [ -n "${LUET_REPOSITORY}" ] ; then
  luet_trees_opts="$luet_trees_opts -t ${LUET_REPOSITORY}/${TREE}"
else
  luet_trees_opts="$luet_trees_opts -t ${TREE}"
fi

echo "
========================================
Mottainai Namespace: ${NAMESPACE}
Luet Repo Devkit Tree: ${TREE}
Luet Repo Devkit Filters: ${LUET_REPODEVKIT_FILTER}
Luet Repo Devkit Options: ${LUET_REPODEVKIT_OPTS}
Luet Repository: ${LUET_REPOSITORY}
========================================
"

main () {

  if [ -z "${MOTTAINAI_CLI_PROFILE}" ] ; then
    echo "Missng MOTTAINAI_CLI_PROFILE env variable"
    exit 1
  fi

  if [ -z "${NAMESPACE}" ] ; then
    echo "Missing NAMESPACE env variable."
    echo "Normally this variable is equal to repository name."
    exit 1
  fi

  isvalid=$(yq r ${luet_values} -j | jq ".values.repositories[] | select(.name==\"${NAMESPACE}\") | length")
  if [ "${isvalid}" == "0" ] ; then
    echo "Selected repository not defined on luet-repo.values file."
    exit 1
  fi

  repo=$(yq r ${luet_values} -j | jq ".values.repositories[] | select(.name==\"${NAMESPACE}\") | .http_repo" -r)
  repo_branch=$(yq r ${luet_values} -j | jq ".values.repositories[] | select(.name==\"${NAMESPACE}\") | .branch" -r)

  luet-repo-devkit pkgs ${luet_trees_opts} \
    --backend mottainai  \
    --mottainai-profile ${MOTTAINAI_CLI_PROFILE} \
    --mottainai-namespace ${NAMESPACE} \
    --missings ${LUET_REPODEVKIT_OPTS} ${LUET_REPODEVKIT_FILTER} \
    --json | jq 'to_entries[]' -s | \
    jq '. | ."values"."packages" = .value | del(.key, .value)' | yq r -P - > ${tmp_packages_files}


  n_packages=$(yq r ${tmp_packages_files} 'values.packages'  -j | jq '. | length')

  if [ "$n_packages" != "0" ] ; then

    opts=""

    if [ -n "$GROUP_PIPELINE" ] ; then
      opts="-s group=true"
    fi

    mkdir /tmp/macaroni -p || true

    # Create pipeline
    if [ "${TREE_VERSION}" = "v2" ] ; then

      mottainai-cli task compile \
        ${TEMPLATES_DIR}/luet-pkgs-pipelinev2.tmpl -l ${tmp_packages_files} \
        -s "namespace=${NAMESPACE}" $opts \
        -s "repo=${LUET_REPOSITORY}" \
        -s repo="${repo}" \
        -s branch="${repo_branch}" \
        -s enable_docker_host="${ENABLE_DOCKER_HOST}" \
        -s enable_buildkit="${ENABLE_BUILDKIT}" \
        -s push_images="${PUSH_IMAGES}" \
        -o /tmp/macaroni/luet-pkgs-pipeline.yaml || {
        echo "Error on compile pipeline."
        return 1
      }
    else
      mottainai-cli task compile \
        ${TEMPLATES_DIR}/luet-pkgs-pipeline.tmpl -l ${tmp_packages_files} \
        -s "namespace=${NAMESPACE}" $opts \
        -s "repo=${LUET_REPOSITORY}" \
        -s repo="${repo}" \
        -s branch="${repo_branch}" \
        -s enable_docker_host="${ENABLE_DOCKER_HOST}" \
        -s enable_buildkit="${ENABLE_BUILDKIT}" \
        -s push_images="${PUSH_IMAGES}" \
        -o /tmp/macaroni/luet-pkgs-pipeline.yaml || {
        echo "Error on compile pipeline."
        return 1
      }
    fi

    echo "Building packages:"
    cat /tmp/macaroni/luet-pkgs-pipeline.yaml | \
      grep PACKAGES  --color=none | \
      awk '{ print $2 }' | \
      sed -e 's/"PACKAGES=//' -e 's/"//'


    if [ -z "${SKIP_FIRE}" ] ; then
      mottainai-cli pipeline create --yaml /tmp/macaroni/luet-pkgs-pipeline.yaml
    fi

    if [ -z "${SKIP_CLEAN}" ] ; then
      rm /tmp/macaroni/luet-pkgs-pipeline.yaml
    fi

  else
    echo "No new packages found. Nothing to do."
  fi

  return 0
}

main $@
exit $?
