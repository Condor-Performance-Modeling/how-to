#! /bin/bash
# -------------------------------------------------------------
# Uses CONDOR_TOP RV_ANDES_GNU_BAREMETAL_TOOLS CPM_ANDES_SPIKE_DIR 
#      TOOLS WHISPER_DIR
#
# Checks/Requires that conda not be active
#
# Checks/Requires for proper link to andes compiler
#
# Clones and builds the CPM fork of Spike with Andes V5
#      cpm.andes.riscv-isa-sim
# Clones and builds the public tenstorrent whisper
#      tenstorrent.whisper
#
# FIXME: rename script to reflect addition of whisper
# -------------------------------------------------------------
set -euo pipefail

# -------------------------------------------------------------
# Update the progress file
# -------------------------------------------------------------
update_progress() {
    echo "${1}" >> "${PROGRESS_FILE}"
}
# -------------------------------------------------------------
# Pre-pend path to PATH if is does not already exist
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
# CHECKS
# -------------------------------------------------------------
if [[ -n "${CONDA_DEFAULT_ENV:-}" ]]; then
  echo "-E: You must exit conda before running this script"
  echo "-E: Use 'conda deactivate' until you fully exit the conda environment" 
  echo "-E: Your prompt should not include (base) or (sparta)"
  exit 1
fi

# CONDOR_TOP
if [[ -z "${CONDOR_TOP}" ]]; then
  echo "-E: CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"
  exit 1
fi

PROGRESS_FILE="${CONDOR_TOP}/.onboarding_env_setup_progress"

# RV_ANDES_GNU_BAREMETAL_TOOLS
if [[ -z "${RV_ANDES_GNU_BAREMETAL_TOOLS}" ]]; then
  echo "-E: RV_ANDES_GNU_BAREMETAL_TOOLS is undefined, execute 'source how-to/env/setuprc.sh'"
  exit 1
fi

# CPM_ANDES_SPIKE_DIR
if [[ -z "${CPM_ANDES_SPIKE_DIR}" ]]; then
  echo "-E: CPM_ANDES_SPIKE_DIR is undefined, execute 'source how-to/env/setuprc.sh'"
  exit 1
fi

# TOOLS
if [[ -z "${TOOLS}" ]]; then
  echo "-E: TOOLS is undefined, execute 'source how-to/env/setuprc.sh'"
  exit 1
fi

safe_export_path_chk "${RV_ANDES_GNU_BAREMETAL_TOOLS}/bin"

# Cross check compiler, in case the above fails, some how
if ! command -v "riscv64-unknown-elf-gcc" > /dev/null; then
  echo "-E: RISC-V cross-compiler riscv64-unknown-elf-gcc was not found in PATH."
  echo "-E: Please ensure it is in your PATH, for example:"
  echo "export PATH=\$RV_ANDES_GNU_BAREMETAL_TOOLS/bin:\$PATH"
  exit 1
fi

# WHISPER_DIR
if [[ -z "${WHISPER_DIR}" ]]; then
  echo "-E: WHISPER_DIR is undefined, execute 'source how-to/env/setuprc.sh'"
  exit 1
fi
# -------------------------------------------------------------
# Andes Spike
# -------------------------------------------------------------
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
echo "CPM Andes Spike installed successfully"
# ----------------------------------------------------------------------
# Boost - needed for Tenstorrent Whisper
# ----------------------------------------------------------------------
cd "${CONDOR_TOP}"

mkdir -p exttools; cd exttools
if ! [ -d "boost" ]; then
  echo "-W: boost does not exist, cloning repo."
  clone_repository_with_retries "https://github.com/boostorg/boost.git" "boost" "--recursive"
fi

update_progress "exttools_boost_installed"
echo "Boost installed successfully"
# ----------------------------------------------------------------------
update_progress "cpm_andes_spike_installed"
# Whisper
# ----------------------------------------------------------------------
cd "${CONDOR_TOP}"

if ! [ -d "${WHISPER_DIR}" ]; then
  echo "-W: whisper does not exist, cloning repo."
  clone_repository_with_retries "https://github.com/tenstorrent/whisper.git" "${WHISPER_DIR}" "--recursive"
fi

cd "${WHISPER_DIR}"
make -j"$(nproc)"

mkdir -p "${TOOLS}/bin"
cp build-Linux/whisper "${TOOLS}/bin"

update_progress "whisper_installed"
echo "Whisper installed successfully"
