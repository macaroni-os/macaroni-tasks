#!/bin/bash
# Author: Daniele Rondina, geaaru@macaronios.org
# Description: Tag all kits of a stable release.

KITS_REPO_PREFIX=${KITS_REPO_PREFIX:-https://github.com/macaroni-os}
MARK_TAG=${MARK_TAG:-""}
MARK_BRANCH=${MARK_BRANCH:-""}
WORKDIR=${WORKDIR:-/}
DRYRUN=${DRYRUN:-0}

if [ -n "${DEBUG}" ] ; then
  set -x
fi

tag_kit() {
  local kit=$1
  local repodir=${WORKDIR}/kits/${kit}
  local gitrepo=${KITS_REPO_PREFIX}/${kit}.git

  git clone ${gitrepo} -b ${MARK_BRANCH} ${repodir} || {
    echo "Error on clone repository ${gitrepo}!"
    return 1
  }

  pushd ${repodir}
  echo "Tagging ${MARK_TAG} on branch ${MARK_BRANCH} for repo ${gitrepo}..."
  git tag ${MARK_TAG}

  if [ "${DRYRUN}" != 1 ] ; then
    git push --tags
  fi
  popd

  return 0
}

main() {
  if [ -z "${KITS_REPO_PREFIX}" ] ; then
    echo "Invalid kits prefix URL!"
    return 1
  fi

  if [ -z "${KITS}" ] ; then
    echo "Invalid kits list"
    return 1
  fi

  if [ -z "${MARK_TAG}" ] ; then
    echo "No MARK tag defined!"
    return 1
  fi

  if [ -z "${MARK_BRANCH}" ] ; then
    echo "No MARK Branch defined!"
    return 1
  fi

  mkdir ${WORKDIR}kits

  for kit in ${KITS} ; do
    tag_kit ${kit} || {
      echo "Error on tag kit ${kit}!"
      return 1
    }
  done

  return 0
}


main $@
exit $?
