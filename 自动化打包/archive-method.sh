#!/bin/sh
# 打包脚本抽取的方法

#工程名称，注意：ExportOptions.plist文件必须放到"工程名.xcodeproj"同级目录下，然后在终端中输入"cd 当前工程名.xcodeproj所在文件路径"，在拖入此Shell脚本即可。
g_project_name=""

#打包模式 Debug/Release
g_development_mode="Release"

#scheme名
g_scheme_name=""

#plist文件所在路径，里面需要包含Bundle ID和描述文件名称，注意：ExportOptions.plist文件必须放到"工程名.xcodeproj"同级目录下
g_export_options="ExportOptions.plist"

#导出.ipa文件所在路径，默认在桌面的 auto-ipa 文件夹下
g_ipa_path="~/Desktop/auto-ipa"

#导出 ipa 文件的时间
g_current_time=""

# 找到xcodeproj文件或者xcworkspace文件
FindProjFile() {
	for file in ./*; do
		#判断是否为文件夹
		if [ -d "$file" ]; then
			file_name=$(basename "$file")
			#判断后缀名称
			file_last=${file_name##*.}
            if [ "$file_last" = "xcodeproj" ]; then
                g_project_name=$file_name
            fi
            if [ "$file_last" = "xcworkspace" ]; then
                g_project_name=$file_name
                break
            fi
		fi
	done
}

# 自动找到scheme
# list_proj=$(xcodebuild -list -project "$file_proj")
# list_scheme=${list_proj##*:}
# 使用awk去除换行，使用sed去除空格
# g_scheme_name=$(echo "$list_scheme" | awk '{printf "%s",$1}'| sed "s/ //g")
FindScheme() {
    temp_project_name=$1
    file_proj=${temp_project_name%.*}.xcodeproj
    if [ -d "$file_proj" ]; then
        proj_setting=$(xcodebuild -showBuildSettings)
        s_scheme=$(echo "$proj_setting" | grep TARGET_NAME)
        g_scheme_name=${s_scheme#*= }
    fi
}

# 创建ExportOptions.plist 文件
CreateExportOptionsPlist() {
    export_plist=$1
    proj_setting=$(xcodebuild -showBuildSettings)
    s_identifier=$(echo "$proj_setting" | grep PRODUCT_BUNDLE_IDENTIFIER)
    k_id=${s_identifier#*= }
    s_provision=$(echo "$proj_setting" | grep PROVISIONING_PROFILE_SPECIFIER)
    k_pr=${s_provision#*= }
    s_team_id=$(echo "$proj_setting" | grep DEVELOPMENT_TEAM)
    k_te=${s_team_id#*= }

    # 添加team id
    /usr/libexec/PlistBuddy -c "Add :teamID string $k_te" "$export_plist"
    # 添加描述文件
    /usr/libexec/PlistBuddy -c "Add :provisioningProfiles dict" "$export_plist"
    # 添加value值,
    /usr/libexec/PlistBuddy -c "Add :provisioningProfiles:$k_id string $k_pr" "$export_plist"

    echo "*** teamID：$k_te"
    echo "*** provisioningProfiles：$k_id:$k_pr"
}

# 导出ipa
ArchiveIpa() {
    proj_name=$1
    proj_export_plist=$2
    proj_scheme=$3
    proj_ipa_path=$4
    # 获取时间 如:20190613-092619
    g_current_time="$(date +%Y%m%d-%H%M%S)"
    ipa_folder="$proj_ipa_path/$proj_scheme$g_current_time"

    xcodebuild -exportArchive -archivePath build/"$proj_name".xcarchive \
	-exportPath "$ipa_folder" \
    -destination generic/platform=ios \
	-exportOptionsPlist "$proj_export_plist" \
    -allowProvisioningUpdates \
	-quiet || exit

    # 删除build包
    if [ -d build ]; then
        rm -rf build -r
    fi
}

# 编译项目
BuildProj() {
    proj_name=$1
    proj_mode=$2
    proj_scheme=$3
    proj_export_plist=$4
    proj_ipa_path=$5

    echo "*** 正在清理工程 ***"
    xcodebuild clean  -project "$proj_name".xcodeproj \
    -scheme "$proj_scheme" \
    -configuration "$proj_mode" -quiet || exit
    echo "*** 清理完成     ***"

    echo "*** 正在编译 For $proj_mode"
    xcodebuild \
    archive -project "$proj_name".xcodeproj \
    -scheme "$proj_scheme" \
    -configuration "$proj_mode" \
    -archivePath build/"$proj_name".xcarchive \
    -destination generic/platform=ios -quiet || exit
    echo "*** 编译完成     ***"

    # 导出ipa
    echo "*** 正在导出ipa  ***"
    ArchiveIpa "$proj_name" "$proj_export_plist" "$proj_scheme" "$proj_ipa_path"
    echo "*** ipa 已导出到目录：$proj_ipa_path"
}

BuildWorkspace() {
    proj_name=$1
    proj_mode=$2
    proj_scheme=$3
    proj_export_plist=$4
    proj_ipa_path=$5

    echo "*** 正在清理工程 ***"
    xcodebuild clean  -workspace "$proj_name".xcworkspace \
    -scheme "$proj_scheme" \
    -configuration "$proj_mode" -quiet || exit
    echo "*** 清理完成     ***"

    echo "*** 正在编译 For $proj_mode"
    xcodebuild \
    archive -workspace "$proj_name".xcworkspace \
    -scheme "$proj_scheme" \
    -configuration "$proj_mode" \
    -archivePath build/"$proj_name".xcarchive \
    -destination generic/platform=ios -quiet || exit
    echo "*** 编译完成     ***"

     # 导出ipa
    echo "*** 正在导出ipa  ***"
    ArchiveIpa "$proj_name" "$proj_export_plist" "$proj_scheme" "$proj_ipa_path"
    echo "*** ipa 已导出到目录：$proj_ipa_path"
}