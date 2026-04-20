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

# --- 第二行 cheat-sheet（上下文感知：copy-mode / prefix / marked / idle）---
#
# 嵌套三目: #{?pane_in_mode, COPY, #{?client_prefix, PREFIX, #{?pane_marked, MARKED, IDLE}}}
# 注意事项：
#   1) 三目分隔符是 `,`，文本里的字面逗号必须写 `#,`
#   2) 在嵌套内层不能直接用双引号，所有样式都用 tmux 的 #[…]
#   3) 为了可读性，分四个 shell 变量拼接

# ---- IDLE：无 prefix、不在 copy 模式、没标记 pane ----
IDLE='#[bg=#1c1c1c fg=#585858] tips: C-b ? 速查全部快捷键   C-b 唤起 prefix 查看高频键                                           '

# ---- PREFIX：按下 C-b 的瞬间 ----
PREFIX='#[bg=#ffff00 fg=#080808 bold] PREFIX #[bg=#303030 fg=#e4e4e4]  #[fg=#ffff00]c#[fg=#8a8a8a]新窗口  #[fg=#ffff00]#,#[fg=#8a8a8a]重命名  #[fg=#ffff00]"#[fg=#8a8a8a]上下分  #[fg=#ffff00]-#[fg=#8a8a8a]左右分  #[fg=#ffff00]hjkl#[fg=#8a8a8a]切换  #[fg=#ffff00]z#[fg=#8a8a8a]放大  #[fg=#ffff00]s#[fg=#8a8a8a]会话  #[fg=#ffff00]d#[fg=#8a8a8a]断开  #[fg=#00afff]│#[default]  #[fg=#ffff00]?#[fg=#8a8a8a]菜单  #[fg=#ffff00]h#[fg=#8a8a8a]列表  '

# ---- COPY：进入 copy-mode ----
COPY='#[bg=#5fff00 fg=#080808 bold] COPY #[bg=#303030 fg=#e4e4e4]  #[fg=#5fff00]v#[fg=#8a8a8a]选择  #[fg=#5fff00]V#[fg=#8a8a8a]行选  #[fg=#5fff00]C-v#[fg=#8a8a8a]矩形  #[fg=#5fff00]y#[fg=#8a8a8a]复制(→系统剪贴板)  #[fg=#5fff00]/?#[fg=#8a8a8a]搜索  #[fg=#5fff00]n/N#[fg=#8a8a8a]跳匹配  #[fg=#5fff00]g/G#[fg=#8a8a8a]首/末  #[fg=#00afff]│#[default]  #[fg=#ffff00]q/Esc#[fg=#8a8a8a]退出  '

# ---- MARKED：有 pane 被 m 标记 ----
MARKED='#[bg=#ff00af fg=#080808 bold] MARKED #[bg=#303030 fg=#e4e4e4]  #[fg=#ff00af]C-b m#[fg=#8a8a8a]取消标记  #[fg=#ff00af]C-b M#[fg=#8a8a8a]选中此 pane  #[fg=#ff00af];#[fg=#8a8a8a]跳回标记  #[fg=#00afff]│#[default]  #[fg=#8a8a8a]可用于跨窗口 swap-pane / join-pane  '

# 组装嵌套三目。在 tmux format 里 pane_in_mode 为 1 表示 copy-mode 等
FMT="#[fill=#1c1c1c]#{?pane_in_mode,${COPY},#{?client_prefix,${PREFIX},#{?pane_marked,${MARKED},${IDLE}}}}"

tmux set -g status 2
tmux set -g 'status-format[1]' "$FMT"