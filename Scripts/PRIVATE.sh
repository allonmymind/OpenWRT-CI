UPDATE_PACKAGE "open-app-filter" "destan19/OpenAppFilter" "oaf-6.1" "" "luci-app-appfilter oaf"

#UPDATE_PACKAGE "homebox" "sirpdboy/netspeedtest" "main" "pkg" "luci-app-netspeedtest ookla-speedtest"

# 引入自建 LuCI 插件
UPDATE_PACKAGE "luci-app-homebox" "allonmymind/luci-app-homebox" "main" "" ""

# 仅引入 Homebox 后端
REPO_PATH="./package/netspeedtest"

rm -rf "$REPO_PATH"

git clone --depth=1 --single-branch --branch main \
    https://github.com/sirpdboy/netspeedtest.git "$REPO_PATH" || exit 1

if [ -d "$REPO_PATH/homebox" ]; then
    rm -rf ./package/homebox
    cp -a "$REPO_PATH/homebox" ./package/
    echo "已复制 Homebox 后端"
else
    echo "错误：未找到 homebox 软件包目录"
    exit 1
fi

rm -rf "$REPO_PATH"

