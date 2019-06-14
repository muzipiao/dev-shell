# Mac 端 Shell 脚本

Mac 上一些常用的**批处理脚本**，类似 Windows 电脑上常用的 Batch 批处理脚本文件。收集开发中常用到的 Shell 脚本，下载后可根据需求修改使用。 

|类型|说明|备注|
|:---|:---|:---|
|生成 AppIcon|一键缩放图片生成 App 所有尺寸 icon 图标。||
|生成 LaunchImage|一键缩放图片生成 App 所需启动图。||
|生成 2x/3x 图片|一键将文件夹内图片生成 2x/3x 图片并自动重命名。||
|图片转 PNG 格式|一键将文件夹内所有图片转为 PNG 格式。||
|自动化打包|利用 xcodebuild 指令将项目打包为 ipa。||
|app 转 ipa|将项目编译后的 .app 文件转换为 ipa 文件。||

## 基于 tkinter 的简易图像界面

![python 图像界面](https://raw.githubusercontent.com/muzipiao/GitHubImages/master/dev-shell/shell_py.png)

## 直接使用终端操作

![python 图像界面](https://raw.githubusercontent.com/muzipiao/GitHubImages/master/dev-shell/shell_cmd.png)

## Shell 脚本用法（以图片批处理为例）

直接在 Mac 的终端中使用：

1. 将 image-shell.sh 脚本和要处理的图片拖放到同一个文件夹中；
2. 将 image-shell.sh 拖入终端，回车；
3. 根据提示，输入数字1或2或3或4，执行脚本；
4. 脚本会在原图片目录下新建文件夹，处理后的图片在新建文件夹中。

使用 Python 图形界面：

1. 将 image-shell.sh 脚本和 dev-shell.py 脚本拖放到同一个文件夹中；
2. 打开终端，输入 python3 (注意有一个空格)，拖入 dev-shell.py 到终端，回车；
3. 根据图形界面提示，选择文件或者文件夹，点击确定按钮；
4. 脚本会在原图片目录下新建文件夹，处理后的图片在新建文件夹中。

## 修改 Shell 脚本

增加 AppIcon 或 LaunchImage 的尺寸类型

AppIcon 尺寸包含 40×40 58×58 60×60 80×80 87×87 120×120 180×180 1024×1024，如果需要特殊尺寸，在下方的for循环处添加相应的数字即可。LaunchImage 尺寸包含 960x640，1134x640，1334x750，2208x1242 等等，如果需要其他尺寸，方法相同。

![增加尺寸类型](https://raw.githubusercontent.com/muzipiao/GitHubImages/master/dev-shell/shell_edit.png)

LaunchImage 的尺寸类型

手机型号 | 屏幕尺寸 | 屏幕密度 | 逻辑尺寸 | 逻辑像素 | 缩放倍数
---|---|---|---|---|---
4/4S | 3.5英寸 | 326ppi | 320*480pt | 640*960px | @2x
5/5S/5c | 4英寸 | 326ppi | 320*480pt | 640*1136px | @2x
6/6S/7/8 | 4.7英寸 | 326ppi | 375*667pt | 750*1334p | @2x
6+/6S+/7+/8+ | 5.5英寸 | 401ppi | 414*736pt | 1242*2208px | @3x
X | 5.8英寸 | 458ppi | 375*812pt | 1125*2436px | @3x
XS | 5.8英寸 | 458ppi | 375*812pt | 1125*2436px | @3x
XS Max | 6.5英寸 | 458ppi | 414*896pt | 1242*2688px | @3x
XR | 6.1英寸 | 326ppi | 414*896pt | 828*1792px | @2x

## JPEG 与 PNG 图片格式

1. 使用 Shell 脚本或苹果图片预览工具转换，转换图片格式时，若原来不包含 Alpha 通道，则会将缺失的 Alpha 通道值补为1，体积会变大。
2. JPEG 图片格式，只包含RGB通道颜色，体积小，适合网络传输和打印；而 PNG 图片格式，除了包含RGB颜色外，还包含Alpha透明通道。
3. PNG 图片格式是苹果官方推荐的格式，因为iOS系统会用到大量的透明效果，而且 PNG 图片支持硬解码，使界面更流畅。

如果您觉得有所帮助，请在[GitHub](https://github.com/muzipiao/dev-shell)上赏个Star ⭐️，您的鼓励是我前进的动力。
