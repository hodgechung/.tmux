# 键绑定说明

## ✅ 最终方案：覆盖 `?` 键

### gpakosz 原始
- `Ctrl+B, ?` → 显示快捷键列表（`list-keys`）

### 覆盖后
- `Ctrl+B, ?` → **which-key 交互式菜单** ✅

### which-key 菜单中的选项
在 which-key 菜单中，按 `/` 可以查看完整快捷键列表（替代原 gpakosz 功能）

---

## 🎹 最终键绑定

| 快捷键 | 功能 | 来源 |
|--------|------|------|
| `Ctrl+B, ?` | **which-key 菜单** | 覆盖 gpakosz ⭐ |
| `Ctrl+B, F` | 模糊搜索 | tmux-fzf |
| `Ctrl+B, Shift+O` | 会话管理 | tmux-sessionx |
| `Ctrl+B, Space` | 快速复制 | tmux-thumbs |
| `Ctrl+B, /` | 内容搜索 | tmux-copycat |

---

## 💡 为什么覆盖 `?`

### 优点
- ✅ **最符合直觉** - `?` = 帮助/问号
- ✅ **功能更强** - which-key 菜单 > 纯文本列表
- ✅ **包含原功能** - 菜单中按 `/` 可查看完整列表
- ✅ **易于记忆** - 问号 = 寻求帮助

### 原 gpakosz 功能保留
在 which-key 菜单中：
- 按 `/` → 查看完整快捷键列表（原 `list-keys -N`）

---

**最佳方案，无需妥协！** ✨
