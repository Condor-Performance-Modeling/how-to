#! /bin/bash
# ------------------------------------------------------------------------
#
# This is for expansion of future repos. Only CPM_DOCS is built 
#
# Uses:  CONDOR_TOP CPM_DOCS
#
# Clones/builds
#    cpm documents repo
#
# ------------------------------------------------------------------------
set -euo pipefail

if [[ -z "${CONDOR_TOP}" ]]; then
  echo "-E: CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"
  exit 1
fi

if [[ -z "${CPM_DOCS}" ]]; then
  echo "-E: CPM_DOCS is undefined, execute 'source how-to/env/setuprc.sh'"
  exit 1
fi

source "${CONDOR_TOP}/how-to/scripts/git_clone_retry.sh"

# ----------------------------------------------------------------------
# Documents
# ----------------------------------------------------------------------
cd "${CONDOR_TOP}"

if ! [ -d "${CPM_DOCS}" ]; then
  echo "-W: 'documents' does not exist, cloning repo."
  clone_repository_with_retries "git@github.com:Condor-Performance-Modeling/documents.git ${CPM_DOCS}"
fi

# ----------------------------------------------------------------------
# ----------------------------------------------------------------------
cd "${CONDOR_TOP}"
