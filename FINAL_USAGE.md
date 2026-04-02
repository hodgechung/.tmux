# tmux + CPU 监控 + 插件 - 完整使用指南

## ✅ 配置完成

### 状态
- ✅ **gpakosz/.tmux** 主配置未修改
- ✅ **CPU 监控** 已显示在状态栏
- ✅ **7 个插件** 已安装并加载
- ✅ **持久化存储** `/data/workspace/.tmux-plugins`

### 插件列表
1. **tmux-cpu** - CPU 使用率显示 ✅
2. **tmux-fzf** - 模糊搜索 (`Ctrl+B, F`)
3. **tmux-which-key** - 快捷键提示
4. **tmux-sessionx** - 会话管理 (`Ctrl+B, Shift+O`)
5. **tmux-copycat** - 内容搜索 (`Ctrl+B, /`)
6. **tmux-thumbs** - 快速复制 (`Ctrl+B, Space`)
7. **tmux-resurrect** - 会话保存/恢复 (`Ctrl+B, Ctrl+S/R`)
8. **tmux-continuum** - 自动保存（每15分钟）

---

## 📱 使用流程

### 完整初始化（每次连接后）

```bash
# 1. 连接服务器
ssh anydev_ts3

# 2. 启动或连接 tmux
tmux new -s work
# 或: tmux attach -t plugin-working

# 3. 应用完整配置（一键完成所有设置）
~/.tmux/apply_custom_statusbar.sh
```

**脚本会自动完成：**
- ✅ 检查并修复插件符号链接
- ✅ 加载所有 7 个插件
- ✅ 应用自定义状态栏（显示 CPU）

---

## 🎹 插件快捷键

### tmux-fzf（模糊搜索）
- `Ctrl+B, F` - 打开 fzf 菜单
  - 搜索会话、窗口、窗格
  - 搜索命令、快捷键

### tmux-sessionx（会话管理）
- `Ctrl+B, Shift+O` - 打开会话选择器
  - 切换会话
  - 创建新会话
  - 管理多个会话

### tmux-thumbs（快速复制）
- `Ctrl+B, Space` - 激活 thumbs 模式
  - 屏幕上的文本会显示字母标记
  - 按对应字母快速复制

### tmux-copycat（内容搜索）
- `Ctrl+B, /` - 搜索当前窗格内容
- `Ctrl+B, Ctrl+F` - 搜索文件路径
- `Ctrl+B, Ctrl+D` - 搜索数字
- `Ctrl+B, Ctrl+G` - 搜索 git 状态

### tmux-resurrect（会话保存/恢复）
- `Ctrl+B, Ctrl+S` - 保存当前会话
- `Ctrl+B, Ctrl+R` - 恢复已保存的会话

### tmux-continuum（自动保存）
- 自动工作，无需手动操作
- 每 15 分钟自动保存会话

---

## 🔧 自动化（推荐）

在 `~/.bashrc` 或 `~/.zshrc` 添加：

```bash
# 进入 tmux 时自动应用配置
if [ -n "$TMUX" ]; then
  ~/.tmux/apply_custom_statusbar.sh >/dev/null 2>&1
fi
```

重新加载：
```bash
source ~/.bashrc  # 或 source ~/.zshrc
```

以后每次进入 tmux 会话，插件和 CPU 显示会自动生效。

---

## 🐛 故障排查

### 插件不工作
```bash
# 手动加载所有插件
~/.tmux/load_plugins.sh
```

### 符号链接丢失
```bash
# 重建符号链接
~/.tmux/ensure_plugins.sh
```

### CPU 不显示
```bash
# 测试脚本
bash /data/workspace/.tmux-plugins/tmux-cpu/scripts/cpu_percentage.sh

# 重新应用状态栏
~/.tmux/apply_custom_statusbar.sh
```

### 检查快捷键绑定
```bash
# 查看所有插件快捷键
tmux list-keys | grep -E "fzf|sessionx|thumbs|copycat|resurrect"
```

---

## 📋 技术细节

### 为什么需要手动加载插件？

gpakosz/.tmux 的配置加载顺序导致 TPM 无法自动加载插件：

1. `.tmux.conf` 主配置加载
2. `.tmux.conf.local` 用户配置加载（包含 `run tpm`）
3. gpakosz 主题脚本**重新运行**，覆盖部分设置
4. TPM 的自动加载在第 2 步，但被第 3 步的逻辑干扰

**解决方案：** 手动运行每个插件的 `.tmux` 文件（通过 `load_plugins.sh`）

### 为什么插件目录会消失？

**根本原因：** Git 跟踪了 `plugins` 符号链接

- 我们误用 `git add plugins` 提交了符号链接
- Git 操作时会删除或替换符号链接
- 导致插件目录消失

**解决方案：**
- `.gitignore` 忽略 `plugins/`
- `ensure_plugins.sh` 自动重建符号链接
- 插件存储在 `/data/workspace/.tmux-plugins`（持久化）

---

## 🔗 相关文件

- `apply_custom_statusbar.sh` - **一键配置脚本** ⭐
- `load_plugins.sh` - 手动加载所有插件
- `ensure_plugins.sh` - 确保符号链接正确
- `README.custom.md` - 安装说明
- `PLUGINS.md` - 插件详细文档

## 🔗 GitHub

https://github.com/hodgechung/.tmux

---

**享受强大的 tmux！** 🚀

---

## ⚠️ 已知问题

### tmux-which-key 插件错误

**错误信息：** `[tmux-which-key] Rebuilding menu ... [0/0]`

**原因：** 该插件与 gpakosz/.tmux 配置有冲突

**影响：** 不影响其他插件使用

**替代方案：**
- 查看快捷键列表：`tmux list-keys`
- 参考 gpakosz/.tmux 文档：`~/.tmux/README.md`
- 使用其他 6 个插件正常工作

**工作的插件：**
- ✅ tmux-fzf (Ctrl+B, F)
- ✅ tmux-sessionx (Ctrl+B, Shift+O)
- ✅ tmux-thumbs (Ctrl+B, Space)
- ✅ tmux-copycat (Ctrl+B, /)
- ✅ tmux-resurrect (Ctrl+B, Ctrl+S/R)
- ✅ tmux-continuum (自动)
