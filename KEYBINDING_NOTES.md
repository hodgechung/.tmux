# 键绑定说明

## ⚠️ 键冲突解决历史

### 第一次尝试：`?` 键
- **问题：** gpakosz/.tmux 已占用 `?` 显示快捷键列表
- **结果：** 冲突 ❌

### 第二次尝试：`'` (单引号)
- **问题：** gpakosz/.tmux 使用 `'` 选择窗口
- **结果：** 冲突 ❌

### 最终方案：`W` (大写 = Shift+W) ✅
- **优点：** 
  - gpakosz 未占用
  - 容易记忆（W = Which-key）
  - Shift+W 有"展开"的感觉
- **结果：** 无冲突 ✅

---

## 🎹 最终键绑定

| 快捷键 | 功能 | 插件/来源 |
|--------|------|-----------|
| `Ctrl+B, Shift+W` | **which-key 菜单** | tmux-which-key ⭐ |
| `Ctrl+B, F` | 模糊搜索 | tmux-fzf |
| `Ctrl+B, Shift+O` | 会话管理 | tmux-sessionx |
| `Ctrl+B, Space` | 快速复制 | tmux-thumbs |
| `Ctrl+B, /` | 内容搜索 | tmux-copycat |
| `Ctrl+B, w` | 窗口列表 | gpakosz (小写 w) |
| `Ctrl+B, '` | 选择窗口 | gpakosz (单引号) |
| `Ctrl+B, ?` | 快捷键列表 | gpakosz |

---

## 💡 记忆技巧

- **W** = **W**hich-key（哪个键）
- **大写** = Shift+W = "展开菜单"的感觉
- 与小写 `w`（窗口列表）区分开

---

**现在所有键都可用，无冲突！** ✨
