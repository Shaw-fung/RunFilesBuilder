#!/bin/bash
set -e

# 从 dl.openwrt.ai 下载指定包名的 ipk
# 用法: ./dl_openwrt_ai.sh <arch> <package_prefix1> [package_prefix2] ...
# arch: x86_64, aarch64_cortex-a53, arm_cortex-a7_neon-vfpv4
# 会在当前目录下的 <arch>/ 子目录中保存下载的 ipk 文件

ARCH="$1"
shift
PREFIXES=("$@")

PACKAGE_VERSION="packages-24.10"
BASE_URL="https://dl.openwrt.ai/${PACKAGE_VERSION}/${ARCH}/kiddin9/"
SAVE_DIR="${ARCH}"
mkdir -p "$SAVE_DIR"

echo "🔍 从 ${BASE_URL} 下载包..."

# 下载页面内容
page_content=$(curl -s "$BASE_URL")

# 提取所有 .ipk 文件链接
all_ipks=$(echo "$page_content" | grep -oP 'href="\K[^"]+\.ipk')

for prefix in "${PREFIXES[@]}"; do
  match=$(echo "$all_ipks" | grep "^${prefix}_" | head -n1)
  if [ -n "$match" ]; then
    echo "⬇️  下载: $match"
    curl -s -L -o "$SAVE_DIR/$match" "${BASE_URL}${match}"
  else
    echo "⚠️ 未找到: $prefix"
  fi
done

echo "✅ 下载完成，文件保存在: $SAVE_DIR/"
