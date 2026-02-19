#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

#修改默认IP地址
sed -i 's/192\.168\.[0-9]*\.1/192.168.5.1/g' package/base-files/files/bin/config_generate
#修改WIFI名称
sed -i 's/ImmortalWrt-2.4G/Q30-2G/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i 's/ImmortalWrt-5G/Q30-5G/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
##-----------------Del duplicate packages------------------
rm -rf feeds/packages/net/open-app-filter
rm -rf ./feeds/packages/net/adguardhome
rm -rf ./feeds/packages/net/mosdns
rm -rf ./feeds/packages/net/shadowsocks-libev
rm -rf ./feeds/packages/net/shadowsocks-rust
rm -rf ./feeds/packages/net/shadowsocksr-libev
rm -rf ./feeds/luci/applications/luci-app-passwall
rm -rf ./feeds/luci/applications/luci-app-passwall2
rm -rf ./feeds/luci/applications/luci-app-ssr-plus
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang

# --- OpenClash 核心集成 ---
echo "Optimizing OpenClash Cores..."
mkdir -p files/etc/openclash/core
# 使用 -sSL 保证下载稳定且日志整洁
curl -sSL https://github.com/vernesong/OpenClash/raw/refs/heads/core/master/meta/clash-linux-arm64.tar.gz | tar -xz -C files/etc/openclash/core/
mv files/etc/openclash/core/clash files/etc/openclash/core/clash_meta
chmod +x files/etc/openclash/core/clash_meta

# --- AdGuardHome 集成 ---
echo "Optimizing AdGuardHome Binary..."
mkdir -p files/usr/bin
# 下载到临时目录处理
curl -sSL https://github.com/AdguardTeam/AdGuardHome/releases/download/v0.107.69/AdGuardHome_linux_arm64.tar.gz | tar -xz -C /tmp/
# 强制移动，覆盖可能存在的旧文件
mv -f /tmp/AdGuardHome/AdGuardHome files/usr/bin/AdGuardHome
chmod +x files/usr/bin/AdGuardHome
# 清理临时垃圾
rm -rf /tmp/AdGuardHome

echo "Core components integration completed!"

# 4. 清理临时目录
rm -rf /tmp/AdGuardHome
# 修正 ebtables 源码哈希值，解决编译下载校验失败问题
ebtables_makefile="package/network/utils/ebtables/Makefile"
if [ -f "$ebtables_makefile" ]; then
    sed -i 's/1ee560498e1a047b329eab3dad8425ae51e7f0527e4495efb99481ca11206b37/3039d73b167c41025b1b401b647743b9c6d786613c693eef34de325b30de6d47/g' "$ebtables_makefile"
fi

## ----------------- Rust 综合修复逻辑 -----------------
RUST_MAKE="feeds/packages/lang/rust/Makefile"

if [ -f "$RUST_MAKE" ]; then
    echo ">>> 发现 Rust Makefile，开始修复..."

    # 1. 修复 CI LLVM 配置
    sed -i 's/ci-llvm=true/ci-llvm=false/g' "$RUST_MAKE"

    # 2. 强行降级版本 1.90.0 -> 1.89.0
    if grep -q "1.90.0" "$RUST_MAKE"; then
        echo ">>> 检测到 1.90.0，正在执行降级..."
        sed -i 's/PKG_VERSION:=1.90.0/PKG_VERSION:=1.89.0/g' "$RUST_MAKE"
        sed -i 's/PKG_HASH:=6bfeaddd90ffda2f063492b092bfed925c4b8c701579baf4b1316e021470daac/PKG_HASH:=0b9d55610d8270e06c44f459d1e2b7918a5e673809c592abed9b9c600e33d95a/g' "$RUST_MAKE"
        echo ">>> 降级指令已执行。"
    else
        echo ">>> 当前版本不是 1.90.0，跳过降级。"
    fi
    echo ">>> Rust Makefile 处理完毕。"
else
    echo ">>> 错误: 未找到 $RUST_MAKE"
fi

# 3. 修正补丁文件
RUST_PATCH="feeds/packages/lang/rust/patches/0001-Update-xz2-and-use-it-static.patch"
if [ -f "$RUST_PATCH" ]; then
    echo ">>> 正在修正 Rust 补丁中的 sysinfo 版本..."
    sed -i 's/sysinfo = { version = "0.36.0"/sysinfo = { version = "0.35.0"/g' "$RUST_PATCH"
    echo ">>> 补丁修正完毕。"
fi

echo "========================================="
echo "DIY Part2 脚本执行结束"
echo "========================================="
