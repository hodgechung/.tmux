# 个人 tmux 配置（基于 oh-my-tmux）

这是 [gpakosz/.tmux](https://github.com/gpakosz/.tmux)（俗称 oh-my-tmux）的个人 fork，补丁集中在：

1. **`C-b ?` 帮助菜单重写**：用 tmux 3.0+ 的 `{…}` 块语法重构，修复子菜单命令被 `,` 误当三目分隔符截断的问题
2. **双行状态栏 + prefix cheat-sheet**：按下 `C-b` 时第二行亮起常用快捷键
3. **CPU 百分比**在状态栏右侧稳定显示（绕开 `_apply_theme` 的异步覆盖）
4. **tmux-continuum 手动激活**：禁用了 TPM 默认绑定时仍能自动保存/恢复 session
5. **离线部署脚本**：一键打包 + 离线安装

---

## 快速开始

```bash
# 有网机器：拉取并安装
git clone --depth 1 git@github.com:hodgechung/.tmux.git ~/.tmux
ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf

# 启动 tmux
tmux new -s main
```

首次启动会由 gpakosz 的 `_apply_plugins` 自动 clone TPM + 6 个插件到 `~/.tmux/plugins/`，需要访问 GitHub。

## 目录结构

```
.tmux/
├── .tmux.conf                  # gpakosz 主配置（upstream，勿改）
├── .tmux.conf.local            # 用户配置：插件声明 + hooks + CPU 重贴
├── .tmux.conf.override         # Space/reload 绑定（由 .local 末尾 source）
├── .tmux.conf.local.help       # C-b ? 菜单（由 .local 末尾 source）
│
├── scripts/
│   ├── apply_cheatsheet.sh     # 贴第二行 cheat-sheet + 激活 continuum
│   ├── pack-offline.sh         # 在有网机器打包离线安装包
│   └── install.offline.sh      # 在离线机器一键部署
│
├── plugins/                    # → symlink 到插件目录
├── install.sh                  # upstream 官方安装器
├── README.md                   # upstream 原版说明
├── README.custom.md            # 本文件
└── LICENSE.*                   # upstream 许可证
```

## 已启用的插件（6 个）

| 插件 | 触发键 | 作用 |
|---|---|---|
| tmux-cpu | —（状态栏右侧） | 显示 CPU 百分比 |
| tmux-copycat | `C-b /` 搜索；`C-b C-f/C-g/C-u/C-d` | 正则搜索 / 快搜文件路径、Git SHA、URL、数字 |
| tmux-fzf | `C-b F` | fzf 模糊搜索操作 |
| tmux-sessionx | `C-b O` | 高级会话切换 |
| tmux-resurrect | `C-b C-s` / `C-b C-r` | 手动保存 / 恢复 session |
| tmux-continuum | 自动 | 每 15 分钟自动保存，启动时自动恢复 |

## 常用快捷键

* `C-b ?` — 帮助菜单（Windows / Panes / Sessions / Copy / Config）
* `C-b h` — 列出全部键绑定
* `C-b Space` — 切换 pane 布局
* `C-b r` — 重载配置 + 立即重贴 cheat-sheet

按下 `C-b` 之后会在状态栏第二行看到：

```
 PREFIX   c新窗口  ,重命名  "上下分  -左右分  hjkl切换  z放大  s会话  d断开  │  ?菜单  h列表
```

## 离线部署

```bash
# 有网机器
bash ~/.tmux/scripts/pack-offline.sh
# → 生成 tmux-offline.tar.gz (~580 KB，含所有插件)

# 拷到离线机器，解压 + 安装
scp tmux-offline.tar.gz user@offline:/tmp/
ssh user@offline '
  tar xzf /tmp/tmux-offline.tar.gz -C "$HOME"
  bash "$HOME/.tmux/scripts/install.offline.sh"
'
```

若离线机器没装 tmux 3.x，建议同时带上 [tmux AppImage](https://github.com/nelsonenzo/tmux-appimage)。

## 核心实现细节（避免踩坑）

### 为什么 hook 要写在 `.tmux.conf.local` 末尾并带 `#!important`？

gpakosz 主配置在 line 161 会跑 `_apply_configuration` 外部 shell，其中 `_apply_theme` / `_apply_plugins` 等异步步骤会**清空** `.tmux.conf.local` 中注册的 hook 的 command 内容。gpakosz 专门留了 `_apply_important` 作为"主题之后再 source 一次"的扩展点 —— 它 grep 所有带 `#!important` 标记的 `set/bind/unbind` 行。

所以：

```tmux
set-hook -g client-attached "run-shell -b '$HOME/.tmux/scripts/apply_cheatsheet.sh'" #!important
set -g status-right "... CPU: ..." #!important
```

都必须放在 `.tmux.conf.local` 而**不是** `.tmux.conf.override`（后者在主题应用之前）。

### 为什么 continuum 要在脚本里手动 source？

`tmux-continuum` 的 `.tmux` 启动脚本需要被显式执行才会激活后台定时保存。你禁用了 TPM 的默认绑定（`run '~/.tmux/plugins/tpm/tpm'` 被注释），所以首次启动时 gpakosz 虽然 clone 了插件，但 continuum 的启动脚本没人触发。

解决：`apply_cheatsheet.sh` 在被 hook 首次调用时，通过 `@_continuum_loaded` 做幂等守卫 source 一次 `continuum.tmux`。

### cheat-sheet 格式中的 `#,` 是什么？

`#{?client_prefix,TRUE,FALSE}` 的 `,` 是 tmux 三目分隔符。你要在 TRUE 或 FALSE 分支里输出字面量逗号（比如"重命名"的键帽 `,`），必须转义为 `#,`，否则 tmux 会以为你在提前结束分支。

## 回滚

仓库有完整 git 历史，任何一次修改都可 `git revert`。如果只想暂时停用 cheat-sheet：

```bash
# 清掉第二行状态栏（当前 session）
tmux set -g status 1
tmux set -gu "status-format[1]"

# 永久停用：注释 .tmux.conf.local 末尾那 5 行 set-hook
```

## 许可证

继承自 upstream：WTFPL v2 / MIT。
