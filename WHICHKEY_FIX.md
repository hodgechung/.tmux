# tmux-which-key 修复说明

## 问题
插件构建脚本使用了错误的导入语句：
```python
from pyyaml.lib import yaml  # ❌ 错误
```

## 解决方案
修改为正确的导入：
```python
import yaml  # ✅ 正确
```

## 修复步骤
```bash
cd /data/workspace/.tmux-plugins/tmux-which-key/plugin
sed -i 's/from pyyaml.lib import yaml/import yaml/' build.py
python3 build.py config.yaml init.tmux
```

## 验证
```bash
~/.tmux/load_plugins.sh
# 应该显示: [tmux-which-key] ✓
```

## 使用方法
1. 按住 `Ctrl+B` 大约 1 秒
2. 松开后会显示快捷键菜单
3. 根据菜单提示按下对应的键

## 注意
- which-key 有延迟显示（约 1 秒）
- 这是正常行为，避免误触发
- 如果没有显示，检查 `tmux show-options -g repeat-time`
