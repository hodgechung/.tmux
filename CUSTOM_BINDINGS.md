# 自定义键绑定

## 💡 为什么需要覆盖

### 默认行为
tmux 默认在 **HOME 目录** 创建新窗口和窗格。

### 改进后
在 **当前目录** 创建，更符合工作流。

---

## 🎯 已添加的覆盖

### 新窗口继承路径
```bash
bind c new-window -c '#{pane_current_path}'
```

**效果：**
- 在 `/project/code` 按 `Ctrl+B, c` 
- 新窗口在 `/project/code` 而不是 `~`

### 分割窗格继承路径

**原生分割：**
```bash
bind '"' split-window -c '#{pane_current_path}'     # 水平
bind % split-window -h -c '#{pane_current_path}'    # 垂直
```

**gpakosz 风格：**
```bash
bind - split-window -v -c '#{pane_current_path}'    # 水平
bind _ split-window -h -c '#{pane_current_path}'    # 垂直
```

---

## 📋 使用效果

### 场景 1：项目开发
```bash
cd ~/projects/my-app
tmux new -s dev

# 在 ~/projects/my-app
Ctrl+B, c           # 新窗口在 ~/projects/my-app ✓
Ctrl+B, -           # 分割窗格在 ~/projects/my-app ✓
```

### 场景 2：多目录工作
```bash
# 窗口 1 在 ~/frontend
cd ~/frontend
Ctrl+B, c           # 窗口 2 在 ~/frontend

# 切换到其他目录
cd ~/backend
Ctrl+B, c           # 窗口 3 在 ~/backend
```

---

## 🔧 自定义更多绑定

编辑 `~/.tmux/.tmux.conf.local`：

```bash
# 你的自定义绑定
bind <键> <命令>

# 示例：
# bind r source-file ~/.tmux.conf \; display "Config reloaded!"
# bind X kill-window -a  # 关闭其他所有窗口
```

---

## 📚 相关变量

- `#{pane_current_path}` - 当前窗格路径
- `#{window_name}` - 窗口名称
- `#{session_name}` - 会话名称

更多变量：`tmux show -g | grep @`

---

**配置文件位置：** `~/.tmux/.tmux.conf.local`
