# 🚀 新用户快速开始指南

## 1️⃣ 克隆仓库

```bash
git clone git@github.com:hodgechung/.tmux.git ~/.tmux
cd ~/.tmux
```

## 2️⃣ 创建符号链接

```bash
ln -s -f .tmux.conf ~/.tmux.conf
```

## 3️⃣ 创建持久化插件目录

```bash
# 如果是 AnyDev 环境
mkdir -p /data/workspace/.tmux-plugins

# 如果是本地环境
mkdir -p ~/.tmux-plugins
```

## 4️⃣ 安装 TPM（插件管理器）

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# 或使用持久化路径
git clone https://github.com/tmux-plugins/tpm /data/workspace/.tmux-plugins/tpm
```

## 5️⃣ 安装所有插件

### 方法 1：使用 TPM 自动安装

```bash
# 启动 tmux
tmux new -s setup

# 在 tmux 中按：Ctrl+B, I（大写 I）
# 等待插件安装完成
```

### 方法 2：手动安装（推荐）

```bash
cd /data/workspace/.tmux-plugins  # 或 ~/.tmux-plugins

# 安装所有插件
git clone https://github.com/tmux-plugins/tmux-cpu
git clone https://github.com/sainnhe/tmux-fzf
git clone https://github.com/alexwforsythe/tmux-which-key
git clone https://github.com/omerxx/tmux-sessionx
git clone https://github.com/tmux-plugins/tmux-copycat
git clone https://github.com/fcsonline/tmux-thumbs
git clone https://github.com/tmux-plugins/tmux-resurrect
git clone https://github.com/tmux-plugins/tmux-continuum

# 修复 which-key 导入问题
cd tmux-which-key/plugin
sed -i 's/from pyyaml.lib import yaml/import yaml/' build.py
```

## 6️⃣ 应用配置

```bash
# 创建符号链接（如果还没创建）
~/.tmux/ensure_plugins.sh

# 加载所有插件
~/.tmux/load_plugins.sh

# 应用完整配置（CPU + 插件）
~/.tmux/apply_custom_statusbar.sh
```

## 7️⃣ 验证

```bash
# 检查状态栏是否显示 CPU
tmux display-message -p "#{status-right}"

# 应该看到：
# ⌨#{?client_prefix,ON,} | CPU: #(...) | %H:%M | %d-%b | #(whoami)@#H
```

## 8️⃣ 测试插件

在 tmux 会话中：

- `Ctrl+B, '` - which-key 菜单
- `Ctrl+B, F` - 模糊搜索
- `Ctrl+B, Shift+O` - 会话管理
- `Ctrl+B, Space` - 快速复制
- `Ctrl+B, /` - 内容搜索

---

## 🔧 故障排查

### 插件不工作

```bash
~/.tmux/load_plugins.sh
```

### CPU 不显示

```bash
~/.tmux/apply_custom_statusbar.sh
```

### 符号链接丢失

```bash
~/.tmux/ensure_plugins.sh
```

### which-key 报错

```bash
# 安装 dash（如果需要）
yum install -y dash

# 或修改脚本使用 bash
cd /data/workspace/.tmux-plugins/tmux-which-key
sed -i 's|#!/usr/bin/env dash|#!/usr/bin/env bash|' which-key.sh
```

---

## 📚 完整文档

- **FINAL_KEYS.md** - 完整键绑定 ⭐
- **FINAL_USAGE.md** - 使用指南
- **SHORTCUTS.md** - 快捷键卡片
- **WHICHKEY_USAGE.md** - which-key 说明
- **PLUGINS.md** - 插件详细文档

---

**安装完成后，享受强大的 tmux！** 🎉
