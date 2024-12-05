
# Creating a Custom `rootfs.cpio` File

This document contains notes on how to create a custom `rootfs.cpio` file for a RISC-V Linux environment and use it when booting Linux on Dromajo/Spike. It includes steps to set up Buildroot if it’s not already available and instructions to inject your own files into the root filesystem.

---

## Prerequisites

This document assumes that you have already set up your work area, if not, run:

```bash
git clone https://github.com/Condor-Performance-Modeling/how-to.git
source how-to/env/setuprc.sh
echo $PATCHES                     # this should not be empty
```

## Steps to Set Up Buildroot

If you don’t already have Buildroot (should be located in $TOP directory), or want to work on a separate Buildroot copy, follow these steps to download, configure, and patch it:

### 1. Download and Extract Buildroot

```bash
wget --no-check-certificate https://github.com/buildroot/buildroot/archive/2020.05.1.tar.gz
tar xf 2020.05.1.tar.gz
```

### 2. Apply Configuration

Copy the Buildroot configuration file into the extracted directory:

```bash
cp $PATCHES/config-buildroot-2020.05.1 buildroot-2020.05.1/.config
```

### 3. Build and Patch Buildroot

The initial build attempts will fail and require patching:

#### First Build Attempt

```bash
make -C buildroot-2020.05.1 -j$(nproc)
cp $PATCHES/c-stack.c ./buildroot-2020.05.1/output/build/host-m4-1.4.18/lib/c-stack.c
```

#### Second Build Attempt

```bash
make -C buildroot-2020.05.1 -j$(nproc)
cp $PATCHES/libfakeroot.c ./buildroot-2020.05.1/output/build/host-fakeroot-1.20.2/libfakeroot.c
```

#### Final Build

```bash
sudo make -C buildroot-2020.05.1 -j$(nproc)
```

If the final build succeeds, the `rootfs.cpio` file will be located in the `output/images` directory. If it fails, the script will exit with an error.

---

## Adding Custom Files to the Root Filesystem

To include your own files in the root filesystem:

**Inject Files**:

   Copy the files into the Buildroot target filesystem, for example:

   ```bash
   sudo cp inittab buildroot-2020.05.1/output/target/etc
   sudo cp run_benchmark.sh buildroot-2020.05.1/output/target/etc/init.d
   sudo mkdir -p buildroot-2020.05.1/output/target/root/custom_files
   sudo cp custom_file.txt buildroot-2020.05.1/output/target/root/custom_files
   ```

**Rebuild the Root Filesystem**:

   Rebuild Buildroot to generate the updated `rootfs.cpio` file:

   ```bash
   sudo make -C buildroot-2020.05.1
   ```

---

## Using `rootfs.cpio` when booting Linux

When booting Linux, `initrd` option must be used.

- **Purpose**:
  - Specifies the `rootfs.cpio` file to be loaded into RAM during boot.
  - Provides the kernel with the root filesystem, enabling initialization of user-space programs.

- **Requirements**:
  - The `rootfs.cpio` must include essential files like `/init` or `/etc/inittab`.
  - The path should correctly point to the `rootfs.cpio` file relative to `boot.cfg`.

---

## Boot Linux - CPM Dromajo

### Boot Command - Dromajo

```bash
dromajo --ctrlc --stf_priv_modes USHM --stf_trace example.stf boot.cfg
```

### `initrd` in `boot.cfg`

The `initrd` field in `boot.cfg` specifies the initial RAM disk (root filesystem) for the Linux kernel:

```json
"initrd": "../common/rootfs.cpio"
```

---

## Boot Linux - Spike

### Boot Command - Spike

```bash
spike --kernel Image --initrd rootfs.cpio --bootargs "root=/dev/ram rw earlycon=sbi console=hvc0" fw_jump.elf
```

### `--initrd` Option in Spike

The `--initrd` option specifies the initial RAM disk (root filesystem) for the Linux kernel:

```bash
--initrd rootfs.cpio
```
