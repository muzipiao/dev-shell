# MacShell 脚本

## 一、脚本简介

在 Mac 电脑上最常用的**批处理脚本**就是 Shell 了，就像在 Windows 电脑上常用的 Batch 批处理脚本文件。收集开发中常用到的 Shell 脚本，下载后可根据需求修改即可。

### Mac 使用 Shell 处理图片脚本

- 一键缩放图片生成 App 所有尺寸 icon 图标。
- 一键缩放图片生成 App 所需启动图。
- 一键将文件夹内图片生成 1x/2x/3x 图片并自动重命名。
- 一键将文件夹内所有图片转为 PNG 格式。

一些常用的图片批量处理脚本，使用的时候比较方便。
  
### 利用 Shell 脚本自动化打 ipa 包脚本

将此脚本比较简单，但需要提交配置好项目描述文件，配置文件和版本号等，将此脚本拖入项目文件夹下，
利用 xcodebuild 指令将项目打包为 ipa，脚本应与 Project 文件同目录下。

### 利用 Shell 自动配置项目并打包脚本

- 自动读取配置的项目路径或者拖入终端即可。
- 可配置删除指定的文件及清除pbxproj文件引用。
- 自动修改配置project.pbxproj文件中的描述文件。
- 可根据需要，修改项目中的一些配置文件。
- 自动修改配置项目 info.plist 文件的版本号。
- 自动修改配置 ExportOptions.plist 文件。
- 电脑安装多版本 XCode 时，自动切换 XCode 为指定版本。

使用此脚本需要一定的脚本基础，根据项目实际情况修改使用，分享供大家参考。
  
### 将 .app 文件转换为 .ipa 文件脚本

将项目编译后的 .app 文件转换为 ipa 文件，此脚本比较简单，不多介绍。

### 脚本用法示例之图片处理

在 Mac 的终端中，将 Shell 文件放在图片同级目录下 —> 拖入 Shell 文件到终端 —> 回车 -> 输入 1 或 2 或 3 或 4 即可进行对应操作,如图：

![](https://github.com/muzipiao/GitHubImages/blob/master/CreateiPhoneIconShellBlogImages/1.png)

## 二、Shell 脚本用法示例（以 CreateiPhoneIconShell.sh 为例）

### 2.1、例如你要处理的图片文件放在桌面上的 images 文件中

![](https://github.com/muzipiao/GitHubImages/blob/master/CreateiPhoneIconShellBlogImages/2.png)

### 2.2、把要作为图标的图片命名为 icon

![](https://github.com/muzipiao/GitHubImages/blob/master/CreateiPhoneIconShellBlogImages/3.png)

### 2.3、需要在终端中用 cd 命令先进入此文件夹，终端输入 cd 空格（cd后面有一个空格），然后拖入你桌面的 images 文件夹

![](https://github.com/muzipiao/GitHubImages/blob/master/CreateiPhoneIconShellBlogImages/4.png)
![](https://github.com/muzipiao/GitHubImages/blob/master/CreateiPhoneIconShellBlogImages/5.png)

### 2.4、同理，再拖入所用到的 Shell 文件，然后回车确认

![](https://github.com/muzipiao/GitHubImages/blob/master/CreateiPhoneIconShellBlogImages/6.png)

### 2.5、显示界面如下，如果需要生成 AppIcon 图标，则输入数字 1，回车

![](https://github.com/muzipiao/GitHubImages/blob/master/CreateiPhoneIconShellBlogImages/7.png)

### 2.6、JPG 与 PNG 注意点：

由于我在网上找到的是` JPG `图片，转为` PNG `图片后，` Alpha 通道`颜色异常，所以有` CGColor `颜色警告，正常` PNG `图片处理是没有<...>部分的，有警告但不影响使用。

![](https://github.com/muzipiao/GitHubImages/blob/master/CreateiPhoneIconShellBlogImages/8.png)


## 三、注意点

### 3.1、生成 AppIcon 注意点（苹果官方要求**PNG**格式）

图片名称需要为 icon.png ，尺寸目前包括 40×40 58×58 60×60 80×80 87×87 120×120 180×180 1024×1024，如果需要特殊尺寸，在下方的for循环处添加相应的数字即可。

![](https://github.com/muzipiao/GitHubImages/blob/master/CreateiPhoneIconShellBlogImages/9.png)

### 3.2、生成 App 启动图片 LaunchImage 注意点(苹果官方要求` PNG `格式)

要作为启动图片的名称需要为 LaunchImage.png，目前按照屏幕尺寸默认生成尺寸为 960x640，1134x640，1334x750，2208x1242 等等，如果需要其他尺寸，方法同上，自己到Shell文件中修改相应尺寸数字即可。

#### iPhone屏幕尺寸一览

手机型号 | 屏幕尺寸 | 屏幕密度 | 逻辑尺寸 | 逻辑像素 | 缩放倍数
---|---|---|---|---|---
4/4S | 	3.5英寸 | 326ppi | 320*480pt | 640*960px | @2x
5/5S/5c | 4英寸 | 326ppi | 320*480pt | 640*1136px | @2x
6/6S/7/8 | 4.7英寸 | 326ppi | 375*667pt | 750*1334p | @2x
6+/6S+/7+/8+ | 5.5英寸 | 401ppi | 414*736pt | 1242*2208px | @3x
X | 5.8英寸 | 458ppi | 375*812pt | 1125*2436px | @3x
XS | 5.8英寸 | 458ppi | 375*812pt | 1125*2436px | @3x
XS Max | 6.5英寸 | 458ppi | 414*896pt | 1242*2688px | @3x
XR | 6.1英寸 | 326ppi | 414*896pt | 828*1792px | @2x

#### 生成 LaunchImage 的脚本预览

```shell
#>>>>>>>>>>一键生成App启动图片LaunchImage<<<<<<<<<<<<<
#自动生成LaunchImage
LaunchWithSize() {
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
```

### 3.3、批量生成1x，2x，3x图片

1. 将当前文件夹下所有图片缩放为1x，2x，3x图片，并自动命名；
2. 注意：如果icon.png和LaunchImage.png也在当前图片文件下，也会生成1x，2x，3x图片。

### 3.4、批量将图片转为PNG格式

1. 会将当前文件夹下所有图片转换为PNG格式；
2. 注意，用Shell脚本和用苹果图片预览工具另存为转换，都是仅仅转换图片格式，简单的将缺失Alpha通道色都补为1，体积会变大；
3. 例如JPEG图片格式，只包含RGB通道颜色，体积小，适合网络传输和打印；而PNG图片格式，除了包含RGB颜色外，还包含Alpha透明通道；
4. PNG图片格式是苹果官方推荐的格式，因为iOS系统会用到大量的透明效果，而且PNG图片支持硬解码，使界面更流畅。

### 3.5、自动配置项目脚本

此脚本供参考，需要一定的脚本基础，根据项目实际情况修改使用。

```shell
# 主Shell文件，配置文件填写完成后，将此文件拖入到终端即可。

shell_path=$(cd `dirname $0`; pwd)
# 导入公共方法和环境变量
cd `dirname $0`
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
        ip_file_name=""$shell_path"/arch_config/"$ip_file_name$method".txt"
    elif [ "$method" = "prod" ]; then
        ip_file_name=""$shell_path"/arch_config/"$ip_file_name$method".txt"
        # 生产要求输入BundleVersion，存到bundle_version
        if ["$bundle_prod_version" = ""]; then
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

```

----------

如果您觉得有所帮助，请在[GitHub](https://github.com/muzipiao/MacShell)上赏个Star ⭐️，您的鼓励是我前进的动力。
