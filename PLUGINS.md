# tmux 插件使用指南

本配置包含以下插件：

## 🎯 核心插件

### 1. tmux-cpu
**功能**: 在状态栏显示 CPU 使用率

**使用**: 自动显示在状态栏右侧
```
... | CPU: 18.6% | 时间 | 日期 | ...
```

---

### 2. tmux-which-key
**功能**: 按下 prefix 后显示所有可用快捷键

**使用**:
- 按 `Ctrl+B`（prefix），然后等待 1 秒
- 会弹出快捷键提示窗口

**自定义**: 在 `.tmux.conf.local` 中配置
```bash
set -g @tmux-which-key-xdg-enable 1
```

---

### 3. tmux-fzf
**功能**: 模糊搜索 tmux 会话、窗口、面板等

**快捷键**:
- `prefix + F`: 打开 fzf 菜单
- 然后选择:
  - `s`: 搜索会话
  - `w`: 搜索窗口
  - `c`: 搜索命令
  - `k`: 搜索按键绑定

**示例**:
```
Ctrl+B, F, s   # 模糊搜索并切换会话
```

---

### 4. tmux-copycat
**功能**: 正则表达式搜索 tmux 屏幕内容

**快捷键**:
- `prefix + /`: 正则搜索
- `prefix + Ctrl-f`: 搜索文件
- `prefix + Ctrl-g`: 搜索 Git 状态
- `prefix + Alt-h`: 搜索 SHA-1 哈希
- `prefix + Ctrl-u`: 搜索 URL
- `prefix + Ctrl-d`: 搜索数字
- `prefix + Alt-i`: 搜索 IP 地址

**示例**:
```
Ctrl+B, /       # 输入搜索词
n               # 下一个匹配
N               # 上一个匹配
```

---

### 5. tmux-thumbs
**功能**: 快速复制屏幕上的文本（类似 vimium 的 hint 模式）

**快捷键**:
- `prefix + Space`: 激活 thumbs 模式
- 屏幕上会出现字母标签
- 输入对应字母即可复制

**示例**:
```
Ctrl+B, Space   # 激活
输入 "ab"        # 复制标记为 "ab" 的文本
```

**依赖**: 需要 Rust（已安装）

---

### 6. tmux-sessionx
**功能**: 高级会话管理和切换器

**快捷键**:
- `prefix + O`: 打开 sessionx（大写 O）
- 或 `prefix + Ctrl-o`: 备用快捷键

**功能**:
- 预览会话内容
- 快速创建新会话
- 删除会话
- 重命名会话

**示例**:
```
Ctrl+B, Shift+O    # 打开会话选择器
输入名称搜索        # 模糊搜索
Enter              # 切换到该会话
Ctrl+X             # 删除会话
Ctrl+R             # 重命名会话
```

---

### 7. tmux-resurrect
**功能**: 保存和恢复 tmux 会话

**快捷键**:
- `prefix + Ctrl-s`: 保存当前会话
- `prefix + Ctrl-r`: 恢复保存的会话

**保存内容**:
- 所有会话、窗口、面板
- 工作目录
- 正在运行的程序

---

### 8. tmux-continuum
**功能**: 自动保存 tmux 会话

**配置**:
```bash
set -g @continuum-restore 'on'       # 启动时自动恢复
set -g @continuum-save-interval '15' # 每 15 分钟自动保存
```

**状态**: 自动运行，无需手动操作

---

## 🔧 插件管理

### 安装/更新插件
在 tmux 中按：
- `Ctrl+B, Shift+I` - 安装新插件
- `Ctrl+B, Shift+U` - 更新所有插件
- `Ctrl+B, Alt+U` - 卸载未配置的插件

### 手动安装
```bash
~/.tmux/plugins/tpm/bin/install_plugins
```

---

## 📦 依赖检查

### fzf (必需)
```bash
fzf --version
# 安装: git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
```

### Rust (tmux-thumbs 需要)
```bash
cargo --version
# 安装: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

---

## 🎨 推荐工作流

### 1. 会话管理
```bash
Ctrl+B, Shift+O    # 打开 sessionx
输入 "work"         # 搜索或创建 work 会话
```

### 2. 快速复制
```bash
Ctrl+B, Space      # thumbs 模式
ab                 # 复制指定内容
```

### 3. 搜索内容
```bash
Ctrl+B, /          # copycat 正则搜索
# 或
Ctrl+B, Ctrl-u     # 搜索 URL
```

### 4. 查看快捷键
```bash
Ctrl+B             # 等待 1 秒
# which-key 会自动显示
```

---

## 🐛 故障排查

### 插件未生效
```bash
# 在 tmux 中重新加载配置
tmux source ~/.tmux.conf

# 或按 Ctrl+B, : 然后输入
source ~/.tmux.conf
```

### fzf 不工作
```bash
# 确保 fzf 在 PATH 中
source ~/.bashrc  # 或 source ~/.zshrc
which fzf
```

### tmux-thumbs 不工作
```bash
# 重新编译
cd ~/.tmux/plugins/tmux-thumbs
cargo build --release
```

---

**享受 tmux + 插件的强大组合！** 🚀
