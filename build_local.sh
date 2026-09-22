#!/usr/bin/env bash
set -e

echo "=== SBC3500 Wi-Fi Driver Builder (Linux / Docker) ==="

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  build-essential libncurses-dev bison flex libssl-dev libelf-dev bc git wget kmod \
  gcc-aarch64-linux-gnu g++-aarch64-linux-gnu clang-14 lld-14 llvm-14

if [ ! -d "linux-rk" ]; then
  echo "Cloning Rockchip Linux 5.10..."
  git clone --depth=50 --branch develop-5.10 https://github.com/rockchip-linux/kernel.git linux-rk
fi

cd linux-rk
sed -i 's/^SUBLEVEL = .*/SUBLEVEL = 157/' Makefile
sed -i 's/^EXTRAVERSION = .*/EXTRAVERSION =/' Makefile
cp ../sbc3500_android13.config .config

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export LLVM=1
export LLVM_IAS=1

make olddefconfig
make prepare modules_prepare -j$(nproc)
cd ..

if [ ! -d "rtl8821cu" ]; then
  git clone --depth=1 https://github.com/morrownr/8821cu-20210916.git rtl8821cu
fi
cd rtl8821cu
sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/g' Makefile
make KSRC=$(pwd)/../linux-rk -j$(nproc) modules
cd ..

mkdir -p output_modules
cp rtl8821cu/8821cu.ko output_modules/8821cu.ko
cp rtl8821cu/8821cu.ko output_modules/8822bu.ko

echo "=== Build Complete! Output located in output_modules/ ==="
ls -lh output_modules/
