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

# 3. 修复 rd05a1 递归依赖错误 (必须执行，否则 config 不准)
find feeds/ -name "rd05a1" -type d | xargs rm -rf

# 4. 修复 usbgadget 警告
IFILE="package/utils/usbgadget/Makefile"
[ -f "$IFILE" ] && sed -i 's/+kmod-usb-gadget-ncm//g' "$IFILE"

# 5. 【核心步骤】彻底拦截并引诱 Rust 报错
# 删除 Rust 源码文件夹。如果编译依然需要 Rust，
# 报错信息将不再是 "checksum 错误"，而是 "No rule to make target ... rust"
# 在那行错误的上方，会显示： "make[3]: Entering directory '/workdir/openwrt/feeds/packages/xxxx'"
# 那个 xxxx 就是真正的元凶！
rm -rf feeds/packages/lang/rust

# 6. 在 .config 中显式禁用 Rust 相关项（尝试拦截隐式选中）
sed -i '/CONFIG_PACKAGE_rust=y/d' .config
sed -i '/CONFIG_PACKAGE_librust=y/d' .config
echo "CONFIG_PACKAGE_rust=n" >> .config
echo "CONFIG_PACKAGE_librust=n" >> .config
