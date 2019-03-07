#!/bin/sh
# 主Shell文件，配置文件填写完成后，将此文件拖入到终端即可。
shell_path=$(
	cd $(dirname $0)
	pwd
)
# 导入公共方法和环境变量
cd $(dirname $0)
. ./arch_common.sh
. ./envir_config.sh

#提示用户选择
echo "*** 输入以下需要连接的后台环境 ***"
echo "*** vali,dev,prod ***"
# 读取用户输入并存到变量里
read parameter
sleep 0.5
#获取用户选择的字符串,切记=号两边不能有空格
method="$parameter"
# 判读用户是否有输入
if [ -n "$method" ]; then
	ip_file_name="config_"
	if [ "$method" = "vali" ] || [ "$method" = "dev" ]; then
		ip_file_name="$shell_path/arch_config/"$ip_file_name$method".txt"
	elif [ "$method" = "prod" ]; then
		ip_file_name="$shell_path/arch_config/"$ip_file_name$method".txt"
		# 生产要求输入BundleVersion，存到bundle_version
		if [ "$bundle_prod_version" = "" ]; then
			# 如果生产版本未配置，则读取输入
			ReadTargetBundleVersion
		fi
	else
		echo "*** 不包含此配置文件 ***"
		exit 1
	fi
	# 读取ip配置文件到session环境变量
	source $ip_file_name
	echo "*** 读取配置文件"$ip_file_name" ***"
else
	echo "*** 参数无效，重新输入 ***"
fi

# 读取项目路径
CdProjectPath ${project_folder_path}
# 删除重复Info.plist防止打包错误（可选，根据需要）
DelDuplicateInfo ${pbxproj_path}
# 配置项目描述文件
ConfigProjectProvison ${pbxproj_path} ${provison_name} ${provison_value}
# 删除Config.h旧的配置
RemoveConfigFileOldDefine ${config_file_path}
# 配置Config.h文件
DeployConfigManager ${config_file_path} ${bundle_version}
# 配置Info.plist文件
DeployInfoFile ${Info_file} ${bundle_version}
# 配置ExportOptions.plist文件
DeployExportOptionsFile ${export_options_file} ${provison_value}
echo "*** "$parameter"环境配置完成 ***"

# XCode目录路径
default_xcode="/Applications/Xcode.app/Contents/Developer"
current_xcode=$(xcode-select --print-path)
config_xcode="/Applications/"$xcode_name".app/Contents/Developer"

# 如果当前环境变量和配置不相等，则切换（安装多版本XCode需要切换）
if [ $current_xcode != $config_xcode ]; then
	echo "*** 请输入系统密码切换Xcode为:"$xcode_name" ***"
	# 切换XCode默认版本
	sudo xcode-select -switch $config_xcode
fi

# 工程名,注意：脚本目录和xxxx.xcodeproj要在同一个目录，如果放到其他目录，请自行修改脚本。
project_name="工程名称"

#打包模式 Debug/Release
development_mode="Release"

#scheme名
scheme_name="编译生成的Target名称"

#plist文件所在路径
exportOptionsPlistPath=./ExportOptions.plist

#导出.ipa文件所在路径
exportFilePath=~/Desktop/$project_name-ipa

echo '*** 正在 清理工程 ***'
xcodebuild \
	clean -configuration ${development_mode} -quiet || exit
echo '*** 清理完成 ***'

echo '*** 正在 编译工程 For '${development_mode}
xcodebuild \
	archive -project ${project_name}.xcodeproj \
	-scheme ${scheme_name} \
	-configuration ${development_mode} \
	-archivePath build/${project_name}.xcarchive -quiet || exit
echo '*** 编译完成 ***'

echo '*** 正在 打包 ***'
xcodebuild -exportArchive -archivePath build/${project_name}.xcarchive \
	-configuration ${development_mode} \
	-exportPath ${exportFilePath} \
	-exportOptionsPlist ${exportOptionsPlistPath} \
	-quiet || exit

# 删除build包
if [[ -d build ]]; then
	rm -rf build -r
fi

if [ -e $exportFilePath/$scheme_name.ipa ]; then
	echo "*** .ipa文件已导出 ***"
	cd ${exportFilePath}
	echo "*** 开始上传.ipa文件 ***"
	#此处上传分发应用
	echo "*** .ipa文件上传成功 ***"
else
	echo "*** 创建.ipa文件失败 ***"
fi
echo '*** 打包完成 ***'
