# tmux 快捷键参考卡

## 🎹 插件快捷键（6 个可用）

### tmux-fzf - 模糊搜索
```
Ctrl+B, F
```
- 搜索会话、窗口、窗格
- 搜索命令历史
- 搜索快捷键

### tmux-sessionx - 会话管理
```
Ctrl+B, Shift+O
```
- 切换会话
- 创建新会话
- 删除会话
- 会话预览

### tmux-thumbs - 快速复制
```
Ctrl+B, Space
```
- 显示字母标记
- 按字母复制对应文本
- 适合复制路径、命令、URL

### tmux-copycat - 内容搜索
```
Ctrl+B, /          搜索任意内容
Ctrl+B, Ctrl+F     搜索文件路径
Ctrl+B, Ctrl+D     搜索数字
Ctrl+B, Ctrl+U     搜索 URL
Ctrl+B, Alt+H      搜索 Git SHA
Ctrl+B, Alt+I      搜索 IP 地址
```

### tmux-resurrect - 会话持久化
```
Ctrl+B, Ctrl+S     保存会话
Ctrl+B, Ctrl+R     恢复会话
```
保存内容：
- 窗口布局
- 窗格分割
- 运行的程序
- 工作目录

### tmux-continuum - 自动保存
- 自动工作，无需手动操作
- 每 15 分钟自动保存
- 与 tmux-resurrect 配合使用

---

## 📊 状态栏

```
⌨ | CPU: 25.3% | 16:05 | 02-Apr | root@hostname
```

显示内容：
- ⌨ Prefix 键状态（按下 Ctrl+B 后显示 ON）
- CPU 使用率（实时）
- 当前时间
- 日期
- 用户@主机名

---

## 🎨 gpakosz/.tmux 原生快捷键

### 窗口管理
```
Ctrl+B, c          创建新窗口
Ctrl+B, &          关闭当前窗口
Ctrl+B, n          下一个窗口
Ctrl+B, p          上一个窗口
Ctrl+B, 数字       切换到第 N 个窗口
```

### 窗格分割
```
Ctrl+B, -          水平分割
Ctrl+B, _          垂直分割
Ctrl+B, x          关闭当前窗格
Ctrl+B, 方向键     在窗格间移动
Ctrl+B, Ctrl+方向  调整窗格大小
```

### 复制模式
```
Ctrl+B, [          进入复制模式
Ctrl+B, ]          粘贴缓冲区
```

### 其他
```
Ctrl+B, e          编辑配置文件
Ctrl+B, r          重新加载配置
Ctrl+B, m          切换鼠标模式
Ctrl+B, +          最大化/恢复窗格
```

---

## ⚠️ 不可用的插件

### tmux-which-key
**错误：** 缺少 Python pyyaml 模块

**替代方案：**
- 使用本文档查看快捷键
- 运行 `tmux list-keys` 查看所有绑定
- 参考 `~/.tmux/README.md`

---

## 🔧 快速参考命令

```bash
# 应用完整配置（插件 + CPU）
~/.tmux/apply_custom_statusbar.sh

# 只加载插件
~/.tmux/load_plugins.sh

# 确保符号链接正确
~/.tmux/ensure_plugins.sh

# 查看所有快捷键
tmux list-keys

# 查看状态栏配置
tmux show-options -g status-right
```

---

**打印此文档或添加到书签！** 📌
