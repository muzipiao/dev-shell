#!/bin/sh

#
#  Created by PacteraLF on 17/4/17.
#  Copyright © 2017年 PacteraLF. All rights reserved.

# 将此脚本放入project文件同级目录下即可
cd $(dirname $0)

#注意：脚本目录和xxx.app要在同一个目录，如果放到其他目录，请自行修改脚本。
#包名称(以.app为后缀名的包名称)
#这里请将双引号里面的名称改为你xxx.app的名称
App_Name="这里替换为你的.app的文件名，不包含后缀"

# 先删除里面当前的IPAFolder文件夹
rm -rf IPAFolder
# 再创建IPAFolder文件夹
mkdir IPAFolder
# 在文件夹里面创建Payload文件夹
mkdir IPAFolder/Payload
# 将当前目录下的App_Name.app复制到Payload里面
cp -r $App_Name.app IPAFolder/Payload/$App_Name.app
# IPA包制作中可忽略iTunesArtwork这个图标，经过发现，可以不要这个图标，打包的时候只吧目录打进去即可
# cp Icon.png IPAFolder/iTunesArtwork
# 进入CEB文件夹
cd IPAFolder
# 压缩多个目录zip FileName.zip 目录1 目录2 目录3....
# zip -r $App_Name.ipa Payload iTunesArtwork
zip -r $App_Name.ipa Payload

exit 0
