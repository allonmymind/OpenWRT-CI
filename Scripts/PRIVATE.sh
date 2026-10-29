UPDATE_PACKAGE "open-app-filter" "destan19/OpenAppFilter" "oaf-6.1" "" "luci-app-appfilter oaf"

#UPDATE_PACKAGE "homebox" "sirpdboy/netspeedtest" "main" "pkg" "luci-app-netspeedtest ookla-speedtest"
# Homebox + LuCI 网络测速插件 + Ookla
REPO_PATH="./package/netspeedtest"

rm -rf "$REPO_PATH"

git clone --depth=1 --single-branch --branch main \
    https://github.com/sirpdboy/netspeedtest.git "$REPO_PATH" || exit 1

for NAME in homebox luci-app-netspeedtest ookla-speedtest; do
    if [ -d "$REPO_PATH/$NAME" ]; then
        cp -a "$REPO_PATH/$NAME" ./package/
        echo "已复制软件包：$NAME"
    else
        echo "错误：未找到软件包目录 $REPO_PATH/$NAME"
        exit 1
    fi
done

rm -rf "$REPO_PATH"
