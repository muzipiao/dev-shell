#!/bin/sh
#  CreateAppIcon.sh
#  Created by SuperlightBaby on 2017/4/30.
#  Copyright © 2017年 SuperlightBaby. All rights reserved.

# 全局的临时变量，储存用户选择
user_select=""
# 全局的临时变量，储存图片名称
global_image_name=""
# 默认启动图片名称
lauch_image_name="LaunchImage.png"
# 默认icon图片名称
icon_image_name="AppIcon.png"

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

# --------------------读取文件名或者参数的方法--------------------
JudgeFileIsExist() {
	temp_file_name=$1
	if [ -f "$temp_file_name" ]; then
	    # 文件存在
		echo "*** 文件名称:$temp_file_name ***"
		global_image_name=$temp_file_name
	else
	    # 文件不存在
		echo "*** 文件不存在:$temp_file_name ***"
		echo "*** 请输入文件全名称或者路径，eg：LaunchImage.png ***"
		read -r file_name_para
		sleep 0.5
		# 递归调用
		JudgeFileIsExist "$file_name_para"
	fi
}

#>>>>>>>>>>>>>>>>>>>>>>>先判断是否是图片,是返回0，否返回-1<<<<<<<<<<<<<<<<<<<<<<<<
JudgeIsImage() {
	#format string jpeg | tiff | png | gif | jp2 | pict | bmp | qtif | psd | sgi | tga
	#获取输入的图形文件类型
	imgType=$(sips -g format "$1" | awk -F: '{print $2}')
	#转换为字符串格式
	imgStr="echo $imgType"
	# 去除空格和换行
	typeStr=$($imgStr | xargs echo -n)
	if [ "$typeStr" = "png" ] || [ "$typeStr" = "jpg" ] || [ "$typeStr" = "jpeg" ] || [ "$typeStr" = "tiff" ] || [ "$typeStr" = "gif" ] || [ "$typeStr" = "jp2" ] || [ "$typeStr" = "pict" ] || [ "$typeStr" = "bmp" ] || [ "$typeStr" = "qtif" ] || [ "$typeStr" = "psd" ] || [ "$typeStr" = "sgi" ] || [ "$typeStr" = "tga" ]; then
		return 0
	else
		echo "$1非图片格式,无法转换"
		return 1
	fi
}

#>>>>>>>>>>>>>>>>>>>>>>>自动生成1x，2x，3x图片<<<<<<<<<<<<<<<<<<<<<<<<
#自动生成1x，2x，3x图片，只对png图形有效
ScalePic() {
	#获取文件尺寸，像素值
	imageHeight=$(sips -g pixelHeight "$1" | awk -F: '{print $2}')
	imageWidth=$(sips -g pixelWidth "$1" | awk -F: '{print $2}')
	height=$((imageHeight))
	width=$((imageWidth))
	#2x图形比例
	height2x=$((height * 2 / 3))
	width2x=$((width * 2 / 3))
	#1x图形尺寸
	height1x=$((height / 3))
	width1x=$((width / 3))
	#文件名称
	imageFile=$1
	#分别获取文件名和文件类型
	#截取文件名称，最后一个.号前面的字符
	filehead=${imageFile%.*}

	#获取输入的图形文件类型
	imgType=$(sips -g format "$1" | awk -F: '{print $2}')
	imgStr="echo $imgType"
	# 去除空格和换行
	typeStr=$($imgStr | xargs echo -n)

	#fileName2x=${imageFile/\.png/@2x\.png}
	#fileName3x=${imageFile/\.png/@3x\.png}
	fileName1x="$filehead""@1x.""$typeStr"
	fileName2x="$filehead""@2x.""$typeStr"
	fileName3x="$filehead""@3x.""$typeStr"

	#原图像默认为3X
	cp "$imageFile" "XXFolder/$fileName3x"
	#缩放2X图形
	sips -z $height2x $width2x "$1" --out "XXFolder/$fileName2x"
	#缩放1x图形
	sips -z $height1x $width1x "$1" --out "XXFolder/$fileName1x"
}

# 将文件内所有图片转2x，3x
CreateXXImage() {
	#先删除旧的
	rm -rf XXFolder
	# 再创建CEB文件夹
	mkdir XXFolder
	for file in ./*; do
			#判断是否为文件，排除文件夹
			if [ -f "$file" ]; then
				imageFile=$(basename $file)
				#判断是否是图片格式
				JudgeIsImage $imageFile
				boolIsImg=$?
				if [ $boolIsImg -eq 0 ]; then
					ScalePic "$imageFile"
				else
					echo "非图片文件：$imageFile"
				fi
			fi
	done
}

#>>>>>>>>>>>>>>>>>>>>>>>图片转为PNG<<<<<<<<<<<<<<<<<<<<<<<<
#如果图片不是PNG，则转换为png
ConvertToPng() {
	#format string jpeg | tiff | png | gif | jp2 | pict | bmp | qtif | psd | sgi | tga
	#获取输入的图形文件类型
	imgType=$(sips -g format "$1" | awk -F: '{print $2}')
	#转换为字符串格式
	typeStr="echo $imgType"
	if [ "$typeStr" = "png" ]; then
		echo "$1为PNG图片，不需要转换"
		#拷贝过去即可
		cp "$1" PngFolder/"$1"
	else
		echo "$1格式需要转换"
		#文件全名称
		filename=$1
		#截取文件名称，最后一个.号前面的字符
		filehead=${filename%.*}
		#截取文件后缀名称，删除最后一个.前面的字符
		#filelast=${filename##*.}
		#转换为PNG格式图片
		sips -s format png "$1" --out PngFolder/"${filehead}".png
	fi
 }

#>>>>>>>>>>>>>>>>>>>>>>>一键生成App图标<<<<<<<<<<<<<<<<<<<<<<<<
#自动生成icon
CreateIconImage() {
	#-Z 等比例按照给定尺寸缩放最长边。
	#先删除旧的
	rm -rf IconFolder
	# 再创建CEB文件夹
	mkdir IconFolder

	icon_image_name=$1
	# icon图片尺寸数组
	icon_array=(20 29 40 58 60 76 80 87 120 152 167 180 1024)
	# 遍历
	for item in "${icon_array[@]}";
	do 
		sips -Z "$item" "$icon_image_name" --out IconFolder/AppIcon_"$item"x"$item".png
	done
}

#>>>>>>>>>>>>>>>>>>>>>>>一键生成App启动图片LaunchImage<<<<<<<<<<<<<<<<<<<<<<<<
#自动生成LaunchImage
CreateLaunchImage() {
	#iPhone 6Plus/6SPlus(Retina HD 5.5 @3x): 1242 x 2208
	#iPhone 6/6S/(Retina HD 4.7 @2x): 750 x 1334
	#iPhone 5/5S(Retina 4 @2x): 640 x 1136
	#iPhone 4/4S(@2x): 640 x 960
	#先删除旧的
	rm -rf LaunchImageFolder
	# 再创建CEB文件夹
	mkdir LaunchImageFolder
	image_name=$1
	# 图片高度
	h_array=(960 1024 1136 1334 1792 2048 2208 2436 2688)
	# 图片宽度
	w_array=(640 768  640  750  828  1536 1242 1125 1242)
	array_count=${#h_array[@]}
	for ((i=0; i<"$array_count"; i++))
	do
		sips -z "${h_array[i]}" "${w_array[i]}" "$image_name" --out LaunchImageFolder/"LaunchImage_${h_array[i]}x${w_array[i]}.png"
		# 个别图片需要横屏图片
		if [ "${h_array[i]}" = 1792 ] || [ "${h_array[i]}" = 2208 ] || [ "${h_array[i]}" = 2436 ] || [ "${h_array[i]}" = 2688 ]; then
			sips -z "${w_array[i]}" "${h_array[i]}" "$image_name" --out LaunchImageFolder/"LaunchImage_${w_array[i]}x${h_array[i]}.png"
		fi
	done
}

#提示用户选择
cd "$(dirname "$0")" || exit
echo "~~~~~~~~~~~~~~~~~~ 输入数字操作 ~~~~~~~~~~~~~~~"
echo "~~~~~~~~~ 1 一键生成AppIcon(图片名称需为icon)         ~~~~~~~~"
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
		#先删除旧的
		rm -rf PngFolder
		# 再创建CEB文件夹
		mkdir PngFolder
		for file in ./*; do
			#判断是否为文件，排除文件夹JudgeIsImage
			if [ -f "$file" ]; then
				imageFile=$(basename $file)
				#判断是否是图片格式
				JudgeIsImage $imageFile
				boolIsImg=$?
				if [ $boolIsImg -eq 0 ]; then
					ConvertToPng $imageFile
				else
					echo "非图片文件：$imageFile"
				fi
			fi
		done
		##########################################
		#参数无效
	else
		echo "参数无效，重新输入"
	fi
fi
