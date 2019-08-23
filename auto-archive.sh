#!/bin/sh
# 打包脚本, 将此脚本放在后缀名为xcodeproj的文件同级目录下，运行脚本即可自动打包
# 脚本会自动获取 工程名称、scheme、描述文件名称等，若不正确，请手动配置

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

# 如果导出ipa失败，很可能是ExportOptions.plist文件错误，检查提示
CheckExportOptionsPlist() {
    export_plist=$1
    proj_setting=$(xcodebuild -showBuildSettings)
    s_identifier=$(echo "$proj_setting" | grep PRODUCT_BUNDLE_IDENTIFIER)
    k_id=${s_identifier#*= }
    s_provision=$(echo "$proj_setting" | grep PROVISIONING_PROFILE_SPECIFIER)
    k_pr=${s_provision#*= }
    s_team_id=$(echo "$proj_setting" | grep DEVELOPMENT_TEAM)
    k_te=${s_team_id#*= }

    # 读取 ExportOptions.plist 的值对比
    p_team=$(/usr/libexec/PlistBuddy -c 'Print :teamID' "$export_plist")
    prov_key="provisioningProfiles:$k_id"
    p_prov=$(/usr/libexec/PlistBuddy -c 'Print :'$prov_key'' "$export_plist")
    # 标记是否有更改
    diff_config=0
    # 对比 teamID
    if [ "$k_te" != "$p_team" ]; then
        diff_config=1
        echo "*** 检测到项目配置的teamID与ExportOptions.plist文件中的值不相等 ***"
        echo "*** 项目teamID为：$k_te  ExportOptions.plist文件teamID为：$p_team"
    fi
    # 对比 provisioningProfiles
    if [ "$k_pr" != "$p_prov" ]; then
        diff_config=1
        echo "*** 检测到项目配置的provisioningProfiles与ExportOptions.plist文件中的值不相等 ***"
        echo "*** 项目配置的provisioningProfiles为：$k_pr ***"
        echo "*** ExportOptions.plist文件provisioningProfiles为：$p_prov ***"
    fi
    if [ "$diff_config" = 1 ]; then
        echo "*** 若创建ipa失败，请删除ExportOptions.plist文件自动配置，重新运行此脚本 ***"
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
}

BuildWorkspace() {
    proj_name=$1
    proj_mode=$2
    proj_scheme=$3
    proj_export_plist=$4

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
}

# 程序主方法
Main() {
    # 自动获取项目名称
    if [ -z "$g_project_name" ]; then
        FindProjFile
    fi

    # 自动获取scheme
    if [ -z "$g_scheme_name" ]; then
        FindScheme "$g_project_name"
    fi

    if [ -z "$g_project_name" ] || [ -z "$g_scheme_name" ]; then
        echo "*** 提示：项目名称或 scheme 获取失败。 ***"
        exit 0
    fi

    if [ ! -f "$g_export_options" ]; then
        echo "*** 未发现ExportOptions.plist文件，自动创建中... ***"
        CreateExportOptionsPlist "$g_export_options"
    else
        echo "*** 检查ExportOptions.plist文件配置是否正确 ***"
        CheckExportOptionsPlist "$g_export_options"
    fi

    echo "*** 项目配置信息如下： ***"
    echo "*** 工程名称：$g_project_name"
    echo "*** 打包模式：$g_development_mode"
    echo "*** scheme：$g_scheme_name"
    echo "*** 导出配置：$g_export_options"
    echo "*** 导出路径：$g_ipa_path"
    echo "*** 项目配置完毕 ***"

    # 获取名称和后缀
    proj_name=${g_project_name%.*}
    proj_type=${g_project_name##*.}

    # 编译项目
    if [ "$proj_type" = "xcworkspace" ]; then
        BuildWorkspace "$proj_name" "$g_development_mode" "$g_scheme_name" "$g_export_options"
    else
        BuildProj "$proj_name" "$g_development_mode" "$g_scheme_name" "$g_export_options" 
    fi

    # 编译完成导出ipa
    echo "*** 正在导出ipa  ***"
    ArchiveIpa "$proj_name" "$g_export_options" "$g_scheme_name" "$g_ipa_path"
    echo "*** ipa 已导出到目录：$proj_ipa_path"
    
    # 绝对路径
    user_path=$(cd ~ && pwd)
    abs_ipa_folder=$(echo ${g_ipa_path/\~/"$user_path"})

    ipa_path="$abs_ipa_folder/$proj_scheme$g_current_time/$g_scheme_name.ipa"
    if [ -e "$ipa_path" ]; then
        echo "*** ipa 路径：$ipa_path"
    else
        echo "*** 创建 ipa 文件失败 ***"
    fi

    echo "*** 打包完成 ***"
}

cd "$(dirname "$0")" || exit 0

# 判断有无传递参数，Python脚本中传递有参数
if [ -z "$1" ]; then
    Main
fi