#!/bin/bash

set -e

TIMESTAMP="$(date +'%Y%m%d_%H%M%S')"
LOG_FILE="${TIMESTAMP}_cpm_env_setup.log"

BM_BASE="riscv64-unknown-elf"
LNX_BASE="riscv64-unknown-linux-gnu"
# -------------------------------------------------------------
safe_export_path() {
    local path_to_add="${1}"

    if [[ -z "${path_to_add}" ]]; then
        echo "-E: No path provided to safe_export_path."
        exit 1
    fi

    if [[ ! -d "${path_to_add}" ]]; then
        echo "-E: Missing required path: ${path_to_add}"
        exit 1
    fi

    export PATH="${path_to_add}:${PATH}"
}
# -------------------------------------------------------------
check_path_exists() {
    local path="${1}"

    if [[ -z "${path}" ]]; then
        echo "-E: No path specified to check."
        exit 1
    fi

    if [[ ! -e "${path}" ]]; then
        echo "-E: Required path does not exist: ${path}"
        exit 1
    fi
}
# -------------------------------------------------------------
update_progress() {
    echo "${1}" >> "${PROGRESS_FILE}"
}
# -------------------------------------------------------------
check_progress() {
    if [[ -f "${PROGRESS_FILE}" ]]; then
        grep -Fxq "${1}" "${PROGRESS_FILE}"
        return $?
    fi
    return 1
}
# -------------------------------------------------------------
echo_stage() {
    echo "Starting Script Stage: ${1}"
}
# -------------------------------------------------------------
pretty_error() {
    echo
    echo -e "\t# --------------------------------------------"
    echo -e "\t# ${1}"
    echo -e "\t# --------------------------------------------"
    echo
}
# -------------------------------------------------------------
set_up_cpm_environment() {

    echo "Checking conda environment settings"
    if [[ "${CONDA_DEFAULT_ENV}" != "sparta" ]]; then
        echo "The 'sparta' environment is not active."
        echo "To activate it, run: conda activate sparta"
        exit 1
    fi
    echo "Checking conda environment settings - OK"

    echo "Checking CPM environment settings"

    if [[ -z "${CONDOR_TOP}" || \
          -z "${TOOLS}" || \
          -z "${PATCHES}" || \
          -z "${RV_GNU_LINUX_TOOLS}" || \
          -z "${RV_GNU_BAREMETAL_TOOLS}" || \
          -z "${RV_ANDES_GNU_BAREMETAL_TOOLS}" || \
          -z "${WHISPER_DIR}" || \
          -z "${CPM_DOCS}" || \
          -z "${CPM_ANDES_SPIKE_DIR}" ]]; then
        echo
        echo "One or more required environment variables are not set:"
        echo
        printf "  %-25s : %s\n" "CONDOR_TOP" "${CONDOR_TOP:-<undefined>}"
        printf "  %-25s : %s\n" "TOOLS" "${TOOLS:-<undefined>}"
        printf "  %-25s : %s\n" "PATCHES" "${PATCHES:-<undefined>}"
        printf "  %-25s : %s\n" "RV_GNU_LINUX_TOOLS" "${RV_GNU_LINUX_TOOLS:-<undefined>}"
        printf "  %-25s : %s\n" "RV_GNU_BAREMETAL_TOOLS" "${RV_GNU_BAREMETAL_TOOLS:-<undefined>}"
        printf "  %-25s : %s\n" "RV_ANDES_GNU_BAREMETAL_TOOLS" "${RV_ANDES_GNU_BAREMETAL_TOOLS:-<undefined>}"
        printf "  %-25s : %s\n" "CPM_ANDES_SPIKE_DIR" "${CPM_ANDES_SPIKE_DIR:-<undefined>}"
        echo
        echo "To set these variables, cd to your work area and run:"
        echo "  source how-to/env/setuprc.sh"
        exit 1
    fi

    TOOLCHAIN_ELF_DIR="${RV_GNU_BAREMETAL_TOOLS}"
    TOOLCHAIN_LINUX_DIR="${RV_GNU_LINUX_TOOLS}"
    TOOLCHAIN_PATH_MOD="${RV_GNU_LINUX_TOOLS}/bin"
    mkdir -p "${CONDOR_TOP}/tools"
    TOOLS_DIR="${CONDOR_TOP}/tools"

    PROGRESS_FILE="${CONDOR_TOP}/.onboarding_env_setup_progress"

    check_path_exists "${TOOLCHAIN_ELF_DIR}"
    check_path_exists "${TOOLCHAIN_LINUX_DIR}"
    check_path_exists "${TOOLCHAIN_PATH_MOD}"
    check_path_exists "${RV_ANDES_GNU_BAREMETAL_TOOLS}/bin"
    check_path_exists "${TOOLS_DIR}"

    echo "Checking CPM environment settings - OK"

    if check_progress "env_setup_completed"; then
        echo "Previous setup process completed."
        echo "Clearing progress file to start fresh."
        rm -f "${PROGRESS_FILE}"
    fi

    # Build Sparcians components
    if ! check_progress "build_sparcians"; then
        echo_stage "Building Sparcians components"
        conda install yaml-cpp -y
        cd "${CONDOR_TOP}"
        if ! bash how-to/scripts/build_sparcians.sh; then
            pretty_error "Failed to build Sparcians. See log: ${LOG_FILE}"
            exit 1
        fi
        update_progress "build_sparcians"
    fi

    # Link cross compilers and check /tools
    if ! check_progress "cross_compilers_and_tools_checked"; then
        echo_stage "Checking ${TOOLS_DIR} and linking cross compilers"

        if [[ ! -d "${TOOLCHAIN_ELF_DIR}" ]]; then
            pretty_error "Missing ${TOOLCHAIN_ELF_DIR}"
            exit 1
        fi

        if [[ ! -d "${TOOLCHAIN_LINUX_DIR}" ]]; then
            pretty_error "Missing ${TOOLCHAIN_LINUX_DIR}"
            exit 1
        fi

        cd "${CONDOR_TOP}"
        ln -fs "${TOOLCHAIN_ELF_DIR}" "${BM_BASE}"
        ln -fs "${TOOLCHAIN_LINUX_DIR}" "${LNX_BASE}"

        safe_export_path "${TOOLCHAIN_PATH_MOD}"

        export CROSS_COMPILE="${LNX_BASE}-"

        update_progress "cross_compilers_and_tools_checked"
    fi

    # Build the Linux collateral
    if ! check_progress "linux_collateral_built"; then
        echo_stage "Building the Linux collateral"
        cd "${CONDOR_TOP}"
        if ! bash how-to/scripts/build_linux_collateral.sh; then
            pretty_error "Failed to build Linux collateral. See log: ${LOG_FILE}"
            exit 1
        fi
        update_progress "linux_collateral_built"
    fi

    # Install the CPM Repos
    if ! check_progress "cpm_repos_installed"; then
        echo_stage "Building and Installing CPM Repos"
        cd "${CONDOR_TOP}"
        if ! CPATH="${CONDA_PREFIX}/include" LIBRARY_PATH="${CONDA_PREFIX}/lib" LD_LIBRARY_PATH="${CONDA_PREFIX}/lib" bash how-to/scripts/build_cpm_repos.sh; then
            pretty_error "Failed to install CPM repos. See log: ${LOG_FILE}"
            exit 1
        fi
        update_progress "cpm_repos_installed"
    fi

    # Install the Secondary Repos
    if ! check_progress "extra_repos_installed"; then
        echo_stage "Building and Installing Secondary Repos"
        cd "${CONDOR_TOP}"
        if ! bash how-to/scripts/build_extra_tools.sh; then
            pretty_error "Failed to install Secondary repos. See log: ${LOG_FILE}"
            exit 1
        fi
        update_progress "extra_repos_installed"
    fi

}

set_up_cpm_environment "${@}" 2>&1 | tee -a "${LOG_FILE}"

