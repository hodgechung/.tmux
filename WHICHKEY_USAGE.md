# tmux-which-key 完整说明

## ⚠️ 键绑定冲突

### 问题
- **tmux-which-key** 默认绑定：`Ctrl+B, Space`
- **tmux-thumbs** 默认绑定：`Ctrl+B, Space`
- 两个插件冲突，thumbs 覆盖了 which-key

### 解决方案
重新绑定 which-key 到 `?` 键：

```
Ctrl+B, ?
```

## 🎹 正确使用方法

### 触发 which-key 菜单
```
1. 按 Ctrl+B
2. 松开
3. 按 ?（问号键）
4. 显示交互式菜单
```

### 触发 tmux-thumbs
```
1. 按 Ctrl+B
2. 松开
3. 按 Space（空格键）
4. 显示文本标记
```

## 📋 菜单导航

进入 which-key 菜单后：
- 按字母/数字选择项目
- `+` 开头的是子菜单
- 按 `Esc` 退出菜单
- 按对应的键执行命令

## 🎨 菜单结构

主菜单（`Ctrl+B, ?`）：
- `space` - 运行命令
- `tab` - 上一个窗口
- `c` - 复制模式
- `w` - 窗口菜单 ⭐
- `p` - 窗格菜单 ⭐
- `b` - 缓冲区菜单
- `s` - 会话菜单
- `C` - 客户端菜单
- `?` - 查看所有快捷键

## 💡 推荐使用

### 常用子菜单

**窗口管理** (`Ctrl+B, ?` → `w`):
- `c` - 创建窗口
- `/` - 水平分割
- `-` - 垂直分割
- `l` - 布局菜单
- `R` - 重命名窗口

**窗格管理** (`Ctrl+B, ?` → `p`):
- `h/j/k/l` - 移动到左/下/上/右窗格
- `z` - 最大化/恢复窗格
- `r` - 调整大小菜单
- `!` - 分离窗格为新窗口

## 🔧 自定义配置

编辑配置：
```bash
vim ~/.tmux/plugins/tmux-which-key/config.yaml
```

重新构建：
```bash
cd ~/.tmux/plugins/tmux-which-key/plugin
python3 build.py ../config.yaml init.tmux
```

重新加载 tmux:
```bash
tmux source ~/.tmux/.tmux.conf
```

---

**现在 which-key 和 thumbs 都可以正常使用了！** 🎉
