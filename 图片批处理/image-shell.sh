#!/bin/sh
#  CreateAppIcon.sh
#  Created by SuperlightBaby on 2017/4/30.
#  Copyright © 2017年 SuperlightBaby. All rights reserved.

# 导入公共方法和环境变量
cd $(dirname $0)
. ./image-method.sh

ReadUserSelectPara() {
	# 判断用户选择的是否在数组内
	isContainPara="0"
	# 读取当前用户选择
	temp_slect=$1
	para_array=(1 2 3 4)
	for item in "${para_array[@]}";
	do 
		if [ "$item" = "$temp_slect" ]; then
			isContainPara="888888"
			break
		fi
	done

	if [ "$isContainPara" = "888888" ]; then
	    # 参数有效
		echo "*** 当前用户选择操作类型:$temp_slect ***"
		user_select="$select_para"
	else
	    # 参数无效
		echo "*** 请输入所选操作的对应数字 ***"
		read -r select_para
		sleep 0.5
		# 递归调用
		ReadUserSelectPara "$select_para"
	fi
}

#提示用户选择
cd "$(dirname "$0")" || exit
echo "~~~~~~~~~~~~~~~~~~ 输入数字操作(e.g. 输入：1) ~~~~~~~~~~~~~~~"
echo "~~~~~~~~~ 1 一键生成AppIcon(图片名称需为AppIcon)      ~~~~~~~~"
echo "~~~~~~~~~ 2 一键生成App启动图(图片名称需为LaunchImage) ~~~~~~~~"
echo "~~~~~~~~~ 3 一键将所有PNG图片缩放为1x,2x,3x图片        ~~~~~~~~"
echo "~~~~~~~~~ 4 一键将所有图片转化为PNG格式                ~~~~~~~~"

# 读取用户选择
ReadUserSelectPara "$user_select"
#当前方法
method="$user_select"
# 判读用户是否有输入
if [ -n "$method" ]; then
	##########################################
	#一键生成App图标
	if [ "$method" = "1" ]; then
		# 判断默认文件是否存在
		JudgeFileIsExist "$icon_image_name"
		# 创建 icon 图片
		CreateIconImage "$global_image_name"
		##########################################
		#创建启动页图片
	elif [ "$method" = "2" ]; then
		# 判断默认文件是否存在
		JudgeFileIsExist "$lauch_image_name"
		# 生成启动图片
		CreateLaunchImage "$global_image_name"
		##########################################
		#自动生成1x，2x，3x图片
	elif [ "$method" = "3" ]; then
		# 当前目录下所有图片
		CreateXXImage
		##########################################
		#转换格式
	elif [ "$method" = "4" ]; then
		ConvertAllToPng
		##########################################
		#参数无效
	else
		echo "参数无效，重新输入"
	fi
fi
