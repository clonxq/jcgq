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
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/shadowsocks-libev
rm -rf feeds/packages/net/shadowsocks-rust
rm -rf feeds/packages/net/shadowsocksr-libev
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/luci/applications/luci-app-passwall2
rm -rf feeds/luci/applications/luci-app-ssr-plus
rm -rf feeds/luci/applications/luci-app-openclash
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang

## ----------------- Rust 综合修复逻辑 -----------------
RUST_MAKE="feeds/packages/lang/rust/Makefile"

if [ -f "$RUST_MAKE" ]; then
    echo ">>> 发现 Rust Makefile，开始修复..."

    # 1. 修复 CI LLVM 配置
    sed -i 's/ci-llvm=true/ci-llvm=false/g' "$RUST_MAKE"

    # 2. 动态检测并强行降级版本至 1.89.0
    CURRENT_VERSION=$(grep -E '^PKG_VERSION:=' "$RUST_MAKE" | cut -d'=' -f2)

    if [ "$CURRENT_VERSION" != "1.89.0" ]; then
        echo ">>> 检测到当前 Rust 版本为 $CURRENT_VERSION，正在执行降级到 1.89.0..."
        
        # 通配替换版本号和对应的固定哈希值
        sed -i 's/^PKG_VERSION:=.*/PKG_VERSION:=1.89.0/g' "$RUST_MAKE"
        sed -i 's/^PKG_HASH:=.*/PKG_HASH:=0b9d55610d8270e06c44f459d1e2b7918a5e673809c592abed9b9c600e33d95a/g' "$RUST_MAKE"
        
        echo ">>> 降级指令已执行。"
    else
        echo ">>> 当前版本已经是 1.89.0，跳过降级。"
    fi
    echo ">>> Rust Makefile 处理完毕。"
else
    echo ">>> 错误: 未找到 $RUST_MAKE"
fi
echo "========================================="
echo "DIY Part2 脚本执行结束"
echo "========================================="

# 移除针对 1.89.0 不兼容的 PowerPC 补丁，避免打补丁失败
RUST_PATCH_DIR="feeds/packages/lang/rust/patches"
if [ -f "$RUST_PATCH_DIR/0002-AtomicExpand-keep-the-release-fence-out-of-the-reserv.patch" ]; then
    echo ">>> 正在移除与 Rust 1.89.0 不兼容的 LLVM PowerPC 补丁..."
    rm -f "$RUST_PATCH_DIR/0002-AtomicExpand-keep-the-release-fence-out-of-the-reserv.patch"
fi
