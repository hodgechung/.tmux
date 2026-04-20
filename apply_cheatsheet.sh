#!/usr/bin/env bash
# 给 tmux 状态栏第二行贴 prefix cheat-sheet
# 由 .tmux.conf.local 末尾的 !important hooks 调用
# 也可手动：bash ~/.tmux/apply_cheatsheet.sh

set -euo pipefail

# 等一下让 tmux 本轮 event loop 稳定
sleep 0.3

FMT='#[fill=#1c1c1c]#{?client_prefix,#[bg=#ffff00 fg=#080808 bold] PREFIX #[bg=#303030 fg=#e4e4e4]  #[fg=#ffff00]c#[fg=#8a8a8a]新窗口  #[fg=#ffff00]#,#[fg=#8a8a8a]重命名  #[fg=#ffff00]"#[fg=#8a8a8a]上下分  #[fg=#ffff00]-#[fg=#8a8a8a]左右分  #[fg=#ffff00]hjkl#[fg=#8a8a8a]切换  #[fg=#ffff00]z#[fg=#8a8a8a]放大  #[fg=#ffff00]s#[fg=#8a8a8a]会话  #[fg=#ffff00]d#[fg=#8a8a8a]断开  #[fg=#00afff]│#[default]  #[fg=#ffff00]?#[fg=#8a8a8a]菜单  #[fg=#ffff00]h#[fg=#8a8a8a]列表 #[default],#[bg=#1c1c1c fg=#585858] tips: C-b 唤起 prefix 后显示常用快捷键                                                                }'

tmux set -g status 2
tmux set -g 'status-format[1]' "$FMT"
