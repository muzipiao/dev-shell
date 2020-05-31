#!/usr/bin/env python
# coding=UTF-8

'''
g_repos_folder 下拉代码，存放组件代码的路径
'''

g_repos_folder = "/Desktop/GitJH"

import sys, os, platform

# 找到 xcodeproj 工程文件
def find_project(branch_dir):
    proj_path = ""
    for home, dirs, files in os.walk(branch_dir):
        for temp_dir in dirs:
            name_array = os.path.splitext(temp_dir)
            if len(name_array) < 2:
                continue
            file_suffix = name_array[1] # 获取后缀
            if file_suffix.lower() == ".xcodeproj":
                proj_path = os.path.join(home, temp_dir)
                break
    return proj_path

# 获取所有scheme
def get_schemes(proj_path):
    proj_folder = os.path.dirname(proj_path)
    xcodebuild_list = os.popen('cd ' + proj_folder + ' && xcodebuild -list')
    scheme_list = []
    sch_flag = False # 标记找到Scheme
    for line in xcodebuild_list:
        temp_line = line.strip()
        if "Schemes:" in temp_line:
            sch_flag = True
            continue
        if sch_flag == True and temp_line != "" and not temp_line.lower().endswith("bundle") and not " " in temp_line:
            scheme_list.append(temp_line)
        if temp_line == "":
            sch_flag = False
    return scheme_list

# 自动拉取分支
def git_clone(argv_list, branch_dir):
    branch_group = argv_list[0] # 参数1 分组名称
    branch_name = argv_list[1] # 参数2 分支名称
    branch_path = branch_dir + "/" + branch_name
    # http://192.168.1.44/publicrepos/demo1.git
    branch_link = "http://192.168.1.44/" + branch_group + "/" + branch_name  + ".git"
    git_pwd = "cd " + branch_dir +" && git clone " + branch_link
    if os.path.exists(branch_path):
        git_pwd = "cd " + branch_path +" && git pull origin master"
    os.system(git_pwd)
    print("拉取：" + branch_name)

# 自动化 sonar 扫描
def auto_sonar(argvs):
    argv_list = argvs[:-4].split("/")
    if len(argv_list) < 2:
        print("Python 参数错误")
        return
    branch_name = argv_list[1]
    # 分支绝对路径
    branch_dir = os.path.expanduser('~') + g_repos_folder
    branch_path = branch_dir + "/" + branch_name
    print("分支路径：" + branch_path)
    # 拉取或者clone分支
    git_clone(argv_list, branch_dir)
    # 找到工程文件
    proj_path = find_project(branch_path)
    print("工程路径：" + proj_path)
    # 找到所有scheme
    scheme_list = get_schemes(proj_path)
    print("scheme 列表：" + str(scheme_list))
    # shell 参数，参数1：分支名称；参数2：xcodeproj 文件全路径；参数3：scheme
    for scheme in scheme_list:
        sh_path = os.path.dirname(os.path.abspath(__file__)) + '/run-sonar.sh'
        os.system("chmod 777 " + sh_path)
        sonar_pwd = 'sh '+ sh_path + ' ' + branch_name + ' ' + proj_path + ' ' + scheme
        os.system(sonar_pwd)

# 主程序
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("python 参数必须带上 分组/分支名称")
        sys.exit(0)
    else:
        auto_sonar(str(sys.argv[1]))

