# 抽取一些通用的方法
# --------------------1、进入项目文件夹，配置或者拖入项目文件夹--------------------
CdProjectPath(){
    temp_project_folder_path=$1
    if [ -d "$temp_project_folder_path" ]; then
        echo "*** 项目路径:$temp_project_folder_path ***"
        # 进入文件夹
        cd $temp_project_folder_path
    else
        echo "*** 项目路径错误，请输入或者拖入项目的文件夹的绝对路径 ***"
        echo $temp_project_folder_path
        read pf_path_para
        sleep 0.5
        # 递归调用
        CdProjectPath $pf_path_para
    fi
}

#--------------------2、清除项目中重复的Info.plist防止打包错误--------------------
DelDuplicateInfo(){
    # 删除Resources文件下Info.plist
    echo "*** 删除Resources/Info.plist ***"
    resour_info="Resources/Info.plist"
    rm $resour_info
    # 清除pbxproj文件中Info.plist的索引B04709921B2ADD0800737722和B04709941B2ADD0800737722
    temp_pbxproj_file_path=$1
    sed -i "" "/B04709921B2ADD0800737722/d" ${temp_pbxproj_file_path}
    sed -i "" "/B04709941B2ADD0800737722/d" ${temp_pbxproj_file_path}
}

#-------------------3、配置project.pbxproj文件中描述文件-------------------
ConfigProjectProvison(){
    # project.pbxproj文件
    project_file=$1
    # 描述文件名称
    provison_name=$2
    # 描述文件的值
    provison_value=$3
    # 首先替换描述文件名称
    sed -i "" "s/PROVISIONING_PROFILE_SPECIFIER = .*;/PROVISIONING_PROFILE_SPECIFIER = ${provison_name};/g" ${project_file}
    # 再替换描述文件的值
    prov_name_list=$(sed -n -e "/PROVISIONING_PROFILE_SPECIFIER = */=" ${project_file})
    for value in $prov_name_list
    do
        begin_line=$(expr $value - 1)
        end_line=$(expr $value + 1)
        sed -i "" "${begin_line},${end_line}s/PROVISIONING_PROFILE = \".*\"/PROVISIONING_PROFILE = \"${provison_value}\"/g" ${project_file}
    done
    echo "*** target描述文件配置完成 ***"
}

#-------------------4、Prod生产环境要求输入BundleVersion-------------------
ReadTargetBundleVersion(){
    # 读取用户输入的CFBundleVersion
    echo "*** 请输入CFBundleVersion如4.2.0 ***"
    read app_version_para
    sleep 0.5
    #获取用户选择的字符串,切记=号两边不能有空格
    app_version="$app_version_para"
    # 判读用户是否有输入
    if [ -n "$app_version" ]; then
        # 将输入的版本号传给环境变量
        bundle_version=$app_version
    else
        echo "*** 生产版本BundleVersion不能为空 ***"
        ReadTargetBundleVersion
    fi
}

#--------------------5、删除ConfigManager.h旧的自动配置--------------------
RemoveConfigFileOldDefine(){
    temp_config_file=$1
    # 逐行读取文件删除旧的配置，查找需要删除的行
    index=0
    while read line
    do
        # －c：只输出匹配行的计数,这里如果为空行输出1，否则是0
        isBlankLine=$(echo $line | grep -c "^$")
        # 是否有#define的前缀，有输出结果，否则为空
        isHasDefinePre=$(echo $line | grep "^\#define")
        # -n判断变量的值，非空返回true
        if [ -n "$isHasDefinePre" ] || [ $isBlankLine -eq 1 ]; then
            index=`expr $index + 1`
        else
            break
        fi
    done < $temp_config_file
    # 如果匹配结果大于0，则删除这些行
    if [ $index -gt 0 ]; then
        sed -i '' '1,'$index'd' $temp_config_file
        echo "*** Config.h文件删除1--"$index"行 ***"
    fi
}

#-------------------6、配置ConfigManager.h文件IP-------------------
DeployConfigManager(){
    # 配置文件Config.h
    temp_config_file=$1

    # 配置文件前缀
    base_url_pre="#define BASE_URL @"
    app_version_pre="#define APP_VERSION @"
    pub_key_pre="#define PUB_KEY @"
    jgid_pre="#define JGID @"

    # 将文件中以这些前缀的所有行全部注释掉,在行前面加上//
    sed -i "" "s/^${base_url_pre}/\/\/&/g" ${temp_config_file}
    sed -i "" "s/^${app_version_pre}/\/\/&/g" ${temp_config_file}
    sed -i "" "s/^${pub_key_pre}/\/\/&/g" ${temp_config_file}
    sed -i "" "s/^${jgid_pre}/\/\/&/g" ${temp_config_file}

    # 读取配置文件中的配置
    base_url=${BASE_URL}
    app_version=${APP_VERSION}
    pub_key=${PUB_KEY}
    jgid=${JGID}

    # 将空格都转换为[[:space:]]，插入不能有空格
    base_url_space=$(echo $base_url|sed "s/ /[[:space:]]/g")
    app_version_space=$(echo $app_version|sed "s/ /[[:space:]]/g")
    pub_key_space=$(echo $pub_key|sed "s/ /[[:space:]]/g")
    jgid_space=$(echo $jgid|sed "s/ /[[:space:]]/g")

    # 在首行插入配置，方便核对查看
    sed -i '' '1i\
    '$base_url_space'\
    '$app_version_space'\
    '$pub_key_space'\
    '$jgid_space'\
    ' ${temp_config_file}

    # 替换掉所有的[[:space:]]为空格,搜索前100行即可，配置超过100行更改数字即可
    sed -i '' '1,100s/\[\[:space:\]\]/ /g' ${temp_config_file}
    echo "*** Config.h文件配置完成 ***"
}

#--------------------7、配置Info.plist文件--------------------
DeployInfoFile(){
    temp_Info_file=$1
    temp_bundle_version=$2
#    sed -i "" "/<key>CFBundleShortVersionString<\/key>/{ n; s/\(<string>\).*\(<\/string>\)/\1${temp_bundle_version}\2/;}" ${temp_Info_file}
#    sed -i "" "/<key>CFBundleVersion<\/key>/{ n; s/\(<string>\).*\(<\/string>\)/\1${temp_bundle_version}\2/;}" ${temp_Info_file}
    /usr/libexec/PlistBuddy -c 'Set :CFBundleShortVersionString '${temp_bundle_version}'' ${temp_Info_file}
    /usr/libexec/PlistBuddy -c 'Set :CFBundleVersion '${temp_bundle_version}'' ${temp_Info_file}
    echo "*** Info.plist文件配置完成 ***"
}

#------------------8、配置ExportOptions.plist文件----------------
DeployExportOptionsFile(){
    # 配置ExportOptions.plist
    temp_export_options_file=$1
    temp_mobile_provison=$2
    #sed -i "" "/<key>provisioningProfiles<\/key>/{ n; s/\(<string>\).*\(<\/string>\)/\1${temp_mobile_provison}\2/;}" ${temp_export_options_file}
    /usr/libexec/PlistBuddy -c 'Set :provisioningProfiles:com.cebbank.xyk '${temp_mobile_provison}'' ${temp_export_options_file}
    echo "*** ExportOptions.plist文件配置完成 ***"
}




