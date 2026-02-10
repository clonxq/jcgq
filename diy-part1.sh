#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

function merge_package(){
    repo=`echo $1 | rev | cut -d'/' -f 1 | rev`
    pkg=`echo $2 | rev | cut -d'/' -f 1 | rev`
    # find package/ -follow -name $pkg -not -path "package/custom/*" | xargs -rt rm -rf
    git clone --depth=1 --single-branch $1
    mv $2 package/custom/
    rm -rf $repo
}
function drop_package(){
    find package/ -follow -name $1 -not -path "package/custom/*" | xargs -rt rm -rf
}

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
git clone https://github.com/sirpdboy/luci-app-advanced.git package/luci-app-advanced
#git clone https://github.com/linkease/istore.git package/istore
#git clone https://github.com/linkease/istore-ui.git package/istore-ui
#git clone https://github.com/sirpdboy/luci-app-ddns-go.git package/ddns-go
#git clone https://github.com/gdy666/luci-app-lucky.git package/lucky
git clone https://github.com/KFERMercer/luci-app-tcpdump.git package/luci-app-tcpdump
# git clone https://github.com/xiaorouji/openwrt-passwall-packages.git package/openwrt-passwall
# git clone https://github.com/xiaorouji/openwrt-passwall.git package/passwall
# git clone https://github.com/tty228/luci-app-wechatpush.git package/luci-app-wechatpush
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
# git clone https://github.com/sbwml/luci-app-alist package/alist
merge_package https://github.com/vernesong/OpenClash OpenClash/luci-app-openclash
# merge_package https://github.com/kiddin9/kwrt-packages kwrt-packages/luci-app-ddns
# merge_package https://github.com/kiddin9/kwrt-packages kwrt-packages/luci-app-mwan3helper
merge_package https://github.com/kenzok8/openwrt-packages openwrt-packages/luci-app-adguardhome
merge_package https://github.com/kenzok8/openwrt-packages openwrt-packages/adguardhome
# merge_package https://github.com/kiddin9/kwrt-packages kwrt-packages/wrtbwmon
# merge_package https://github.com/kiddin9/kwrt-packages kwrt-packages/luci-app-wrtbwmon
