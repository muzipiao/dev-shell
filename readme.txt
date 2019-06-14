脚本介绍
1. 图片批处理：image-shell.sh
2. 自动化打包：auto-archive.sh
3. app转ipa：convert-ipa.sh
4. 图像界面 ：dev-shell.py

Python 图像界面仅支持 3.0 以上版本，例如 python3 拖入 dev-shell.py 到终端（注意 python3 后面有一个空格）。

-------------------------------------------------------

# image-shell.sh
直接使用步骤：
1. 将 image-shell.sh 脚本和要处理的图片拖放到同一个文件夹中；
2. 将 image-shell.sh 拖入终端，回车；
3. 根据提示，输入数字1或2或3或4，执行脚本；
4. 脚本会在原图片目录下新建文件夹，处理后的图片在新建文件夹中。

使用 Python 图形界面步骤：
1. 将 image-shell.sh 脚本和 dev-shell.py 脚本拖放到同一个文件夹中；
2. 打开终端，输入 python3和一个空格，拖入 dev-shell.py 到终端，回车；
3. 根据图形界面提示，选择文件或者文件夹，点击确定按钮；
4. 脚本会在原图片目录下新建文件夹，处理后的图片在新建文件夹中。

-------------------------------------------------------

# auto-archive.sh
直接使用步骤：
1. 将 auto-archive.sh 脚本复制到文件后缀名 .xcodeproj 所在项目目录下；
2. 将 auto-archive.sh 拖入终端，回车即可；
3. 如果自动打包失败，请打开 auto-archive.sh 配置项目信息；
4. 如果项目目录无 ExportOptions.plist 文件，请参考新建。

使用 Python 图形界面步骤：
1. 将 auto-archive.sh 脚本和 dev-shell.py 脚本拖放到同一个文件夹中；
2. 打开终端，输入 python3和一个空格，拖入 dev-shell.py 到终端，回车；
3. 根据图形界面提示，选择文件或者文件夹，点击确定按钮；
4. 如果脚本自动获取失败，请手动配置。

-------------------------------------------------------

# convert-ipa.sh
直接使用步骤：
1. 将 convert-ipa.sh 和 .app 后缀名文件放在同一个文件夹中;；
2. 将 convert-ipa.sh 拖入终端，回车即可；
3. 转换完成的 ipa 文件在 IPAFolder 文件夹中。

使用 Python 图形界面步骤：
1. 将 convert-ipa.sh 脚本和 dev-shell.py 脚本拖放到同一个文件夹中；
2. 打开终端，输入 python3和一个空格，拖入 dev-shell.py 到终端，回车；
3. 根据图形界面提示，选择文件，点击确定按钮。


