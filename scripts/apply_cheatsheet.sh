#!/usr/bin/env bash
# 给 tmux 状态栏第二行贴 prefix cheat-sheet
# 由 .tmux.conf.local 末尾的 !important hooks 调用
# 也可手动：bash ~/.tmux/scripts/apply_cheatsheet.sh

set -euo pipefail

# 等一下让 tmux 本轮 event loop 稳定
sleep 0.3

# --- 一次性加载 continuum（TPM 被禁用，需要手动 source 它的 .tmux）---
if [[ "$(tmux show -gqv '@_continuum_loaded' 2>/dev/null || true)" != "1" ]]; then
  CONT="$HOME/.tmux/plugins/tmux-continuum/continuum.tmux"
  if [[ -x "$CONT" ]]; then
    "$CONT" >/dev/null 2>&1 || true
    tmux set -g '@_continuum_loaded' 1
  fi
fi

# --- 确保 continuum_save 触发器在 status-right 里（否则不会自动保存）---
# continuum 加载时是用 `set -ag status-right "..."` 追加的，但我们在
# .tmux.conf.local 里用 `set -g status-right "..."` 全量覆盖过它，所以
# 这里检测一下：缺触发器就补上。
CURRENT_SR="$(tmux show -gv status-right 2>/dev/null || true)"
if [[ "$CURRENT_SR" != *continuum_save.sh* ]]; then
  tmux set -ag status-right "#($HOME/.tmux/plugins/tmux-continuum/scripts/continuum_save.sh)"
fi

# --- 第二行 cheat-sheet ---
FMT='#[fill=#1c1c1c]#{?client_prefix,#[bg=#ffff00 fg=#080808 bold] PREFIX #[bg=#303030 fg=#e4e4e4]  #[fg=#ffff00]c#[fg=#8a8a8a]新窗口  #[fg=#ffff00]#,#[fg=#8a8a8a]重命名  #[fg=#ffff00]"#[fg=#8a8a8a]上下分  #[fg=#ffff00]-#[fg=#8a8a8a]左右分  #[fg=#ffff00]hjkl#[fg=#8a8a8a]切换  #[fg=#ffff00]z#[fg=#8a8a8a]放大  #[fg=#ffff00]s#[fg=#8a8a8a]会话  #[fg=#ffff00]d#[fg=#8a8a8a]断开  #[fg=#00afff]│#[default]  #[fg=#ffff00]?#[fg=#8a8a8a]菜单  #[fg=#ffff00]h#[fg=#8a8a8a]列表 #[default],#[bg=#1c1c1c fg=#585858] tips: C-b 唤起 prefix 后显示常用快捷键                                                                }'

tmux set -g status 2
tmux set -g 'status-format[1]' "$FMT"