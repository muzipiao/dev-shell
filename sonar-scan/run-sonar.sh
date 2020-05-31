#!/bin/sh

# 检测参数
if [ -z "$1" ]; then
    echo "参数1：分支名称不能为空"
    exit 0
fi
echo "参数1："$1

if [ -z "$2" ]; then
    echo "参数2：xcodeproj 文件路径不能为空"
    exit 0
fi
echo "参数2："$2

if [ -z "$3" ]; then
    echo "参数3：scheme 名称不能为空"
    exit 0
fi
echo "参数3："$3

# 检测环境
if which xcodebuild 2>/dev/null; then
    echo 'xcodebuild exist'
else
    echo 'xcodebuild 未安装'
fi

if which oclint 2>/dev/null; then
    echo 'oclint exist'
else
    echo 'oclint 未安装'
    exit 0
fi

if which xcpretty 2>/dev/null; then
    echo 'xcpretty exist'
else
    echo 'xcpretty 未安装，执行 gem install xcpretty 安装'
    exit 0
fi

# 获取路径和scheme
proj_dir=$(dirname "$2")
cd "$proj_dir" || exit 0
echo "工程路径："$proj_dir

# 清除上次的缓存
if [ -d ./derivedData ]; then
    echo "清理缓存..."
    rm -rf ./derivedData
fi

myworkspace=$(basename "$2")
myscheme="$3"

# xcodebuild clean
xcodebuild clean -project "$myworkspace" -scheme "$myscheme" -sdk iphoneos -configuration Debug

# 生成编译数据
xcodebuild -project "$myworkspace" -scheme "$myscheme" -sdk iphoneos -configuration Debug \
arch=arm64 COMPILER_INDEX_STORE_ENABLE=NO | xcpretty -r json-compilation-database -o compile_commands.json

if [ -f ./compile_commands.json ]; then
    echo "编译数据生成完毕"
else
    echo "编译数据生成失败"
    exit 0
fi

# 生成报告目录
if [ ! -d ./sonar-reports ]; then
    mkdir sonar-reports
fi

# 删除旧报告
if [ -f sonar-reports/"$myscheme"_oclint.xml ]; then
    rm -f sonar-reports/"$myscheme"_oclint.xml
fi

# 分析编译数据
maxPriority=15000
# Disable rules
LINT_DISABLE_RULES="-disable-rule=LongClass \
-disable-rule=LongLine \
-disable-rule=LongMethod \
-disable-rule=LongVariableName \
-disable-rule=ShortVariableName \
-disable-rule=HighNcssMethod \
-disable-rule=DeepNestedBlock \
-disable-rule=TooManyFields \
-disable-rule=TooManyMethods \
-disable-rule=TooManyParameters \
-disable-rule=IvarAssignmentOutsideAccessorsOrInit"

oclint-json-compilation-database -- \
-report-type pmd -o sonar-reports/"$myscheme"_oclint.xml \
-max-priority-1=$maxPriority \
-max-priority-2=$maxPriority \
-max-priority-3=$maxPriority "$LINT_DISABLE_RULES"

if [ -f sonar-reports/"$myscheme"_oclint.xml ]; then
    echo "分析完成"
else
    echo "分析失败"
    exit 0
fi

sed -i '' 's/\&/\&amp;/g' sonar-reports/"$myscheme"_oclint.xml

# 生产配置文件
rm -f sonar-project.properties
cat > sonar-project.properties <<- EOF
sonar.projectKey=$1
sonar.projectName=$1
sonar.projectVersion=1.0
sonar.language=swift
sonar.sources=.
sonar.swift.simulator=platform=iphoneos,OS=latest
sonar.swift.project=$myworkspace
sonar.swift.appScheme=$myscheme
sonar.swift.appConfiguration=Debug
sonar.sourceEncoding=UTF-8
sonar.swift.excludedPathsFromCoverage=.*Tests.*
sonar.swift.tailor.config=--no-color --max-line-length=100 --max-file-length=500 --max-name-length=40 --max-name-length=40 --min-name-length=4
EOF

# 储存到 sonar 数据库
/bin/sh sonar-scanner -X
