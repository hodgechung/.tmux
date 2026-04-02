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
