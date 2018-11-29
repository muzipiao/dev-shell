#!/bin/sh
#  CreateAppIcon.sh
#  Created by SuperlightBaby on 2017/4/30.
#  Copyright © 2017年 SuperlightBaby. All rights reserved.

#>>>>>>>>>>>>>>>>>>>>>>>先判断是否是图片,是返回0，否返回-1<<<<<<<<<<<<<<<<<<<<<<<<
JudgeIsImage(){
#format string jpeg | tiff | png | gif | jp2 | pict | bmp | qtif | psd | sgi | tga
#获取输入的图形文件类型
imgType=`sips -g format $1 | awk -F: '{print $2}'`
#转换为字符串格式
typeStr=`echo $imgType`
if [ "$typeStr" = "png" ] || [ "$typeStr" = "jpg" ] || [ "$typeStr" = "jpeg" ] || [ "$typeStr" = "tiff" ] || [ "$typeStr" = "gif" ] || [ "$typeStr" = "jp2" ] || [ "$typeStr" = "pict" ] || [ "$typeStr" = "bmp" ] || [ "$typeStr" = "qtif" ] || [ "$typeStr" = "psd" ] || [ "$typeStr" = "sgi" ] || [ "$typeStr" = "tga" ]
then
  return 0
else
  echo "$1非图片格式,无法转换"
  return -1
fi
}

#>>>>>>>>>>>>>>>>>>>>>>>自动生成1x，2x，3x图片<<<<<<<<<<<<<<<<<<<<<<<<
#自动生成1x，2x，3x图片，只对png图形有效
ScalePic () {
#获取文件尺寸，像素值
imageHeight=`sips -g pixelHeight $1 | awk -F: '{print $2}'`
imageWidth=`sips -g pixelWidth $1 | awk -F: '{print $2}'`
height=`echo $imageHeight`
width=`echo $imageWidth`
#2x图形比例
height2x=$(($height*2/3))
width2x=$(($width*2/3))
#1x图形尺寸
height1x=$(($height/3))
width1x=$(($width/3))
#文件名称
imageFile=$1
#分别获取文件名和文件类型
#截取文件名称，最后一个.号前面的字符
filehead=${imageFile%.*}

#获取输入的图形文件类型
imgType=`sips -g format $1 | awk -F: '{print $2}'`
#转换为字符串格式
typeStr=`echo $imgType`

#fileName2x=${imageFile/\.png/@2x\.png}
#fileName3x=${imageFile/\.png/@3x\.png}
fileName2x="$filehead""@2x.""$typeStr"
fileName3x="$filehead""@3x.""$typeStr"

#原图像默认为3X
cp $imageFile $fileName3x
#缩放2X图形
sips -z $height2x $width2x $1 --out $fileName2x
#缩放1x图形
sips -z $height1x $width1x $1
}
#>>>>>>>>>>>>>>>>>>>>>>>图片转为PNG<<<<<<<<<<<<<<<<<<<<<<<<
#如果图片不是PNG，则转换为png
ConvertToPng(){
#format string jpeg | tiff | png | gif | jp2 | pict | bmp | qtif | psd | sgi | tga
#获取输入的图形文件类型
imgType=`sips -g format $1 | awk -F: '{print $2}'`
#转换为字符串格式
typeStr=`echo $imgType`
if [ "$typeStr" = "png" ]
then
echo "$1为PNG图片，不需要转换"
#拷贝过去即可
cp $1 PngFolder/$1
else
echo "$1格式需要转换"
#文件全名称
filename=$1
#截取文件名称，最后一个.号前面的字符
filehead=${filename%.*}
#截取文件后缀名称，删除最后一个.前面的字符
#filelast=${filename##*.}
#转换为PNG格式图片
sips -s format png $1 --out PngFolder/${filehead}.png
fi
}
#>>>>>>>>>>>>>>>>>>>>>>>一键生成App图标<<<<<<<<<<<<<<<<<<<<<<<<
#自动生成icon
IconWithSize() {
#-Z 等比例按照给定尺寸缩放最长边。
 sips -Z $1 icon.png --out IconFolder/icon_$1x$1.png
}
#>>>>>>>>>>>>>>>>>>>>>>>一键生成App启动图片LaunchImage<<<<<<<<<<<<<<<<<<<<<<<<
#自动生成LaunchImage
LaunchWithSize() {
#iPhone 6Plus/6SPlus(Retina HD 5.5 @3x): 1242 x 2208
#iPhone 6/6S/(Retina HD 4.7 @2x): 750 x 1334
#iPhone 5/5S(Retina 4 @2x): 640 x 1136
#iPhone 4/4S(@2x): 640 x 960
case $1 in
    "960")
    sips -z 960 640 LaunchImage.png --out LaunchImageFolder/LaunchImage_960x640.png
    ;;

    "1136")
    sips -z 1136 640 LaunchImage.png --out LaunchImageFolder/LaunchImage_1134x640.png
    ;;

    "1334")
    sips -z 1334 750 LaunchImage.png --out LaunchImageFolder/LaunchImage_1334x750.png
    ;;

    "1792")
    sips -z 1792 828 LaunchImage.png --out LaunchImageFolder/LaunchImage_1792x828.png
    ;;

    "2208")
    sips -z 2208 1242 LaunchImage.png --out LaunchImageFolder/LaunchImage_2208x1242.png
    ;;

    "2436")
    sips -z 2436 1125 LaunchImage.png --out LaunchImageFolder/LaunchImage_2436x1125.png
    ;;

    "2688")
    sips -z 2688 1242 LaunchImage.png --out LaunchImageFolder/LaunchImage_2688x1242.png
    ;;
esac
}
#提示用户选择
echo "~~~~~~~~~~~~~~~~~~ 输入数字操作~~~~~~~~~~~~~~~"
echo "~~~~~~~~~ 1 一键生成AppIcon(图片名称需为icon) ~~~~~~~~~~~~"
echo "~~~~~~~~~ 2 一键生成App启动图(图片名称需为LaunchImage) ~~~~~~~~"
echo "~~~~~~~~~ 3 一键将所有PNG图片缩放为1x,2x,3x图片 ~~~~~~~~"
echo "~~~~~~~~~ 4 一键将所有图片转化为PNG格式 ~~~~~~~~"
# 读取用户输入并存到变量里
read parameter
sleep 0.5
#获取用户选择的字符串,切记=号两边不能有空格
method="$parameter"
# 判读用户是否有输入
if [ -n "$method" ]
then
##########################################
#一键生成App图标
    if [ "$method" = "1" ]
    then
        #先删除旧的
        rm -rf IconFolder
        # 再创建CEB文件夹
        mkdir IconFolder
        for size in 40 58 60 80 87 120 180 1024
        do
        IconWithSize $size
        done
##########################################
#创建启动页图片
    elif [ "$method" = "2" ]
    then
        #先删除旧的
        rm -rf LaunchImageFolder
        # 再创建CEB文件夹
        mkdir LaunchImageFolder
        for size in 960 1136 1334 1792 2208 2436 2688
        do
        LaunchWithSize $size
        done
##########################################
#自动生成1x，2x，3x图片
    elif [ "$method" = "3" ]
    then
        for file in ./*
        do
        #判断是否为文件，排除文件夹
        if [ -f "$file" ]
        then
        imageFile=$(basename $file)
        #判断是否是图片格式
        JudgeIsImage $imageFile
        boolIsImg=$?
           if [ $boolIsImg -eq 0 ]
           then
           ScalePic $imageFile
           fi
        fi
        done
##########################################
#转换格式
    elif [ "$method" = "4" ]
    then
        #先删除旧的
        rm -rf PngFolder
        # 再创建CEB文件夹
        mkdir PngFolder
        for file in ./*
        do
        #判断是否为文件，排除文件夹JudgeIsImage
        if [ -f "$file" ]
        then
        imageFile=$(basename $file)
        #判断是否是图片格式
        JudgeIsImage $imageFile
        boolIsImg=$?
            if [ $boolIsImg -eq 0 ]
            then
            ConvertToPng $imageFile
            fi
        fi
        done
##########################################
#参数无效
    else
        echo "参数无效，重新输入"
   fi
fi
