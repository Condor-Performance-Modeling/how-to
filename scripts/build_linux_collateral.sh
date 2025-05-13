#!/bin/bash

set -e

BM_BASE="riscv64-unknown-elf"
LNX_BASE="riscv64-unknown-linux-gnu"
ECOS_BM_DIR="/data/tools/riscv-embecosm-embedded-ubuntu2204-20240407-14.0.1"
ECOS_LNX_DIR="/data/tools/riscv64-embecosm-linux-gcc-ubuntu2204-20240407-14.0.1"

# Test kernel - this fails
#KERNEL_TARBALL="/data/tools/env/linux-6.12.28.tar.xz"
#KERNEL_BASE="linux-6.12.28"

# Known good kernel
KERNEL_TARBALL="/data/tools/env/linux-5.8-rc4.tar.gz"
KERNEL_BASE="linux-5.8-rc4"

BUILDROOT_TARBALL="/data/tools/env/buildroot-2025.02.tar.gz"
BUILDROOT_BASE="buildroot-2025.02"
BUILDROOT_CONFIG="${PATCHES}/config-buildroot-2025.02" 

# This is the old default string known to work with :
#    buildroot-2020.05
#    linux-5.8-rc4
#KBLD_MARCH="-march=rv64imafdc_zicsr_zifencei"

# Current GCC gives internal error on zicbop, so removed
KBLD_MARCH="-march=rv64imafdc_h_sscofpmf_sstc_svinval_svnapot_svpbmt_zawrs_zba_zbb_zbc_zbs_zfa_zfh_zfhmin_zicbom_zicboz_zicntr_zifencei_zicond_zihintntl_zihintpause_zihpm_zkt_zk_zkn_zknd_zkne_zknh_zbkb_zbkc_zbkx"

# This is the full Condor RVA23 string which GCC fails due to zicbop
#KBLD_MARCH="-march=rv64imafdc_h_sscofpmf_sstc_svinval_svnapot_svpbmt_zawrs_zba_zbb_zbc_zbs_zfa_zfh_zfhmin_zicbop_zicbom_zicboz_zicntr_zifencei_zicond_zihintntl_zihintpause_zihpm_zkt_zk_zkn_zknd_zkne_zknh_zbkb_zbkc_zbkx"

# -------------------------------------------------------------
safe_export_path() {
    local path_to_add="$1"

    if [[ -z "$path_to_add" ]]; then
        echo "-E: No path provided to safe_export_path."
        exit 1
    fi

    if [[ ! -d "$path_to_add" ]]; then
        echo "-E: Missing required path: $path_to_add"
        exit 1
    fi

    export PATH="$path_to_add:$PATH"
}
# -------------------------------------------------------------
safe_export_path_chk() {
    local path_to_add="$1"

    if [[ -z "$path_to_add" ]]; then
        echo "-E: No path provided to safe_export_path."
        exit 1
    fi

    if [[ ! -d "$path_to_add" ]]; then
        echo "-E: Missing required path: $path_to_add"
        exit 1
    fi

    case ":$PATH:" in
        *":$path_to_add:"*)
            # Path already present, do nothing
            ;;
        *)
            export PATH="$path_to_add:$PATH"
            ;;
    esac
}
# -------------------------------------------------------------
check_path_exists() {
    local path="$1"

    if [[ -z "$path" ]]; then
        echo "-E: No path specified to check."
        exit 1
    fi

    if [[ ! -e "$path" ]]; then
        echo "-E: Required path does not exist: $path"
        exit 1
    fi
}

# -------------------------------------------------------------
# Main
# -------------------------------------------------------------
if [[ -z "${CONDOR_TOP}" ]]; then
  echo "CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"
  exit 1
fi

if [[ -z "${PATCHES}" ]]; then
  echo "PATCHES is undefined, execute 'source how-to/env/setuprc.sh'"
  exit 1
fi

if [[ -z "${RV_GNU_LINUX_TOOLS}" ]]; then
  echo "RV_GNU_LINUX_TOOLS is undefined, execute 'source how-to/env/setuprc.sh'"
  exit 1
fi

if [[ -z "${TOOLS}" ]]; then
  echo "TOOLS is undefined, execute 'source how-to/env/setuprc.sh'"
  exit 1
fi

if [[ -z "${BUILDROOT}" ]]; then
  echo "BUILDROOT is undefined, execute 'source how-to/env/setuprc.sh'"
  exit 1
fi

check_path_exists "${CONDOR_TOP}"
check_path_exists "${PATCHES}"
check_path_exists "${ECOS_BM_DIR}"
check_path_exists "${ECOS_LNX_DIR}"

TOOLCHAIN_PATH_MOD="${RV_GNU_LINUX_TOOLS}/bin"
check_path_exists "${TOOLCHAIN_PATH_MOD}"

# Double check the links to the cross compilers

if [[ ! -L "${BM_BASE}" ]]; then
  ln -sfv "${ECOS_BM_DIR}" "${BM_BASE}"
fi

if [[ ! -L "${LNX_BASE}" ]]; then
  ln -sfv "${ECOS_LNX_DIR}" "${LNX_BASE}"
fi

cd "${CONDOR_TOP}"
mkdir -p "${TOOLS}"
mkdir -p "${TOOLS}/riscv-linux"

source "${CONDOR_TOP}/how-to/scripts/git_clone_retry.sh"

safe_export_path_chk "${TOOLCHAIN_PATH_MOD}"

# -------------------------------------------------------------------
# Build the kernel
# -------------------------------------------------------------------
if [[ ! -d "${KERNEL}" ]]; then
  echo 
  echo "Extracting linux kernel (lengthy)"
  echo 
  tar -xf "${KERNEL_TARBALL}"
  mv ${KERNEL_BASE} kernel
fi

grep -qxF "KBUILD_CFLAGS += ${KBLD_MARCH}" \
    "${KERNEL}/Makefile" \
    || echo "KBUILD_CFLAGS += ${KBLD_MARCH}" >> "${KERNEL}/Makefile"

mkdir -p "${TOOLS}/riscv-linux"
rm -f "${TOOLS}/riscv-linux/Image"

make -C "${KERNEL}" ARCH=riscv defconfig
make -C "${KERNEL}" ARCH=riscv -j"$(nproc)"
cp "${KERNEL}/arch/riscv/boot/Image" "${TOOLS}/riscv-linux/Image"

# -------------------------------------------------------------------
# Build the file system
# -------------------------------------------------------------------
tar -xf "${BUILDROOT_TARBALL}"
mv ${BUILDROOT_BASE} buildroot
cp "${BUILDROOT_CONFIG}" "${BUILDROOT}/.config"

make -C "${BUILDROOT}" -j"$(nproc)"

if [[ ! -f "${BUILDROOT}/output/images/rootfs.cpio" ]]; then
  echo "-E: rootfs.cpio build failure"
  exit 1
fi

cp "${BUILDROOT}/output/images/rootfs.cpio" "${CONDOR_TOP}/tools/riscv-linux"

# -------------------------------------------------------------------
# Build OpenSBI
# -------------------------------------------------------------------

cd "${CONDOR_TOP}"
if [[ ! -d "${CONDOR_TOP}/opensbi" ]]; then
  clone_repository_with_retries "https://github.com/riscv/opensbi.git"
else
  cd opensbi && git pull
fi

cd "${OPENSBI}"
make PLATFORM=generic -j"$(nproc)"
cp "${OPENSBI}/build/platform/generic/firmware/fw_jump.bin" "${TOOLS}/riscv-linux"
cp "${OPENSBI}/build/platform/generic/firmware/fw_jump.elf" "${TOOLS}/riscv-linux"

