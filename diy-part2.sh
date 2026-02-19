#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate
# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate
rm -rf ./feeds/packages/net/adguardhome
rm -rf ./feeds/packages/net/mosdns
# rm -rf ./feeds/packages/net/smartdns
rm -rf ./feeds/luci/applications/luci-app-passwall
rm -rf ./feeds/luci/applications/luci-app-alist
# rm -rf ./feeds/luci/applications/luci-app-mwan3helper
rm -rf ./feeds/luci/applications/luci-app-ssr-plus
rm -rf ./feeds/luci/applications/luci-app-openclash
rm -rf ./feeds/luci/applications/luci-app-wechatpush
rm -rf ./feeds/luci/applications/luci-app-ddns-go
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

#修复Rust编译失败
RUST_FILE=$(find ./feeds/packages/ -maxdepth 3 -type f -wholename "*/rust/Makefile")
if [ -f "$RUST_FILE" ]; then
	echo " "

	sed -i 's/ci-llvm=true/ci-llvm=false/g' $RUST_FILE

	cd $PKG_PATH && echo "rust has been fixed!"
fi
