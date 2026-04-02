# tmux 快速上手指南

## 🚀 立即使用

```bash
# 连接到 anydev_ts3
ssh anydev_ts3

# 启动 tmux
tmux

# 或连接到现有会话
tmux attach -t absolutely-final
```

## 📊 状态栏说明

底部状态栏从左到右：
- `⌨ON/OFF` - Prefix 键（Ctrl+B）是否按下
- `CPU: XX.X%` - 实时 CPU 使用率 ✨
- `15:27` - 当前时间
- `02-Apr` - 日期
- `root@hodgezhong-1uetogvoya` - 用户@主机名

## ⌨️ 常用快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+B, c` | 新建窗口 |
| `Ctrl+B, n/p` | 下一个/上一个窗口 |
| `Ctrl+B, %` | 垂直分屏 |
| `Ctrl+B, "` | 水平分屏 |
| `Ctrl+B, 方向键` | 切换面板 |
| `Ctrl+B, d` | 分离会话（后台运行） |
| `Ctrl+B, [` | 进入复制模式（滚动） |
| `Ctrl+B, ?` | 查看所有快捷键 |

## 🔌 插件快捷键

### tmux-which-key (快捷键提示)
- `Ctrl+B` 然后等待 1 秒 → 显示所有可用快捷键

### tmux-fzf (模糊搜索)
- `Ctrl+B, F` → 打开 fzf 菜单
  - 选择 `s` - 搜索会话
  - 选择 `w` - 搜索窗口

### tmux-sessionx (会话管理)
- `Ctrl+B, Shift+O` → 打开会话选择器
  - `Enter` - 切换会话
  - `Ctrl+X` - 删除会话
  - `Ctrl+R` - 重命名会话

### tmux-thumbs (快速复制)
- `Ctrl+B, Space` → 激活 thumbs 模式
  - 屏幕上出现字母标签
  - 输入对应字母复制内容

### tmux-copycat (搜索)
- `Ctrl+B, /` → 正则搜索
- `Ctrl+B, Ctrl+F` → 搜索文件
- `Ctrl+B, Ctrl+U` → 搜索 URL

### tmux-resurrect (会话保存)
- `Ctrl+B, Ctrl+S` → 保存当前会话
- `Ctrl+B, Ctrl+R` → 恢复保存的会话

### tmux-continuum (自动保存)
- 自动每 15 分钟保存一次
- 启动时自动恢复上次会话

## 📱 在 iPhone Termius 中使用

1. 打开 Termius
2. 连接到 anydev_ts3
3. 运行 `tmux attach`
4. 底部可以看到 CPU 使用率！
5. 使用蓝牙键盘体验最佳

## 🐛 故障排查

### CPU 不显示
```bash
# 测试 CPU 脚本
~/.tmux/plugins/tmux-cpu/scripts/cpu_percentage.sh

# 重新加载配置
tmux source ~/.tmux.conf
```

### 插件不工作
```bash
# 在 tmux 中按
Ctrl+B, Shift+I  # 安装插件
Ctrl+B, Shift+U  # 更新插件
```

### 完全重置
```bash
tmux kill-server
tmux
```

## 🎯 推荐工作流

1. **启动持久化会话**:
   ```bash
   tmux new -s work
   ```

2. **创建多窗口布局**:
   - 窗口 1: 编辑代码
   - 窗口 2: 运行服务
   - 窗口 3: 查看日志

3. **分离并离开**:
   ```bash
   Ctrl+B, d
   ```

4. **稍后重新连接**:
   ```bash
   tmux attach -t work
   ```

---

**享受 tmux 的强大功能！** 🚀

文档: [PLUGINS.md](PLUGINS.md) | 仓库: https://github.com/hodgechung/.tmux
