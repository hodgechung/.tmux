# My Custom tmux Configuration

Forked from [gpakosz/.tmux](https://github.com/gpakosz/.tmux)

## Quick Install

```bash
cd
git clone https://github.com/hodgechung/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .
```

## My Customizations

- ✅ CPU usage display in status bar
- ✅ Enabled plugins: tmux-cpu, tmux-resurrect, tmux-continuum, tmux-which-key
- ✅ Custom status-right configuration

## Install Plugins

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

In tmux, press `Ctrl+B` then `Shift+I` to install plugins.

---

Based on [gpakosz/.tmux](https://github.com/gpakosz/.tmux) - Copyright 2012— Gregory Pakosz (@gpakosz)

## 🐛 故障排查

### CPU 不显示

如果状态栏中 CPU 显示为空或脚本路径：

1. **检查插件是否安装**：
   ```bash
   ls ~/.tmux/plugins/tmux-cpu/scripts/cpu_percentage.sh
   ```

2. **手动测试脚本**：
   ```bash
   bash ~/.tmux/plugins/tmux-cpu/scripts/cpu_percentage.sh
   ```

3. **运行测试脚本**：
   ```bash
   ~/tmux/test_tmux_cpu.sh
   ```

4. **重新安装插件**：
   ```bash
   cd ~/.tmux/plugins
   [ ! -d tmux-cpu ] && git clone https://github.com/tmux-plugins/tmux-cpu.git
   ```

5. **在 tmux 内手动设置**（临时）：
   ```bash
   # 按 Ctrl+B 然后 : 输入：
   set -g status-right " CPU: #(~/.tmux/plugins/tmux-cpu/scripts/cpu_percentage.sh) | %H:%M "
   ```

### 配置说明

本配置使用 `set-hook -g after-refresh-client` 来覆盖 gpakosz 主题的状态栏设置。
这是唯一不修改 `.tmux.conf` 主配置文件的方法。

