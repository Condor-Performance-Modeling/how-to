#! /bin/bash

set -euo pipefail


# -------------------------------------------------------------
update_progress() {
    echo "${1}" >> "${PROGRESS_FILE}"
}
# -------------------------------------------------------------
safe_export_path_chk() {
    local path_to_add="${1}"

    if [[ -z "${path_to_add}" ]]; then
        echo "-E: No path provided to safe_export_path_chk."
        exit 1
    fi

    if [[ ! -d "${path_to_add}" ]]; then
        echo "-E: Missing required path: ${path_to_add}"
        exit 1
    fi

    case ":${PATH}:" in
        *":${path_to_add}:"*)
            # Path already present, do nothing
            ;;
        *)
            export PATH="${path_to_add}:${PATH}"
            ;;
    esac
}

# -------------------------------------------------------------
# Pop/pushd cleanup on exit
# -------------------------------------------------------------
cleanup() {
    if [[ "${PUSHED_DIR:-}" == "true" ]]; then
        popd > /dev/null || true
    fi
}
trap cleanup EXIT

# -------------------------------------------------------------
# Main
# -------------------------------------------------------------
# Stupidly, conda requires us to do this, initialize it within
# the script and then deactivate it.
# -------------------------------------------------------------
if [[ -n "${CONDA_DEFAULT_ENV:-}" ]]; then
  echo "-E: You must exit conda before running this script"
  echo "-E: Use 'conda deactivate' until you fully exit the conda environment" 
  echo "-E: Your prompt should not include (base) or (sparta)"
  exit 1
fi

if [[ -z "${CONDOR_TOP}" ]]; then
  echo "-E: CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"
  exit 1
fi

PROGRESS_FILE="${CONDOR_TOP}/.onboarding_env_setup_progress"

if [[ -z "${RV_ANDES_GNU_BAREMETAL_TOOLS}" ]]; then
  echo "-E: RV_ANDES_GNU_BAREMETAL_TOOLS is undefined, execute 'source how-to/env/setuprc.sh'"
  exit 1
fi

if [[ -z "${CPM_ANDES_SPIKE_DIR}" ]]; then
  echo "-E: CPM_ANDES_SPIKE_DIR is undefined, execute 'source how-to/env/setuprc.sh'"
  exit 1
fi

if [[ -z "${TOOLS}" ]]; then
  echo "-E: TOOLS is undefined, execute 'source how-to/env/setuprc.sh'"
  exit 1
fi

safe_export_path_chk "${RV_ANDES_GNU_BAREMETAL_TOOLS}/bin"

# In case the above fails, some how
if ! command -v "riscv64-unknown-elf-gcc" > /dev/null; then
  echo "-E: RISC-V cross-compiler riscv64-unknown-elf-gcc was not found in PATH."
  echo "-E: Please ensure it is in your PATH, for example:"
  echo "export PATH=\$RV_ANDES_GNU_BAREMETAL_TOOLS/bin:\$PATH"
  exit 1
fi

source "${CONDOR_TOP}/how-to/scripts/git_clone_retry.sh"

cd "${CONDOR_TOP}"

mkdir -p "${TOOLS}/bin"

echo "Building CPM Andes Spike"

if ! [[ -d "${CPM_ANDES_SPIKE_DIR}" ]]; then
  echo "-W: ${CPM_ANDES_SPIKE_DIR} does not exist, cloning repo."
  clone_repository_with_retries "git@github.com:Condor-Performance-Modeling/cpm.andes.riscv-isa-sim.git" "${CPM_ANDES_SPIKE_DIR}" "--recurse-submodules"
fi

PUSHED_DIR="true"
pushd "${CPM_ANDES_SPIKE_DIR}" > /dev/null

mkdir -p build install
cd build

../configure --prefix="$(pwd)/../install"
make -j"$(nproc)"
make install
make regress

update_progress "cpm_andes_spike_installed"

echo
echo "CPM Andes Spike installed successfully"
