#!/usr/bin/env bash
# 给 tmux 状态栏第二行贴 prefix cheat-sheet
# 由 .tmux.conf.local 末尾的 !important hooks 调用
# 也可手动：bash ~/.tmux/scripts/apply_cheatsheet.sh

set -euo pipefail

# 极简 shell 里 PATH 可能不含 /usr/bin（sleep/awk 会缺失），补全
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"

# 小延迟让 tmux event loop 稳定。若 sleep 不存在就跳过（不强依赖）
if command -v sleep >/dev/null 2>&1; then
  sleep 0.3
fi

# --- 自注册 hooks（防 gpakosz _apply_important 失败导致僵尸 hook）---
# 每次跑脚本都重贴 hook command，即使 .tmux.conf.local 里的 !important
# 那套机制没生效，只要手动跑过一次脚本，后续 hook 就能用。
HOOK_CMD="run-shell -b '$HOME/.tmux/scripts/apply_cheatsheet.sh'"
for h in session-created client-attached after-select-window after-new-window pane-focus-in; do
  tmux set-hook -g "$h" "$HOOK_CMD" 2>/dev/null || true
done

# --- 一次性加载 continuum（TPM 被禁用，需要手动 source 它的 .tmux）---
if [ "$(tmux show -gqv '@_continuum_loaded' 2>/dev/null || true)" != "1" ]; then
  CONT="$HOME/.tmux/plugins/tmux-continuum/continuum.tmux"
  if [ -x "$CONT" ]; then
    "$CONT" >/dev/null 2>&1 || true
    tmux set -g '@_continuum_loaded' 1
  fi
fi

# --- 确保 continuum_save 触发器在 status-right 里（否则不会自动保存）---
CURRENT_SR="$(tmux show -gv status-right 2>/dev/null || true)"
case "$CURRENT_SR" in
  *continuum_save.sh*) : ;;
  *) tmux set -ag status-right "#($HOME/.tmux/plugins/tmux-continuum/scripts/continuum_save.sh)" ;;
esac

# --- 第二行 cheat-sheet（上下文感知：copy-mode / prefix / marked / idle）---
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