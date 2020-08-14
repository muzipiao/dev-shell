#!/usr/bin/env python3
# coding=UTF-8

'''
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
readme: 查找路径下文件中是否包含关键词，支持查找全部文件，指定类型文件
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'''

import os, shutil

g_keyword = "文件中关键词，支持正则"   # 待扫描的关键词names:@\"notiname\"
g_filetype = "h,m"  # 待扫描的文件类型，多个类型用逗号隔开m,mm,a
g_scan_dir = os.path.expanduser("~/Desktop/GitFolder")      # 待扫描的文件夹
g_result_dir = os.path.expanduser("~/Desktop/result")   # 扫描结果存放路径

def grep_search(git_dir:str, keyword:str, file_type:str):
    grep_cmd:str = "grep -rl "
    # 是否显示扫描类型
    type_count = len(file_type.split(","))
    if type_count > 0:
        grep_cmd = grep_cmd + "--include=\*."
        type_str = "{" + file_type + "}" if type_count > 1 else file_type
        grep_cmd = grep_cmd + type_str
    # 关键词和路径
    grep_cmd = grep_cmd + " \'" + keyword + "\' " + git_dir
    print("*" * 30 + "开始执行 grep 命令" + "*" * 30)
    print(grep_cmd)
    result_str = os.popen(grep_cmd).read()
    print("*" * 30 + "结束执行 grep 命令" + "*" * 30)
    if len(result_str) == 0:
        return ""
    return result_str


# 保存搜索到的文件列表
def save_list(files_str:str, txt_path:str):
    print("搜索结果已保存到 TXT 文件：" + txt_path)
    with open(txt_path, 'w+') as f:
        f.write(files_str)


# 将搜索到文件拷贝到指定文件夹
def cpy_files(files_str:str, save_folder:str):
    files_list = files_str.split("\n")
    files_list.remove("")
    print("总共搜索到包含关键词的文件个数：" + str(len(files_list)))
    if len(files_list) > 0:
        print("搜索到文件已复制到：" + save_folder)
    for line in files_list:
        file_path = line.strip()
        if len(file_path) == 0:
            continue
        dst_name = os.path.basename(file_path)
        dst_path = os.path.join(save_folder, dst_name)
        shutil.copyfile(line, dst_path)


if __name__ == "__main__":
    # grep 遍历搜索文件夹关键词
    files_str = grep_search(g_scan_dir, g_keyword, g_filetype)
    # 将搜索的关键词保存到TXT
    if os.path.exists(g_result_dir) == False:
        os.makedirs(g_result_dir)
    txt_path = g_result_dir + "/result.txt"
    save_list(files_str, txt_path)
    # 将搜索到文件 Copy 到指定文件夹
    cpy_files(files_str, g_result_dir)

