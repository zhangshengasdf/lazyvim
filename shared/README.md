# `shared/` — 共享工具模块

这个目录存放**所有章节共用的工具代码**，不包含任何教程内容。

## 文件

| 文件 | 作用 |
|------|------|
| `verify.lua` | 配置验证工具：检查选项、快捷键、插件加载状态 |

## verify.lua 使用方法

### 基本用法

```lua
-- 在你的验证脚本中
local verify = dofile("shared/verify.lua")

-- 检查选项
local ok, msg = verify.check_opt("number", true)
print(msg)

-- 检查快捷键
local ok, msg = verify.check_keymap("n", "<leader>ff")
print(msg)

-- 批量检查并打印摘要
verify.run({
  { fn = verify.check_opt, args = { "number", true } },
  { fn = verify.check_opt, args = { "relativenumber", true } },
  { fn = verify.check_keymap, args = { "n", "<leader>ff" } },
})
```

### Headless 验证

```bash
# 加载指定配置后验证
nvim --headless -u NONE -c "luafile path/to/your/config.lua" -c "luafile shared/verify.lua" -c "qa!"
```

### 可用函数

| 函数 | 参数 | 返回 | 说明 |
|------|------|------|------|
| `load_config(path)` | 文件路径 | `bool, string\|nil` | 加载配置文件，返回成功/失败 |
| `check_opt(name, expected)` | 选项名, 期望值 | `bool, string` | 检查 vim.opt 选项 |
| `check_keymap(mode, lhs)` | 模式, 按键 | `bool, string` | 检查快捷键是否注册 |
| `check_plugin(plugin)` | 插件名 | `bool, string` | 检查插件是否已加载 |
| `summary(results)` | 结果列表 | `bool` | 打印验证摘要 |
| `run(checks)` | 检查列表 | `bool` | 便捷方法：运行并摘要 |

## 章节作者提示

- 每章的 `exercises/` 目录里可以用 `verify.lua` 验证练习答案。
- 编写章节时，先用 `check_opt` 和 `check_keymap` 确保示例代码能通过验证。
- 不要在章节代码中 `require("shared.verify")`——用相对路径 `dofile` 加载即可。
