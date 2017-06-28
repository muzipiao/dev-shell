#注意：脚本目录和xxxx.xcodeproj要在同一个目录，如果放到其他目录，请自行修改脚本。
#工程名字(Target名字)
Project_Name="这里替换为你的项目名称"
#配置环境，Release或者Debug
Configuration="Release"

#AdHoc版本的Bundle ID
AdHocBundleID="xxx.xxx.xxx"

# ADHOC
#证书名#描述文件
ADHOCCODE_SIGN_IDENTITY="这里替换为你的证书名称"
ADHOCPROVISIONING_PROFILE_NAME="这里替换为你的描述文件名称"

#加载各个版本的plist文件
ADHOCExportOptionsPlist="./Info.plist"
ADHOCExportOptionsPlist=${ADHOCExportOptionsPlist}

#clean下，防止有缓存
xcodebuild clean -xcodeproj ./$Project_Name.xcodeproj -configuration $Configuration -alltargets

#${varible:n1:n2}
#xcodebuild archive -project 项目名称.xcodeproj -scheme 项目名称 -configuration Release -archivePath archive包存储路径 CODE_SIGN_IDENTITY=证书 PROVISIONING_PROFILE=描述文件UUID
xcodebuild -project $Project_Name.xcodeproj -scheme ${Project_Name:0:3} -configuration $Configuration -archivePath build/$Project_Name-adhoc.xcarchive clean archive build  CODE_SIGN_IDENTITY="${ADHOCCODE_SIGN_IDENTITY}" PROVISIONING_PROFILE="${ADHOCPROVISIONING_PROFILE_NAME}" PRODUCT_BUNDLE_IDENTIFIER="${AdHocBundleID}"
#xcodebuild -exportArchive -exportFormat ipa文件格式 -archivePath archive包存储路径 -exportPath ipa包存储路径  -exportProvisioningProfile 描述文件名称，同上，在这里就不需要添加了。
xcodebuild -exportArchive -archivePath build/$Project_Name-adhoc.xcarchive -exportOptionsPlist $ADHOCExportOptionsPlist -exportPath ~/Desktop/$Project_Name-adhoc.ipa
