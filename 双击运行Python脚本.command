#!/bin/sh
# 双击此文件会运行 python 界面python3 dev-shell.py

cd "$(dirname "$0")" || exit 0

py_version=$(python3 -V | grep -i "Python\ 3")

if [ -z "$py_version" ]; then
    echo "检测到未安装 Python3，执行 brew install python3 安装"
    exit 0
fi

# 执行 Python 文件
echo "Python 版本：$py_version"
python3 dev-shell.py