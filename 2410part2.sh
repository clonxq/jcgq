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


# --- 新增：修复源码底层配置错误 ---

# 5. 修复 rd05a1 递归依赖错误 (强制删除该故障包)
# 这是导致你日志里出现 "recursive dependency detected" 的元凶
find feeds/ -name "rd05a1" -type d | xargs rm -rf

# 6. 修复 usbgadget 依赖缺失警告
IFILE="package/utils/usbgadget/Makefile"
if [ -f "$IFILE" ]; then
    sed -i 's/+kmod-usb-gadget-ncm//g' "$IFILE"
fi

# 7. 彻底拦截 Rust 编译 (引蛇出洞策略)
# 之前的 sed 修改 ci-llvm 无法修复文件缺失报错，直接删除 Rust 源码
# 如果有插件强行调用 Rust，编译会停止并报错是谁在调用，方便我们定位
rm -rf feeds/packages/lang/rust
