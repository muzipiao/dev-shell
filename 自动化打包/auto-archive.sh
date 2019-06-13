#!/bin/sh
# 打包脚本

# 将此脚本放在后缀名为xcodeproj的文件同级目录下即可
cd "$(dirname "$0")" || exit 0

# 导入公共方法和变量
. ./archive-method.sh

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
fi

echo "*** 项目配置信息如下： ***"
echo "*** 工程名称：$g_project_name"
echo "*** 打包模式：$g_development_mode"
echo "*** scheme：$g_scheme_name"
echo "*** 导出配置：$g_export_options"
echo "*** 导出路径：$g_ipa_path"
echo "*** 项目配置完毕 ***"

# 获取名称和后缀
file_head=${g_project_name%.*}
file_last=${g_project_name##*.}
if [ "$file_last" = "xcworkspace" ]; then
    BuildWorkspace "$file_head" "$g_development_mode" "$g_scheme_name" "$g_export_options" "$g_ipa_path"
else
    BuildProj "$file_head" "$g_development_mode" "$g_scheme_name" "$g_export_options" "$g_ipa_path" 
fi

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
