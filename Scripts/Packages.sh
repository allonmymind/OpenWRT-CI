#!/bin/bash

# ==============================
# 安装和更新软件包
# ==============================
UPDATE_PACKAGE() {

	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local PKG_LIST=("$PKG_NAME" $5)
	local REPO_NAME=${PKG_REPO#*/}

	echo " "
	echo "========== Updating: $PKG_NAME =========="

	# 删除旧插件
	for NAME in "${PKG_LIST[@]}"; do

		echo "Search directory: $NAME"

		local FOUND_DIRS=$(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" 2>/dev/null)

		if [ -n "$FOUND_DIRS" ]; then
			while read -r DIR; do
				rm -rf "$DIR"
				echo "Delete directory: $DIR"
			done <<< "$FOUND_DIRS"
		else
			echo "Not found directory: $NAME"
		fi

	done


	# 克隆仓库
	git clone --depth=1 --single-branch --branch $PKG_BRANCH https://github.com/$PKG_REPO.git || {
		echo "Clone failed: $PKG_REPO"
		return
	}


	# 处理仓库
	if [[ "$PKG_SPECIAL" == "pkg" ]]; then

		find ./$REPO_NAME -maxdepth 4 -type d -iname "*$PKG_NAME*" -exec cp -rf {} ./ \;
		rm -rf ./$REPO_NAME/

	elif [[ "$PKG_SPECIAL" == "name" ]]; then

		mv -f $REPO_NAME $PKG_NAME

	fi

}



# ==============================
# 插件安装
# ==============================

UPDATE_PACKAGE "open-app-filter" "destan19/OpenAppFilter" "master" "" "luci-app-oaf oaf"

UPDATE_PACKAGE "argon" "sbwml/luci-theme-argon" "openwrt-25.12"
UPDATE_PACKAGE "aurora" "eamonxg/luci-theme-aurora" "master"
UPDATE_PACKAGE "aurora-config" "eamonxg/luci-app-aurora-config" "master"
UPDATE_PACKAGE "kucat" "sirpdboy/luci-theme-kucat" "master"
UPDATE_PACKAGE "kucat-config" "sirpdboy/luci-app-kucat-config" "master"

UPDATE_PACKAGE "homeproxy" "VIKINGYFY/homeproxy" "main"
UPDATE_PACKAGE "momo" "nikkinikki-org/OpenWrt-momo" "main"
UPDATE_PACKAGE "nikki" "nikkinikki-org/OpenWrt-nikki" "main"

UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev" "pkg"
UPDATE_PACKAGE "passwall" "Openwrt-Passwall/openwrt-passwall" "main" "pkg"
UPDATE_PACKAGE "passwall2" "Openwrt-Passwall/openwrt-passwall2" "main" "pkg"

UPDATE_PACKAGE "luci-app-tailscale" "asvow/luci-app-tailscale" "main"

UPDATE_PACKAGE "ddns-go" "sirpdboy/luci-app-ddns-go" "main"
UPDATE_PACKAGE "diskman" "lisaac/luci-app-diskman" "master"
UPDATE_PACKAGE "easytier" "EasyTier/luci-app-easytier" "main"
UPDATE_PACKAGE "fancontrol" "rockjake/luci-app-fancontrol" "main"
UPDATE_PACKAGE "gecoosac" "laipeng668/luci-app-gecoosac" "main"

UPDATE_PACKAGE "mosdns" "sbwml/luci-app-mosdns" "v5" "" "v2dat"

UPDATE_PACKAGE "openlist2" "sbwml/luci-app-openlist2" "main"
UPDATE_PACKAGE "partexp" "sirpdboy/luci-app-partexp" "main"

UPDATE_PACKAGE "qbittorrent" "sbwml/luci-app-qbittorrent" "master" "" "qt6base qt6tools rblibtorrent"

UPDATE_PACKAGE "qmodem" "FUjr/QModem" "main"
UPDATE_PACKAGE "quickfile" "sbwml/luci-app-quickfile" "main"

UPDATE_PACKAGE "viking" "VIKINGYFY/packages" "main" "" "luci-app-timewol luci-app-wolplus"

UPDATE_PACKAGE "vnt" "lmq8267/luci-app-vnt" "main"



# ==============================
# 自定义插件
# ==============================

# Lucky
UPDATE_PACKAGE "lucky" "gdy666/luci-app-lucky" "main"

# 微信推送
UPDATE_PACKAGE "wechatpush" "tty228/luci-app-wechatpush" "master"

# 带宽控制
UPDATE_PACKAGE "luci-app-bandix" "timsaya/luci-app-bandix" "main" "pkg"

# WebDAV
UPDATE_PACKAGE "luci-app-webdav" "sbwml/luci-app-webdav" "master"

# AdGuardHome
UPDATE_PACKAGE "luci-app-adguardhome" "sirpdboy/luci-app-adguardhome" "main"

# TurboACC
UPDATE_PACKAGE "luci-app-turboacc" "chenmozhijin/luci-app-turboacc" "master"

# ARP绑定
UPDATE_PACKAGE "luci-app-arpbind" "seassrs/luci-app-arpbind" "main"

# 网络测速 + Homebox
UPDATE_PACKAGE "netspeedtest" "sirpdboy/netspeedtest" "main" "pkg" "homebox"

# Unishare
#UPDATE_PACKAGE "unishare" "linkease/nas-packages-luci" "main" "pkg"

# CPU频率控制
UPDATE_PACKAGE "luci-app-cpufreq" "pppoex/openwrt-packages" "master" "pkg"

# 定时重启（需要可开启）
# UPDATE_PACKAGE "timedreboot" "sirpdboy/luci-app-timedreboot" "main"



# ==============================
# 自动更新软件包版本
# ==============================

UPDATE_VERSION() {

	local PKG_NAME=$1
	local PKG_MARK=${2:-false}

	local PKG_FILES=$(find ./ ../feeds/packages/ -maxdepth 3 -type f -wholename "*/$PKG_NAME/Makefile")

	if [ -z "$PKG_FILES" ]; then
		echo "$PKG_NAME not found!"
		return
	fi

	echo -e "\n$PKG_NAME version update has started!"

	for PKG_FILE in $PKG_FILES; do

		local PKG_REPO=$(grep -Po "PKG_SOURCE_URL:=https://.*github.com/\K[^/]+/[^/]+(?=.*)" $PKG_FILE)

		local PKG_TAG=$(curl -sL https://api.github.com/repos/$PKG_REPO/releases | jq -r "map(select(.prerelease == $PKG_MARK)) | first | .tag_name")

		local OLD_VER=$(grep -Po "PKG_VERSION:=\K.*" "$PKG_FILE")
		local OLD_URL=$(grep -Po "PKG_SOURCE_URL:=\K.*" "$PKG_FILE")
		local OLD_FILE=$(grep -Po "PKG_SOURCE:=\K.*" "$PKG_FILE")
		local OLD_HASH=$(grep -Po "PKG_HASH:=\K.*" "$PKG_FILE")

		local PKG_URL=$([[ "$OLD_URL" == *"releases"* ]] && echo "${OLD_URL%/}/$OLD_FILE" || echo "${OLD_URL%/}")

		local NEW_VER=$(echo $PKG_TAG | sed -E 's/[^0-9]+/\./g; s/^\.|\.$//g')

		local NEW_URL=$(echo $PKG_URL | sed "s/\$(PKG_VERSION)/$NEW_VER/g; s/\$(PKG_NAME)/$PKG_NAME/g")

		local NEW_HASH=$(curl -sL "$NEW_URL" | sha256sum | cut -d ' ' -f 1)

		echo "old version: $OLD_VER $OLD_HASH"
		echo "new version: $NEW_VER $NEW_HASH"

		if [[ "$NEW_VER" =~ ^[0-9].* ]] && dpkg --compare-versions "$OLD_VER" lt "$NEW_VER"; then

			sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$NEW_VER/g" "$PKG_FILE"
			sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/g" "$PKG_FILE"

			echo "$PKG_FILE version has been updated!"

		else

			echo "$PKG_FILE version is already the latest!"

		fi

	done

}



# ==============================
# 自动更新版本
# ==============================

UPDATE_VERSION "sing-box"
# UPDATE_VERSION "tailscale"
