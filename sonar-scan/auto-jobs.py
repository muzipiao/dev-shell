#!/usr/bin/env python
# coding=UTF-8

'''
g_old_branch 创建的模板文件 config.xml 中需要替换的分支名称
g_old_time 创建的模板文件 config.xml 中需要替换的触发时间
git_links.txt 组件的 Git 地址，逐行分开
config.xml 手动创建的一个 Jenkins 任务当做模板
批量创建完成结果在当前脚本的 xmls 文件夹下
'''

g_old_branch = "publicrepos/demo1"
g_old_time = "H(0-29)/19 * * * *"

import os, re

# 从URL获取分支名称，eg. [publicplugingoup, basemapcomponent]
def get_branch(link):
    link_list = link.split('/')
    if len(link_list) < 2:
        return []
    branch_name_git = link_list[-1]
    branch_group = link_list[-2]
    branch_name = branch_name_git.split('.')[0]
    return [branch_group, branch_name]

# 逐行读取文件中的链接
def read_txt(txt_path):
    links_list = [] # 储存行
    for line in open(txt_path):
        line = line.strip('\n')
        if line != "":
            links_list.append(line)
    return links_list

# 根据当前索引顺序算出下一个时间，索引、时间步长、起始小时，起始分钟
def get_scm_time(index, step, start_hour, start_minute):
    next_hour = ((start_hour * 60 + start_minute + step * index)%1440)/60 # 小时
    begin_minute = (step * index)%60
    next_minute = begin_minute + step - 1
    if next_minute > 59:
        begin_minute = 0
        next_minute = step
    next_time = "H(" + str(begin_minute) + "-" +str(next_minute) + ") " + str(next_hour) + " * * *"
    return next_time

 # 创建 config.xml 文件，传入链接列表，创建文件的保存路径, config.xml 文件路径
def create_xml(links_list, xmls_folder, config_path):
    config_lines = [] # 储存行
    for line in open(config_path):
        config_lines.append(line)
    # 遍历链接列表
    for index, link in enumerate(links_list):
        branch_group_name = get_branch(link)
        if len(branch_group_name) < 2:
            print("链接无效：" + link)
            continue
        branch_group = branch_group_name[0] # 分组名
        branch_name = branch_group_name[1] # 分支名称
        # 创建文件保存到以分支名命名的文件夹中
        branch_folder = xmls_folder + "/" + branch_name
        if not os.path.exists(branch_folder):
            os.system('mkdir ' + branch_folder)
        else:
            os.system('rm -rf ' + branch_folder)
        config_xml_path = branch_folder + "/config.xml"
        # 获取下一个运行的时间, 时间从0点0分开始，每10分钟运行一个组件
        new_time = get_scm_time(index, 10, 0, 0)
        config_copy = []
        for cg_line in config_lines:
            temp_line = cg_line
            if g_old_branch in temp_line:
                temp_line = temp_line.replace(g_old_branch, branch_group + "/" +branch_name)
            if g_old_time in temp_line:
                temp_line = temp_line.replace(g_old_time, new_time)
            config_copy.append(temp_line)
        xml_str = "".join(config_copy)
        with open(config_xml_path, 'w+') as f:
            f.write(xml_str)
        print("已创建" + str(index) + "：" + branch_group + "/" + branch_name + new_time)

# main
if __name__ == "__main__":
    xmls_folder = os.path.dirname(os.path.abspath(__file__)) + "/xmls"
    if os.path.exists(xmls_folder):
        os.system('rm -rf ' + xmls_folder)
    os.system('mkdir ' + xmls_folder)
    links_path = os.path.dirname(os.path.abspath(__file__))+ "/git_links.txt"
    links_list = read_txt(links_path)
    config_path = os.path.dirname(os.path.abspath(__file__))+ "/config.xml"
    create_xml(links_list, xmls_folder, config_path)
