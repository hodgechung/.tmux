# 🎉 tmux 配置完成

基于 gpakosz/.tmux，增强了 CPU 监控和 7 个强大插件。

---

## ✨ 核心功能

1. **CPU 实时监控** - 状态栏显示
2. **7 个插件** - 模糊搜索、会话管理、快速复制等
3. **自动配置** - 一键安装，自动加载
4. **静默启动** - 无加载信息干扰
5. **which-key 菜单** - `Ctrl+B, ?` 交互式帮助

---

## 🚀 快速开始

### 新用户（3 步）

```bash
# 1. 克隆仓库
git clone git@github.com:hodgechung/.tmux.git ~/.tmux
ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf

# 2. 一键安装
~/.tmux/install_autorun.sh

# 3. 启动使用
tmux new -s work
```

### 已安装用户

```bash
# 进入 tmux
tmux

# 按 Ctrl+B, ? 查看帮助菜单
```

---

## 🎹 核心快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+B, ?` | **which-key 菜单** ⭐ |
| `Ctrl+B, F` | 模糊搜索 |
| `Ctrl+B, Shift+O` | 会话管理 |
| `Ctrl+B, Space` | 快速复制 |
| `Ctrl+B, /` | 内容搜索 |
| `Ctrl+B, Ctrl+S` | 保存会话 |
| `Ctrl+B, Ctrl+R` | 恢复会话 |

**记住第一个就够了！** 按 `Ctrl+B, ?` 查看全部。

---

## 📊 状态栏

```
⌨ | CPU: 35.2% | 16:57 | 02-Apr | user@hostname
```

- **⌨** - Prefix 状态
- **CPU** - 实时使用率
- **时间 + 日期 + 用户**

---

## 📚 完整文档

### 必读
- **QUICK_START_NEW_USER.md** - 安装指南
- **QUICK_REFERENCE.md** - 快速参考卡
- **KEYBINDING_NOTES.md** - 键绑定说明

### 详细
- **AUTO_CONFIG.md** - 自动配置原理
- **FEATURES.md** - 功能总览
- **FINAL_KEYS.md** - 完整键绑定列表
- **WHICHKEY_USAGE.md** - which-key 详细用法

---

## 🔧 配置文件

- `.tmux.conf` - gpakosz 主配置（未修改）
- `.tmux.conf.local` - 用户配置（插件声明）
- `.tmux.conf.local.whichkey` - which-key 键绑定
- `.tmux.conf.override` - 状态栏覆盖

---

## 🆘 故障排查

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
# 检查
grep "apply_custom_statusbar.sh" ~/.zshrc

# 重新安装
~/.tmux/install_autorun.sh
```

---

## 🎯 技术细节

### 插件列表
1. tmux-cpu - CPU 监控
2. tmux-fzf - 模糊搜索
3. tmux-which-key - 交互式菜单
4. tmux-sessionx - 会话管理
5. tmux-thumbs - 快速复制
6. tmux-copycat - 内容搜索
7. tmux-resurrect + continuum - 会话保存

### 自动化原理
在 `.zshrc`/`.bashrc` 中添加：
```bash
if [ -n "$TMUX" ]; then
  ~/.tmux/apply_custom_statusbar.sh --silent
fi
```

进入 tmux 时自动静默加载所有配置。

---

## 🔗 链接

- **GitHub**: https://github.com/hodgechung/.tmux
- **上游**: https://github.com/gpakosz/.tmux

---

**开始享受强大的 tmux！** 🚀
