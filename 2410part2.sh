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
##-----------------DIY-----------------
rm -rf ./feeds/packages/net/adguardhome
rm -rf ./feeds/packages/net/mosdns
# rm -rf ./feeds/packages/net/shadowsocks-libev
# rm -rf ./feeds/packages/net/shadowsocks-rust
# rm -rf ./feeds/packages/net/shadowsocksr-libev
# rm -rf ./feeds/luci/applications/luci-app-passwall
# rm -rf ./feeds/luci/applications/luci-app-passwall2
rm -rf ./feeds/luci/applications/luci-app-ssr-plus
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang


#修复Rust编译失败
RUST_FILE=$(find ./feeds/packages/ -maxdepth 3 -type f -wholename "*/rust/Makefile")
if [ -f "$RUST_FILE" ]; then
	echo " "

	sed -i 's/ci-llvm=true/ci-llvm=false/g' $RUST_FILE

	cd $PKG_PATH && echo "rust has been fixed!"
fi

RUST_MAKE="feeds/packages/lang/rust/Makefile"
if [ -f "$RUST_MAKE" ]; then
    echo "正在将 Rust 降级至 1.89.0..."
    # 还原版本号
    sed -i 's/PKG_VERSION:=1.90.0/PKG_VERSION:=1.89.0/g' "$RUST_MAKE"
    # 还原校验值 (PKG_HASH)
    sed -i 's/PKG_HASH:=6bfeaddd90ffda2f063492b092bfed925c4b8c701579baf4b1316e021470daac/PKG_HASH:=0b9d55610d8270e06c44f459d1e2b7918a5e673809c592abed9b9c600e33d95a/g' "$RUST_MAKE"
fi

RUST_PATCH="feeds/packages/lang/rust/patches/0001-Update-xz2-and-use-it-static.patch"
if [ -f "$RUST_PATCH" ]; then
    echo "正在修正 Rust 补丁文件..."
    # 还原补丁里的 sysinfo 版本号
    sed -i 's/sysinfo = { version = "0.36.0"/sysinfo = { version = "0.35.0"/g' "$RUST_PATCH"
fi

