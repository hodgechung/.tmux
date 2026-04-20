#!/usr/bin/env bash
# cheat-sheet.sh —— 由 C-b ? 通过 display-popup 调用
# 输出一份静态文本速查表，涵盖 tmux 原生键 + 本配置自定义 + 插件
#
# 设计原则：
#   - 只读展示，不接收交互（真要操作用 list-keys 或菜单）
#   - 分类排布，颜色分级，prefix 键默认 C-b
#   - 80x40 左右能完全装下

set -euo pipefail

# ANSI 颜色（tmux popup 里可以直接渲染）
C_TITLE=$'\033[1;33m'      # 黄加粗（分组标题）
C_KEY=$'\033[1;36m'        # 青加粗（键）
C_PREFIX=$'\033[0;90m'     # 暗灰（C-b 前缀占位）
C_DESC=$'\033[0;37m'       # 白（说明）
C_SEP=$'\033[0;34m'        # 蓝（分隔符）
C_PLUGIN=$'\033[0;35m'     # 紫（插件来源）
R=$'\033[0m'

# 单条快捷键：prefix + key -> desc
# 参数：$1=key, $2=desc, $3=optional tag (plugin name)
k() {
  local key="$1" desc="$2" tag="${3:-}"
  printf "  ${C_PREFIX}C-b${R} ${C_KEY}%-10s${R} ${C_DESC}%s${R}" "$key" "$desc"
  [[ -n "$tag" ]] && printf "  ${C_PLUGIN}[%s]${R}" "$tag"
  printf "\n"
}

# 不需要 prefix 的键
n() {
  local key="$1" desc="$2" tag="${3:-}"
  printf "  ${C_KEY}%-14s${R} ${C_DESC}%s${R}" "$key" "$desc"
  [[ -n "$tag" ]] && printf "  ${C_PLUGIN}[%s]${R}" "$tag"
  printf "\n"
}

h() {
  printf "\n${C_TITLE}━━━ %s ━━━${R}\n" "$1"
}

cat <<EOF
${C_TITLE}tmux 速查表${R}  ${C_PREFIX}(Prefix = C-b；按 q 或 Esc 关闭)${R}
EOF

h "🪟 Windows（窗口）"
k "c"    "新建窗口（保留当前路径）"
k ","    "重命名当前窗口"
k "&"    "关闭当前窗口（带确认）"
k "n"    "下一个窗口"
k "p"    "上一个窗口"
k "0-9"  "按序号跳转"
k "Tab"  "回到上一个使用的窗口"
k "W"    "窗口选择器"
k "C-h"  "上一个窗口（oh-my-tmux）"
k "C-l"  "下一个窗口（oh-my-tmux）"
k "C-S-H" "当前窗口左移一位"
k "C-S-L" "当前窗口右移一位"

h "📐 Panes（面板）"
k "%"    "左右分割"
k "\""   "上下分割"
k "-"    "上下分割（oh-my-tmux 简写）"
k "_"    "左右分割（oh-my-tmux 简写）"
k "x"    "关闭当前面板（带确认）"
k "z"    "放大 / 恢复"
k "+"    "最大化当前面板"
k "!"    "将面板抽离为新窗口"
k "Space" "循环切换布局"
k "h/j/k/l" "上下左右切换面板（vim 风）"
k "H/J/K/L" "上下左右调整大小"
k "o"    "循环切换面板"
k "q"    "短暂显示面板编号"
k "{"    "当前面板与前一个交换"
k "}"    "当前面板与后一个交换"
k "<"    "交换面板（向前）"
k ">"    "交换面板（向后）"
k "M"    "标记当前面板"

h "🖥  Sessions（会话）"
k "s"    "会话选择器（choose-tree）"
k "\$"   "重命名当前会话"
k "d"    "分离当前 client（session 继续跑）"
k "D"    "选择要踢掉的 client"
k "("    "上一个会话"
k ")"    "下一个会话"
k "C-c"  "新建会话（oh-my-tmux）"
k "C-f"  "按名字跳到会话（oh-my-tmux）"
k "BTab" "回到上一个会话"

h "📋 Copy Mode（复制模式）"
k "["    "进入复制模式"
k "Enter" "进入复制模式（oh-my-tmux）"
k "]"    "粘贴"
k "="    "选择粘贴缓冲区"
k "#"    "列出所有 buffer"
printf "  ${C_PREFIX}(copy-mode 内)${R}\n"
n "v"     "开始选择"
n "C-v"   "切换矩形选择"
n "y"     "复制并退出"
n "Escape" "取消"
n "H / L"  "行首 / 行尾"

h "🔧 Config / 杂项"
k "?"    "（本速查表）"
k "h"    "列出全部键绑定（list-keys）"
k "r"    "重载配置 + 立即重贴 cheat-sheet"
k "e"    "用 \$EDITOR 打开 .tmux.conf.local"
k ":"    "命令模式（tmux 命令）"
k "~"    "查看最近的 tmux 消息"
k "t"    "时钟模式"
k "C-z"  "挂起 tmux client"
k "m"    "切换鼠标模式（oh-my-tmux）"

h "🔌 Plugins（插件快捷键）"
k "/"    "正则搜索屏幕内容" "copycat"
k "C-f"  "快搜文件路径" "copycat"
k "C-g"  "快搜 Git commit / SHA" "copycat"
k "C-u"  "快搜 URL" "copycat"
k "C-d"  "快搜数字" "copycat"
k "F"    "fzf 模糊搜索" "tmux-fzf"
k "O"    "高级会话切换" "tmux-sessionx"
k "C-s"  "手动保存 session" "resurrect"
k "C-r"  "手动恢复 session" "resurrect"
printf "  ${C_PLUGIN}continuum${R}${C_DESC}: 每 15 分钟自动保存、启动时自动恢复${R}\n"

h "💡 提示"
cat <<TIPS
  ${C_DESC}• 第二行状态栏在按下 C-b 时会亮起高频键提示${R}
  ${C_DESC}• 想按分类操作 → 用 list-keys 菜单：${R}${C_KEY}C-b h${R}
  ${C_DESC}• 进 copy-mode 后可用 vim 键位移动、/ 搜索、y 复制${R}
TIPS

# popup 需要用户按键才关，下面的提示挂在最后
printf "\n${C_PREFIX}────────────────────────────────────────────${R}\n"
printf "${C_PREFIX}（按任意键或 Esc/q 关闭）${R}\n"

# 让 popup 等用户按键
read -rsn1 -t 300 || true
