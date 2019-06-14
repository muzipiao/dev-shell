from tkinter import *
from tkinter import filedialog, messagebox
import os, subprocess, imghdr


# ----------------------- image -----------------------
class ImgHandle:
    def __init__(self, master):
        self._master = master
        self._frame = Frame(master)
        self._frame.grid()
        self._str_var = StringVar()
        # 当前处理图片的类型
        self._handle_type = ''
        self._tip_msg = ''

    def create_app_icon(self):
        self._handle_type = 'ka'
        self._tip_msg = '提示：请选择一张图片生成所有尺寸 AppIcon，图片大小最好为 1024px x 1024px。'
        self.create_ui()

    def create_launch_image(self):
        self._handle_type = 'kb'
        self._tip_msg = '提示：请选择一张竖屏图片生成 LaunchImage，部分图片会变形，图片作为 Demo 测试用。'
        self.create_ui()

    def convert_2x3x(self):
        self._handle_type = 'kc'
        self._tip_msg = '提示：请选择想要转换为 2x 3x 图片的目录，一键为目录下所有图片生产 2x 3x 图片。'
        self.create_ui()

    def convert_png(self):
        self._handle_type = 'kd'
        self._tip_msg = '提示：请选择想要转换为 PNG 格式的图片目录，一键将目录下所有图片转换为 PNG 格式。'
        self.create_ui()

    # 创建界面
    def create_ui(self):
        img_frame = self._frame
        field_width = 40
        pad_width = 35
        # 提示
        tip_label = Label(img_frame, text=self._tip_msg, fg='DarkCyan')
        path_label = Label(img_frame, text='项目路径：', fg='black')

        # 选择项目路径按钮
        self._str_var.set('输入或者选择路径')

        path_input = Entry(img_frame, textvariable=self._str_var, width=field_width)
        select_path_btn = Button(img_frame, text='选择路径', command=self.select_path_btn_click)
        # 提交按钮
        sure_btn = Button(img_frame, text='确定', command=self.sure_btn_click)
        # 布局
        tip_label.grid(row=0, column=0, padx=5, pady=5, rowspan=1, columnspan=3, sticky=W)
        path_label.grid(row=1, column=0, padx=5, pady=5)
        path_input.grid(row=1, column=1, padx=5, pady=5)
        select_path_btn.grid(row=1, column=2, padx=5, pady=5)
        sure_btn.grid(row=3, column=0, padx=pad_width, pady=pad_width, rowspan=2, columnspan=3, sticky=NSEW)

    def select_path_btn_click(self):
        if self._handle_type == 'ka' or self._handle_type == 'kb':
            file_path = filedialog.askopenfilename()
        else:
            file_path = filedialog.askdirectory()
        if len(file_path) > 0:
            self._str_var.set(file_path)

    def sure_btn_click(self):
        dst_path = self._str_var.get()
        # 如果是图片，则判断图片格式
        if self._handle_type == 'ka' or self._handle_type == 'kb':
            if not self.judge_img(dst_path):
                return

        # 如果是路径，判断路径合法性
        if self._handle_type == 'kc' or self._handle_type == 'kd':
            if not self.judge_path(dst_path):
                return

        # 判断 shell 脚本是否存在
        if not os.path.isfile('image-shell.sh'):
            messagebox.showinfo(title='提示', message='请将 image-shell.sh 文件拖到 python 脚本所在目录')
            return
        # 如果选择的是文件，则将文件名称和目录分开
        file_name = os.path.basename(dst_path)
        dir_path = os.path.dirname(dst_path)
        if self._handle_type == 'ka':
            os.system('. ./image-shell.sh python ' + '&& cd ' + dir_path + ' && CreateIconImage ' + file_name)
            messagebox.showinfo(title='提示', message='图片已经保存到图片目录下的 IconFolder 文件夹中')
        elif self._handle_type == 'kb':
            os.system('. ./image-shell.sh python ' + '&& cd ' + dir_path + ' && CreateLaunchImage ' + file_name)
            messagebox.showinfo(title='提示', message='图片已经保存到图片目录下的 LaunchImageFolder 文件夹中')
        elif self._handle_type == 'kc':
            os.system('. ./image-shell.sh python ' + '&& cd ' + dst_path + ' && CreateXXImage')
            messagebox.showinfo(title='提示', message='图片已经保存到图片目录下的 XXFolder 文件夹中')
        elif self._handle_type == 'kd':
            os.system('. ./image-shell.sh python ' + '&& cd ' + dst_path + ' && ConvertAllToPng')
            messagebox.showinfo(title='提示', message='图片已经保存到图片目录下的 PngFolder 文件夹中')

    # 判断图片格式
    @staticmethod
    def judge_img(file_path):
        # 判断文件是否存在
        if not os.path.isfile(file_path):
            messagebox.showinfo(title='提示', message='文件不存在')
            return False
        # sips 支持的图片格式
        img_types_str = 'jpeg | tiff | png | gif | jp2 | pict | bmp | qtif | psd | sgi | tga'
        with open(file_path, 'rb') as img_file:
            img_type = imghdr.what(img_file)
            if img_type is None or img_type not in img_types_str:
                messagebox.showinfo(title='提示',
                                    message='不支持的图片格式\n支持的格式为 jpeg | tiff | png | gif'
                                            ' | jp2 | pict | bmp | qtif | psd | sgi | tga')
                return False
        return True

    # 判断路径
    @staticmethod
    def judge_path(dir_path):
        # 判断是否为路径
        if not os.path.isdir(dir_path):
            messagebox.showinfo(title='提示', message='路径不正确')
            return False
        return True


# ----------------------- Archive -----------------------
class ArchiveHandle:
    def __init__(self, master):
        self._master = master
        self._frame = Frame(master)
        self._frame.grid()
        # 工程输入框
        self._str_proj = StringVar()
        self._str_proj.set('输入或者选择后缀名为 .xcworkspace 或 .xcodeproj 的文件路径')
        # Debug/Release 单选结果
        self._str_mode = StringVar()
        self._str_mode.set('Release')
        # scheme 输入框
        self._str_sche = StringVar()
        # ExportOptions.plist 所在路径
        self._str_expo = StringVar()
        self._str_expo.set('ExportOptions.plist')
        # ipa 文件输出路径
        self._str_ipap = StringVar()
        self._str_ipap.set('~/Desktop/auto-ipa')
        # 创建界面
        self.create_ui()
        # 判断 python 文件所在目录有无 shell 脚本
        if not os.path.isfile("auto-archive.sh"):
            messagebox.showinfo(title='提示', message='请将 auto-archive.sh 文件拖到 python 脚本所在目录')
            return

        # 获取默认值
        self.auto_defalut()

    # 自动获取默认值
    def auto_defalut(self):
        config_str = ". ./auto-archive.sh python && echo $g_project_name && echo $g_development_mode " \
                     "&& echo $g_scheme_name && echo $g_export_options && echo $g_ipa_path"
        config_proc = subprocess.Popen(config_str, shell=True, stdout=subprocess.PIPE)
        config_out = config_proc.stdout.readlines()
        if len(config_out) < 5:
            return
        cg_project_name = config_out[-5].decode('utf-8').strip()
        cg_development_mode = config_out[-4].decode('utf-8').strip()
        cg_scheme_name = config_out[-3].decode('utf-8').strip()
        cg_export_options = config_out[-2].decode('utf-8').strip()
        cg_ipa_path = config_out[-1].decode('utf-8').strip()

        # 读取路径
        if len(cg_project_name) > 0:
            self._str_proj.set(cg_project_name)
        else:
            self.auto_read_proj()

        # 编译模式
        if cg_development_mode == "Debug":
            self._str_mode.set('Debug')

        # 读取 scheme
        if len(cg_scheme_name) > 0:
            self._str_sche.set(cg_scheme_name)

        # 读取 ExportOptions.plist
        if len(cg_export_options) > 0:
            self._str_expo.set(cg_export_options)

        # ipa 导出目录
        if len(cg_ipa_path) > 0:
            self._str_ipap.set(cg_ipa_path)

    # 在当前脚本目录下搜索
    def auto_read_proj(self):
        py_dir = os.getcwd()
        file_list = os.listdir(py_dir)
        for file_name in file_list:
            if file_name.endswith('.xcodeproj'):
                temp_full_path = os.path.join(py_dir, file_name)
                self._str_proj.set(temp_full_path)
            if file_name.endswith('.xcworkspace'):
                temp_full_path = os.path.join(py_dir, file_name)
                self._str_proj.set(temp_full_path)
                break
        temp_proj_str = self._str_proj.get()
        if len(temp_proj_str) > 0:
            self.auto_read_scheme()

    # 自动读取 scheme
    def auto_read_scheme(self):
        temp_proj_str = self._str_proj.get()
        temp_proj_dir = os.path.dirname(temp_proj_str)
        temp_proj_full_name = os.path.basename(temp_proj_str)
        proj_name, proj_ext = os.path.splitext(temp_proj_full_name)

        scheme_str = ". ./auto-archive.sh python " + "&& cd " + temp_proj_dir \
                     + " && FindScheme " + proj_name + " && echo $g_scheme_name"
        scheme_proc = subprocess.Popen(scheme_str, shell=True, stdout=subprocess.PIPE)
        scheme_out = scheme_proc.stdout.readlines()
        scheme_name = scheme_out[-1].decode('utf-8').strip()
        if len(scheme_name) > 0:
            self._str_sche.set(scheme_name)

    # 创建界面
    def create_ui(self):
        arch_frame = self._frame
        field_width = 40
        pad_width = 35
        # 提示
        tip_label1 = Label(arch_frame, text="提示1：将 dev-shell.py，auto-archive.sh 复制到与.xcodeproj同级目录下，\n"
                                            "            脚本会自动获取工程名称，scheme等信息。", fg='DarkCyan', justify='left')
        tip_label2 = Label(arch_frame, text="提示2：自动获取不正确请修改或配置 auto-archive.sh 中全局变量。", fg='DarkCyan')
        tip_label3 = Label(arch_frame, text="提示3：配置文件 ExportOptions.plist 不配置会自动检测创建。", fg='DarkCyan')
        tip_label1.grid(row=0, column=0, padx=5, pady=5, rowspan=1, columnspan=3, sticky=W)
        tip_label2.grid(row=1, column=0, padx=5, pady=5, rowspan=1, columnspan=3, sticky=W)
        tip_label3.grid(row=2, column=0, padx=5, pady=5, rowspan=1, columnspan=3, sticky=W)

        # 选择项目路径
        proj_path_label = Label(arch_frame, text='项目路径：', fg='black')
        proj_path_input = Entry(arch_frame, textvariable=self._str_proj, width=field_width)
        proj_path_btn = Button(arch_frame, text='选择文件', command=self.proj_path_btn_click)
        proj_path_label.grid(row=10, column=0, padx=5, pady=5)
        proj_path_input.grid(row=10, column=1, padx=5, pady=5)
        proj_path_btn.grid(row=10, column=2, padx=5, pady=5)
        
        # 选择 Debug/Release
        mode_label = Label(arch_frame, text='编译模式：', fg='black')
        mode_frame = Frame(arch_frame)
        model_release_radio = Radiobutton(mode_frame, variable=self._str_mode, text="Release",
                                          value="Release", command=self.mode_radio_click)
        model_debug_radio = Radiobutton(mode_frame, variable=self._str_mode, text="Debug",
                                        value="Debug", command=self.mode_radio_click)
        mode_label.grid(row=11, column=0, padx=5, pady=5)
        mode_frame.grid(row=11, column=1, padx=5, pady=5, sticky=W)
        model_release_radio.pack(anchor=W, side=LEFT)
        model_debug_radio.pack(anchor=W, side=LEFT)

        # scheme
        sche_label = Label(arch_frame, text='Scheme：', fg='black')
        sche_input = Entry(arch_frame, textvariable=self._str_sche, width=field_width)
        sche_label.grid(row=12, column=0, padx=5, pady=5)
        sche_input.grid(row=12, column=1, padx=5, pady=5)

        # ExportOptions.plist 所在路径
        expo_path_label = Label(arch_frame, text='配置文件：', fg='black')
        expo_path_input = Entry(arch_frame, textvariable=self._str_expo, width=field_width)
        expo_path_btn = Button(arch_frame, text='选择文件', command=self.expo_path_btn_click)
        expo_path_label.grid(row=13, column=0, padx=5, pady=5)
        expo_path_input.grid(row=13, column=1, padx=5, pady=5)
        expo_path_btn.grid(row=13, column=2, padx=5, pady=5)

        # ipa 导出路径
        ipa_path_label = Label(arch_frame, text='ipa路径：', fg='black')
        ipa_path_input = Entry(arch_frame, textvariable=self._str_ipap, width=field_width)
        ipa_path_btn = Button(arch_frame, text='选择路径', command=self.ipa_path_btn_click)
        ipa_path_label.grid(row=14, column=0, padx=5, pady=5)
        ipa_path_input.grid(row=14, column=1, padx=5, pady=5)
        ipa_path_btn.grid(row=14, column=2, padx=5, pady=5)

        # 提交按钮
        sure_btn = Button(arch_frame, text='确定', command=self.sure_btn_click)
        sure_btn.grid(row=15, column=0, padx=pad_width, pady=pad_width, rowspan=2, columnspan=3, sticky=NSEW)

    # 选择项目文件路径
    def proj_path_btn_click(self):
        proj_file_path = filedialog.askopenfilename()
        self._str_proj.set(proj_file_path)
        if len(proj_file_path) > 0:
            self.auto_read_scheme()

    # 选择导出模式 Release
    def mode_radio_click(self):
        mode_str = self._str_mode.get()
        print(mode_str)

    # ExportOptions.plist 所在路径
    def expo_path_btn_click(self):
        expo_file_path = filedialog.askopenfilename()
        self._str_expo.set(expo_file_path)

    # ipa 导出路径
    def ipa_path_btn_click(self):
        ipa_folder_path = filedialog.askdirectory()
        self._str_ipap.set(ipa_folder_path)

    # 确认按钮
    def sure_btn_click(self):
        if not os.path.isfile("auto-archive.sh"):
            messagebox.showinfo(title='提示', message='请将 auto-archive.sh 文件拖到 python 脚本所在目录')
            return

        # 读取输入框
        proj_str = self._str_proj.get()
        mode_str = self._str_mode.get()
        sche_str = self._str_sche.get()
        expo_str = self._str_expo.get()
        ipaf_str = self._str_ipap.get()

        # 判断工程路径是否存在
        if not os.path.isdir(proj_str):
            messagebox.showinfo(title='提示', message='工程文件不存在，请从新选择')
            return

        # 获取文件名称
        proj_full_name = os.path.basename(proj_str)
        proj_path = os.path.dirname(proj_str)
        proj_name, proj_ext = os.path.splitext(proj_full_name)

        # 判断 ExportOptions.plist 输入框是否为空
        if expo_str.strip() == "":
            expo_str = "ExportOptions.plist"
        # 判断项目目录下 ExportOptions.plist 是否存在，不存在创建
        expo_path = os.path.join(proj_path, expo_str)
        if not os.path.isfile(expo_path):
            os.system(". ./auto-archive.sh python && cd " + proj_path + " && CreateExportOptionsPlist " + expo_str)

        # BuildWorkspace  BuildProj
        if proj_ext == ".xcworkspace":
            arch_str = ". ./auto-archive.sh python && cd " + proj_path + " && BuildWorkspace " + proj_name + " " + mode_str \
                       + " " + sche_str + " " + expo_path + " " + ipaf_str + " && echo $g_current_time"
        else:
            arch_str = ". ./auto-archive.sh python && cd " + proj_path + " && BuildProj " + proj_name + " " + mode_str \
                       + " " + sche_str + " " + expo_path + " " + ipaf_str + " && echo $g_current_time"

        arch_proc = subprocess.Popen(arch_str, shell=True, stdout=subprocess.PIPE)
        arch_out = arch_proc.stdout.readlines()
        arch_time = arch_out[-1].decode('utf-8').strip()
        # ipa_folder="$proj_ipa_path/$proj_scheme$g_current_time"
        if len(arch_time) > 0:
            path_abs_str = "cd " + ipaf_str + " && pwd"
            path_abs_proc = subprocess.Popen(path_abs_str, shell=True, stdout=subprocess.PIPE)
            path_abs_out = path_abs_proc.stdout.readlines()
            path_abs = path_abs_out[-1].decode('utf-8').strip()
            arch_ipa_path = sche_str + arch_time + "/" + sche_str + ".ipa"
            # ipa 的绝对路径
            arch_ipa_full_path = os.path.join(path_abs, arch_ipa_path)
            if os.path.isfile(arch_ipa_full_path):
                arch_ipa_dir = os.path.dirname(arch_ipa_full_path)
                messagebox.showinfo(title='提示', message='打包成功，ipa 文件路径：\n' + arch_ipa_dir)
            else:
                messagebox.showinfo(title='提示', message='打包失败，请检查项目')


# ----------------------- App 转 ipa -----------------------
class AppToIpaHandle:
    def __init__(self, master):
        self._master = master
        self._frame = Frame(master)
        self._frame.grid()
        self._str_var = StringVar()
        self.create_ui()
        self.auto_find_app()

    # 在当前脚本目录下搜索
    def auto_find_app(self):
        py_dir = os.getcwd()
        file_list = os.listdir(py_dir)
        for file_name in file_list:
            if file_name.endswith('.app'):
                temp_full_path = os.path.join(py_dir, file_name)
                self._str_var.set(temp_full_path)
                break

    # 创建界面
    def create_ui(self):
        app_frame = self._frame
        field_width = 40
        pad_width = 35
        # 提示
        tip_label = Label(app_frame, text="请选择后缀名为 .app 的文件", fg='DarkCyan')
        path_label = Label(app_frame, text='项目路径：', fg='black')

        # 选择项目路径按钮
        self._str_var.set('输入或者选择 .app 文件路径')
        path_input = Entry(app_frame, textvariable=self._str_var, width=field_width)
        select_path_btn = Button(app_frame, text='选择文件', command=self.select_path_btn_click)
        # 提交按钮
        sure_btn = Button(app_frame, text='确定', command=self.sure_btn_click)
        # 布局
        tip_label.grid(row=0, column=0, padx=5, pady=5, rowspan=1, columnspan=3, sticky=W)
        path_label.grid(row=1, column=0, padx=5, pady=5)
        path_input.grid(row=1, column=1, padx=5, pady=5)
        select_path_btn.grid(row=1, column=2, padx=5, pady=5)
        sure_btn.grid(row=3, column=0, padx=pad_width, pady=pad_width, rowspan=2, columnspan=3, sticky=NSEW)

    # 选择 .app 文件
    def select_path_btn_click(self):
        file_path = filedialog.askopenfilename()
        if len(file_path) > 0:
            self._str_var.set(file_path)

    def sure_btn_click(self):
        dst_path = self._str_var.get()
        # 判断是否是.app 文件
        if not dst_path.endswith('.app'):
            messagebox.showinfo(title='提示', message='请选择 .app 文件')
            return

        if not os.path.isfile("convert-ipa.sh"):
            messagebox.showinfo(title='提示', message='请将 convert-ipa.sh 文件拖到 python 脚本所在目录')
            return
        # 如果选择的是文件，则将文件名称和目录分开
        file_name = os.path.basename(dst_path)
        dir_path = os.path.dirname(dst_path)
        os.system('. ./convert-ipa.sh python ' + '&& cd ' + dir_path + ' && AppToIpa ' + file_name)
        messagebox.showinfo(title='提示', message='图片已经保存' + dir_path + '/IPAFolder 文件夹中')


# ----------------------- App -----------------------
class App:
    def __init__(self, master):
        self._master = master

        # 创建标题Verdana 10 bold
        img_label = Label(master, text='图片批处理', font='宋体 23', fg='black', bg='White', justify='right')
        arch_label = Label(master, text='自动化打包', font='宋体 23', fg='black', bg='White', justify='right')
        ipa_label = Label(master, text='.app 转 .ipa', font='宋体 23', fg='black', bg='White', justify='right')

        # 创建按钮
        img_app_icon_btn = Button(master, text="生成 AppIcon", command=self.create_icon_view, justify='left')
        img_launch_image_btn = Button(master, text="生成 LaunchImage", command=self.create_launch_view, justify='left')
        img_2x3x_btn = Button(master, text="生成 2x 3x图片", command=self.create_2x3x_view, justify='left')
        img_png_btn = Button(master, text="图片转 PNG", command=self.create_png_view, justify='left')
        arch_btn = Button(master, text="自动化打包", command=self.create_archive_view, justify='left')
        ipa_btn = Button(master, text="app 转 ipa", command=self.create_app_ipa_view, justify='left')

        # 创建提示
        tip_app_icon_label = Label(master, text='一键缩放图片生成 App 所有尺寸 icon 图标。',
                                   fg='DarkCyan', bg='LightGray', justify='left')
        tip_launch_image_label = Label(master, text='一键缩放图片生成 App 所需启动图。',
                                       fg='DarkCyan', bg='LightGray', justify='left')
        tip_2x3x_label = Label(master, text='一键将文件夹内图片生成 2x/3x 图片并自动重命名。',
                               fg='DarkCyan', bg='LightGray', justify='left')
        tip_png_label = Label(master, text='一键将文件夹内所有图片转为 PNG 格式。',
                              fg='DarkCyan', bg='LightGray', justify='left')
        tip_arch_label = Label(master, text='利用 xcode build 指令将项目打包为 ipa。',
                               fg='DarkCyan', bg='LightGray', justify='left')
        tip_ipa_label = Label(master, text='将 command + b 编译的 .app 文件转成 ipa。',
                              fg='DarkCyan', bg='LightGray', justify='left')

        # 布局标题
        img_label.grid(row=0, column=0, rowspan=4, columnspan=1, padx=5, pady=5, sticky=NSEW)
        arch_label.grid(row=4, column=0, padx=5, pady=5, sticky=NSEW)
        ipa_label.grid(row=5, column=0, padx=5, pady=5, sticky=NSEW)

        # 布局按钮
        img_app_icon_btn.grid(row=0, column=1, padx=5, pady=5, sticky=NSEW)
        img_launch_image_btn.grid(row=1, column=1, padx=5, pady=5, sticky=NSEW)
        img_2x3x_btn.grid(row=2, column=1, padx=5, pady=5, sticky=NSEW)
        img_png_btn.grid(row=3, column=1, padx=5, pady=5, sticky=NSEW)
        arch_btn.grid(row=4, column=1, padx=5, pady=5, sticky=NSEW)
        ipa_btn.grid(row=5, column=1, padx=5, pady=5, sticky=NSEW)

        # 布局提示
        tip_app_icon_label.grid(row=0, column=2, padx=5, pady=5, sticky=W)
        tip_launch_image_label.grid(row=1, column=2, padx=5, pady=5, sticky=W)
        tip_2x3x_label.grid(row=2, column=2, padx=5, pady=5, sticky=W)
        tip_png_label.grid(row=3, column=2, padx=5, pady=5, sticky=W)
        tip_arch_label.grid(row=4, column=2, padx=5, pady=5, sticky=W)
        tip_ipa_label.grid(row=5, column=2, padx=5, pady=5, sticky=W)
        master.mainloop()

    # 创建 AppIcon 的图标
    def create_icon_view(self):
        xx = self._master.winfo_x()
        yy = self._master.winfo_y()
        hh = self._master.winfo_height()
        ww = self._master.winfo_width()

        img_win = Toplevel(self._master)
        img_win.title('图片处理')
        img_win.geometry('%dx%d+%d+%d' % (ww, hh, xx, yy))
        ImgHandle(img_win).create_app_icon()

    def create_launch_view(self):
        xx = self._master.winfo_x()
        yy = self._master.winfo_y()
        hh = self._master.winfo_height()
        ww = self._master.winfo_width()

        img_win = Toplevel(self._master)
        img_win.title('图片处理')
        img_win.geometry('%dx%d+%d+%d' % (ww, hh, xx, yy))
        ImgHandle(img_win).create_launch_image()

    def create_2x3x_view(self):
        xx = self._master.winfo_x()
        yy = self._master.winfo_y()
        hh = self._master.winfo_height()
        ww = self._master.winfo_width()

        img_win = Toplevel(self._master)
        img_win.title('图片处理')
        img_win.geometry('%dx%d+%d+%d' % (ww, hh, xx, yy))
        ImgHandle(img_win).convert_2x3x()

    def create_png_view(self):
        xx = self._master.winfo_x()
        yy = self._master.winfo_y()
        hh = self._master.winfo_height()
        ww = self._master.winfo_width()

        img_win = Toplevel(self._master)
        img_win.title('图片处理')
        img_win.geometry('%dx%d+%d+%d' % (ww, hh, xx, yy))
        ImgHandle(img_win).convert_png()

    def create_archive_view(self):
        xx = self._master.winfo_x()
        yy = self._master.winfo_y()
        hh = self._master.winfo_height()
        ww = self._master.winfo_width()

        arch_win = Toplevel(self._master)
        arch_win.title('自动化打包')
        arch_win.geometry('%dx%d+%d+%d' % (ww, hh, xx, yy))
        ArchiveHandle(arch_win)

    def create_app_ipa_view(self):
        xx = self._master.winfo_x()
        yy = self._master.winfo_y()
        hh = self._master.winfo_height()
        ww = self._master.winfo_width()

        ipa_win = Toplevel(self._master)
        ipa_win.title('app 转 ipa')
        ipa_win.geometry('%dx%d+%d+%d' % (ww, hh, xx, yy))
        AppToIpaHandle(ipa_win)


# ----------------------- Main -----------------------
if __name__ == '__main__':
    py_full_path = os.path.abspath(__file__)
    py_dir = os.path.dirname(py_full_path)
    os.chdir(py_dir)

    root_win = Tk()
    root_win.title('Shell 功能列表')
    root_sw = root_win.winfo_screenwidth()
    root_sh = root_win.winfo_screenheight()
    root_win.geometry('%dx%d+%d+%d' % (root_sw * 0.5, root_sh * 0.5, root_sw * 0.25, root_sh * 0.15))
    App(root_win)

