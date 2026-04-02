# 🚀 新用户快速开始（3 步完成）

## ⚡ 快速安装（推荐）

```bash
# 1. 克隆仓库
git clone git@github.com:hodgechung/.tmux.git ~/.tmux
ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf

# 2. 一键安装自动配置 ⭐
~/.tmux/install_autorun.sh

# 3. 启动 tmux
tmux new -s work

# ✅ 完成！按 Ctrl+B, ' 查看菜单
```

**就这么简单！** 以后每次进入 tmux 会自动配置好。

---

## 📋 详细步骤

### 1️⃣ 克隆仓库

```bash
git clone git@github.com:hodgechung/.tmux.git ~/.tmux
cd ~/.tmux
```

### 2️⃣ 创建符号链接

```bash
ln -s -f .tmux.conf ~/.tmux.conf
```

### 3️⃣ 安装自动配置（推荐）⭐

```bash
./install_autorun.sh
```

这会在 `.zshrc` 或 `.bashrc` 中添加自动配置，以后每次进入 tmux 自动应用。

**或者** 跳过自动配置，每次手动运行：
```bash
./apply_custom_statusbar.sh
```

### 4️⃣ 安装插件（首次需要）

#### 方法 A：自动安装（推荐）

```bash
# 启动 tmux
tmux new -s setup

# 按快捷键安装插件
# Ctrl+B, I（大写 I）
# 等待几秒，插件会自动下载
```

#### 方法 B：手动安装

```bash
# 创建持久化目录
mkdir -p /data/workspace/.tmux-plugins  # AnyDev 环境
# 或 mkdir -p ~/.tmux-plugins            # 本地环境

cd /data/workspace/.tmux-plugins

# 克隆所有插件
git clone https://github.com/tmux-plugins/tpm
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

### 5️⃣ 启动并享受

```bash
tmux new -s work
# 如果已安装自动配置，会自动加载
# 否则手动运行：~/.tmux/apply_custom_statusbar.sh
```

---

## 🎹 测试功能

### CPU 监控
查看状态栏右侧，应该显示：
```
⌨ | CPU: 35.2% | 16:31 | 02-Apr | user@hostname
```

### 插件快捷键

- `Ctrl+B, '` - which-key 菜单 ⭐
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

### 自动配置不生效
```bash
# 检查是否已添加
grep "apply_custom_statusbar.sh" ~/.zshrc

# 重新加载配置
source ~/.zshrc

# 或重新安装
~/.tmux/install_autorun.sh
```

---

## 🔄 卸载自动配置

如果不想自动配置：

```bash
# 编辑 .zshrc
vim ~/.zshrc

# 删除或注释这几行：
# if [ -n "$TMUX" ]; then
#   ~/.tmux/apply_custom_statusbar.sh >/dev/null 2>&1
# fi
```

---

## 📚 下一步

- **FINAL_KEYS.md** - 完整键绑定
- **AUTO_CONFIG.md** - 自动配置详解
- **FINAL_USAGE.md** - 使用指南

---

**开始享受强大的 tmux！** 🎉
