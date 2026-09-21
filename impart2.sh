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
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate
rm -rf package/feeds/luci/luci-app-wrtbwmon
rm -rf package/feeds/packages/wrtbwmon
rm -rf feeds/packages/net/adguardhome
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

#修复Rust编译失败
sed -i 's/ci-llvm=true/ci-llvm=false/g' feeds/packages/lang/rust/Makefile

#sed -i 's/mt7981b.dtsi/mt7981.dtsi/g' target/linux/mediatek/dts/*.dts*
# 1. 删除 feeds 中自带的旧版 argon 主题与配置插件
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config

# 2. 清理 package 或 feeds 目录下可能存在的其他同名残留
find package/ feeds/ -maxdepth 5 -type d -name "luci-theme-argon" | xargs rm -rf
find package/ feeds/ -maxdepth 5 -type d -name "luci-app-argon-config" | xargs rm -rf

# 3. 克隆 JerryKuku 官方最新 18.06 分支到 package 目录
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
