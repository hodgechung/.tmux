# tmux 最终键绑定方案

## 🎉 所有插件已配置完成

### CPU 监控 + 7 个插件 + gpakosz/.tmux

---

## 🎹 完整键绑定列表

### 插件快捷键

| 快捷键 | 功能 | 插件 | 说明 |
|--------|------|------|------|
| `Ctrl+B, '` | **which-key 菜单** | tmux-which-key | 交互式菜单 ⭐ |
| `Ctrl+B, F` | 模糊搜索 | tmux-fzf | 搜索会话/窗口 |
| `Ctrl+B, Shift+O` | 会话管理 | tmux-sessionx | fzf 会话选择 |
| `Ctrl+B, Space` | 快速复制 | tmux-thumbs | 文本快速标记 |
| `Ctrl+B, /` | 内容搜索 | tmux-copycat | 正则搜索 |
| `Ctrl+B, Ctrl+F` | 文件路径搜索 | tmux-copycat | 搜索路径 |
| `Ctrl+B, Ctrl+U` | URL 搜索 | tmux-copycat | 搜索链接 |
| `Ctrl+B, Ctrl+S` | 保存会话 | tmux-resurrect | 会话持久化 |
| `Ctrl+B, Ctrl+R` | 恢复会话 | tmux-resurrect | 恢复保存 |
| 自动 | 自动保存 | tmux-continuum | 每 15 分钟 |

### gpakosz 原生快捷键

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `Ctrl+B, ?` | 快捷键列表 | gpakosz 内置 |
| `Ctrl+B, e` | 编辑配置 | 打开 .local |
| `Ctrl+B, r` | 重载配置 | 应用修改 |
| `Ctrl+B, m` | 鼠标模式 | 切换鼠标 |
| `Ctrl+B, -` | 水平分割 | 分割窗格 |
| `Ctrl+B, _` | 垂直分割 | 分割窗格 |
| `Ctrl+B, +` | 最大化窗格 | 全屏/还原 |

---

## 🎯 which-key 菜单详解

### 触发方式
```
Ctrl+B, '  (单引号键)
```

### 主菜单选项

按下 `Ctrl+B, '` 后显示：

```
┌─────── tmux ───────┐
│ space - Run        │
│ tab   - Last win   │
│ `     - Last pane  │
│ c     - Copy mode  │
├────────────────────┤
│ +w - Windows  ⭐   │
│ +p - Panes    ⭐   │
│ +b - Buffers       │
│ +s - Sessions      │
│ +C - Client        │
├────────────────────┤
│ T     - Time       │
│ ~     - Messages   │
│ ?     - Keys       │
└────────────────────┘
```

### 常用子菜单

#### Windows 菜单 (`w`)
- `c` - 新建窗口
- `/` - 水平分割
- `-` - 垂直分割
- `l` - 布局菜单
- `R` - 重命名
- `X` - 关闭窗口

#### Panes 菜单 (`p`)
- `h/j/k/l` - 移动选择
- `z` - 最大化/恢复
- `r` - 调整大小菜单
- `!` - 分离为窗口
- `X` - 关闭窗格

---

## 📊 状态栏

```
⌨ | CPU: 35.2% | 16:20 | 02-Apr | root@hostname
```

- `⌨` - Prefix 状态（按下 Ctrl+B 显示 ON）
- `CPU` - 实时使用率
- 时间 + 日期 + 用户@主机

---

## 🚀 推荐工作流

### 1. 启动 tmux
```bash
ssh anydev_ts3
tmux new -s work
~/.tmux/apply_custom_statusbar.sh
```

### 2. 探索功能
- 按 `Ctrl+B, '` 查看 which-key 菜单
- 按 `Ctrl+B, F` 尝试模糊搜索
- 按 `Ctrl+B, Space` 快速复制屏幕文本
- 按 `Ctrl+B, Shift+O` 管理会话

### 3. 保存工作
- `Ctrl+B, Ctrl+S` 保存当前布局
- 断开连接前自动保存（continuum）
- `Ctrl+B, Ctrl+R` 恢复会话

---

## 📚 文档索引

- **FINAL_KEYS.md** - 本文档（键绑定总览）⭐
- **WHICHKEY_USAGE.md** - which-key 详细说明
- **SHORTCUTS.md** - 快捷键参考卡
- **FINAL_USAGE.md** - 完整使用指南
- **PLUGINS.md** - 插件详细文档

---

## 💡 提示

### 记不住快捷键？
直接按 `Ctrl+B, '` 打开 which-key 菜单！

### 想要列表形式？
按 `Ctrl+B, ?` 查看 gpakosz 的完整键列表

### 需要搜索？
- 文本：`Ctrl+B, /`
- 文件：`Ctrl+B, Ctrl+F`
- 任意：`Ctrl+B, F`

---

**所有功能已配置完成！享受强大的 tmux！** 🎉
