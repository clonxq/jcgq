#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
function extract_pkg() {
    local repo_url=$1
    local repo_path=$2
    local local_path=$3
    local branch=${4:-""}
    local tmp_dir="tmp_extract_$(date +%s)"

    echo ">>> 正在提取: $repo_path (分支: ${branch:-默认})"
    local clone_args="--depth 1 --filter=blob:none --sparse"
    [ -n "$branch" ] && clone_args="$clone_args -b $branch"

    git clone $clone_args "$repo_url" "$tmp_dir"
    if [ $? -eq 0 ]; then
        cd "$tmp_dir" || return
        git sparse-checkout set "$repo_path"
        cd ..
        mkdir -p "$(dirname "$local_path")"
        [ -d "$local_path" ] && rm -rf "$local_path"
        if [ -d "$tmp_dir/$repo_path" ]; then
            cp -r "$tmp_dir/$repo_path" "$local_path"
            echo ">>> 成功保存至: $local_path"
        fi
        rm -rf "$tmp_dir"
    fi
}

# Add a feed source
git clone https://github.com/sirpdboy/luci-app-advanced.git package/luci-app-advanced
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
git clone https://github.com/sirpdboy/luci-app-adguardhome package/luci-app-adguardhome
extract_pkg "https://github.com/kenzok8/openwrt-packages" "adguardhome" "package/adguardhome"
git clone --depth=1 https://github.com/padavanonly/immortalwrt-mt798x-6.6 temp_repo
mkdir -p package/mtk-apps
cp -rn temp_repo/package/mtk/applications/wrtbwmon package/mtk-apps/
cp -rn temp_repo/package/mtk/applications/luci-app-wrtbwmon package/mtk-apps/
rm -rf feeds/luci/applications/luci-app-wrtbwmon
rm -rf feeds/packages/net/wrtbwmon
rm -rf temp_repo
