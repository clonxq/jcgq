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

# 定义目标文件路径（相对于源码根目录）
TARGET_FILE="target/linux/mediatek/image/filogic.mk"

# 远程文件地址
REMOTE_URL="https://raw.githubusercontent.com/xqrock/jdbl/main/filogic.mk"

# 执行替换动作
echo "正在替换历史 Bug 文件: $TARGET_FILE ..."
curl -fsSL "$REMOTE_URL" -o "$TARGET_FILE"

# 校验是否替换成功（可选）
if [ $? -eq 0 ]; then
    echo "文件替换成功！"
else
    echo "警告：文件下载失败，请检查网络或 URL 有效性。"
    exit 1
fi
