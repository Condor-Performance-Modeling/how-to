#!/bin/bash

set -e

BM_BASE="riscv64-unknown-elf"
LNX_BASE="riscv64-unknown-linux-gnu"
ECOS_BM_DIR="/data/tools/riscv-embecosm-embedded-ubuntu2204-20240407-14.0.1"
ECOS_LNX_DIR="/data/tools/riscv64-embecosm-linux-gcc-ubuntu2204-20240407-14.0.1"

KERNEL_TARBALL="/data/tools/env/linux-5.8-rc4.tar.gz"
KERNEL_BASE="linux-5.8-rc4"
BUILDROOT_TARBALL="/data/tools/env/2020.05.1.tar.gz"
KBLD_MARCH="-march=rv64imafdc_zicsr_zifencei"
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
#tar -xf "/data/tools/env/linux-5.8-rc4.tar.gz"
if [[ ! -d "${KERNEL_BASE}" ]]; then
  echo "Extracting linux kernel"
  tar -xf "${KERNEL_TARBALL}"
fi

grep -qxF "KBUILD_CFLAGS += ${KBLD_MARCH}" \
    "${KERNEL_BASE}/Makefile" \
    || echo "KBUILD_CFLAGS += ${KBLD_MARCH}" >> "${KERNEL_BASE}/Makefile"

#grep -qxF 'KBUILD_CFLAGS += -march=rv64imafdc_zicsr_zifencei' "linux-5.8-rc4/Makefile" \
#  || echo 'KBUILD_CFLAGS += -march=rv64imafdc_zicsr_zifencei' >> "linux-5.8-rc4/Makefile"
#make -C "linux-5.8-rc4" ARCH=riscv defconfig
#make -C "linux-5.8-rc4" ARCH=riscv -j"$(nproc)"

make -C "${KERNEL_BASE}" ARCH=riscv defconfig
make -C "${KERNEL_BASE}" ARCH=riscv -j"$(nproc)"
mkdir -p "${TOOLS}/riscv-linux"

cp "${KERNEL_BASE}/arch/riscv/boot/Image" "${TOOLS}/riscv-linux/Image"

# -------------------------------------------------------------------
# Build the file system
# -------------------------------------------------------------------
tar -xf "${BUILDROOT_TARBALL}"
cp "${PATCHES}/config-buildroot-2020.05.1" "${BUILDROOT}/.config"

# This make will fail, followed by a patch
set +e
#make -C "buildroot-2020.05.1" -j"$(nproc)"
make -C "${BUILDROOT}" -j"$(nproc)"
set -e
cp "${PATCHES}/c-stack.c" "${BUILDROOT}/output/build/host-m4-1.4.18/lib/c-stack.c"

# This make will also fail, followed by another patch
set +e
#make -C "buildroot-2020.05.1" -j"$(nproc)"
make -C "${BUILDROOT}" -j"$(nproc)"
set -e
cp "${PATCHES}/libfakeroot.c" "${BUILDROOT}/output/build/host-fakeroot-1.20.2/libfakeroot.c"

# This make should not fail
#sudo make -C "buildroot-2020.05.1" -j"$(nproc)"
sudo make -C "${BUILDROOT}" -j"$(nproc)"

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

