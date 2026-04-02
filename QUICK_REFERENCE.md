# 🚀 快速参考卡

## 核心快捷键（记住这 5 个）

```
Ctrl+B, Shift+W   → which-key 菜单 ⭐
Ctrl+B, F         → 模糊搜索
Ctrl+B, Shift+O   → 会话管理  
Ctrl+B, Space     → 快速复制
Ctrl+B, /         → 内容搜索
```

---

## 💡 记忆技巧

| 键 | 含义 | 记忆方法 |
|----|------|----------|
| **Shift+W** | Which-key | **W** = **W**hich 哪个键 |
| **F** | Fuzzy search | **F**uzzy 模糊搜索 |
| **Shift+O** | Overview | **O**verview 会话总览 |
| **Space** | Text thumbs | 空格 = 快速标记 |
| **/** | Search | 搜索符号 |

---

## 📋 完整列表

### 插件快捷键
- `Ctrl+B, Shift+W` - which-key 菜单
- `Ctrl+B, F` - tmux-fzf 搜索
- `Ctrl+B, Shift+O` - 会话管理
- `Ctrl+B, Space` - 快速复制
- `Ctrl+B, /` - 搜索内容
- `Ctrl+B, Ctrl+F` - 搜索文件
- `Ctrl+B, Ctrl+U` - 搜索 URL
- `Ctrl+B, Ctrl+S` - 保存会话
- `Ctrl+B, Ctrl+R` - 恢复会话

### gpakosz 原生
- `Ctrl+B, ?` - 快捷键列表
- `Ctrl+B, e` - 编辑配置
- `Ctrl+B, r` - 重载配置
- `Ctrl+B, m` - 鼠标模式
- `Ctrl+B, -` - 水平分割
- `Ctrl+B, _` - 垂直分割
- `Ctrl+B, +` - 最大化窗格
- `Ctrl+B, w` - 窗口列表（小写）
- `Ctrl+B, '` - 选择窗口

---

## 🎯 使用场景

### 不知道按什么？
→ `Ctrl+B, Shift+W` 打开 which-key 菜单

### 找窗口/会话？
→ `Ctrl+B, F` 模糊搜索

### 管理多个会话？
→ `Ctrl+B, Shift+O` 会话管理器

### 复制屏幕文本？
→ `Ctrl+B, Space` 快速复制

### 搜索历史输出？
→ `Ctrl+B, /` 内容搜索

---

## 📊 状态栏

```
⌨ | CPU: 35.2% | 16:42 | 02-Apr | user@host
```

- **⌨** - Prefix 状态（按下 Ctrl+B 显示 ON）
- **CPU** - 实时使用率
- **时间** - 当前时间
- **日期** - 当前日期
- **用户** - 当前用户@主机名

---

**打印此页或添加到书签！** 📌

---

## 🎯 用户体验改进

### 继承当前路径 ⭐

**问题：** tmux 默认在 HOME 目录创建新窗口

**解决：** 在当前目录创建

| 操作 | 快捷键 | 效果 |
|------|--------|------|
| 新窗口 | `Ctrl+B, c` | 在当前目录创建 |
| 水平分割 | `Ctrl+B, -` | 在当前目录分割 |
| 垂直分割 | `Ctrl+B, _` | 在当前目录分割 |

**示例：**
```bash
cd ~/projects/my-app
Ctrl+B, c    # 新窗口在 ~/projects/my-app ✓
```

---

## 🔧 更多自定义

编辑 `~/.tmux/.tmux.conf.local` 添加你的配置：

```bash
# 你的自定义绑定
bind <键> <命令>
```

详见 **CUSTOM_BINDINGS.md**
