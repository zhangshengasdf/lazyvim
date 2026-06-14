# 第18章 自定义快捷键与自动命令 — vim.keymap.set 与 nvim_create_autocmd

> **插件的 `keys` 字段只能做懒加载触发。真正自由的快捷键和自动行为，要靠 Neovim 原生 API。**
> 本章详解 `vim.keymap.set` 的四个参数、which-key 分组注册、
> `lua/config/keymaps.lua` 和 `lua/config/autocmds.lua` 的写法，
> 以及 `vim.api.nvim_create_autocmd` 的完整用法。
> 学完本章，你能用纯 Lua 写出任何快捷键和自动命令。

---

## 本章目标

学完本章，你将能够：

1. **精通 `vim.keymap.set`**：mode、lhs、rhs、opts 四个参数的完整用法
2. **注册 which-key 分组**：让 `<leader>f` 下面的快捷键自动归组显示
3. **写 `lua/config/keymaps.lua`**：LazyVim 的全局快捷键配置文件
4. **写 `lua/config/autocmds.lua`**：LazyVim 的自动命令配置文件
5. **用 `nvim_create_autocmd`**：在特定事件发生时自动执行代码
6. **用 buffer-local keymaps**：只对当前 buffer 生效的快捷键

> ⚠️ **前置条件**：完成第 07 章（Leader 键）和第 08 章（which-key）。
> 本章是"从配置插件到配置 Neovim 本身"的转折点。

---

## 钩子：为什么插件 keys 字段不够用

插件 spec 里的 `keys` 字段有两个限制：

1. **只能绑定到插件的命令**——如果你想在按键时执行一段自定义 Lua 代码，`keys` 字段做不到
2. **没有分组信息**——which-key 只显示单个按键的 desc，不能把 `<leader>f` 下面的按键归到"查找"组

要突破这些限制，你需要直接用 Neovim 的 `vim.keymap.set` API。

---

## vim.keymap.set 详解

### 函数签名

```lua
vim.keymap.set(mode, lhs, rhs, opts)
```

| 参数 | 类型 | 说明 |
|------|------|------|
| `mode` | string \| table | 模式：`"n"`(普通)、`"i"`(插入)、`"v"`(可视)、`"x"`(选择)、`"c"`(命令行)、`"t"`(终端) |
| `lhs` | string | 按键序列：`"<leader>ff"`、`"<C-s>"`、`"<leader>x"` |
| `rhs` | string \| function | 执行的动作：命令字符串或 Lua 函数 |
| `opts` | table | 选项：`desc`、`silent`、`noremap`、`buffer`、`nowait` 等 |

### 模式参数

```lua
-- 单个模式
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "保存文件" })

-- 多个模式
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "保存文件" })

-- 常用模式速查
-- "n"  普通模式（最常用）
-- "i"  插入模式
-- "v"  可视 + 选择模式
-- "x"  只有选择模式
-- "c"  命令行模式
-- "t"  终端模式
```

### lhs 按键语法

```lua
-- Leader 键组合（LazyVim 默认 Leader 是空格）
"<leader>ff"   -- 空格 + f + f
"<leader>fg"   -- 空格 + f + g

-- Ctrl 组合
"<C-s>"        -- Ctrl + s
"<C-w>"        -- Ctrl + w

-- Alt 组合
"<A-j>"        -- Alt + j（有些终端用 Esc+j 代替）
"<M-j>"        -- Meta + j（等价于 Alt + j）

-- 特殊键
"<CR>"         -- 回车
"<Esc>"        -- Esc
"<Tab>"        -- Tab
"<BS>"         -- 退格
"<Del>"        -- 删除
"<Up>/<Down>/<Left>/<Right>"  -- 方向键

-- 多键序列（不用 timeout）
"<leader>qq"   -- 空格 + q + q（先按 q 再按 q）
```

### rhs 动作类型

```lua
-- 类型 1：命令字符串
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "保存" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "退出" })

-- 类型 2：Ex 命令字符串
vim.keymap.set("n", "<leader>e", ":echo 'hello'<CR>", { desc = "打招呼" })

-- 类型 3：Lua 函数（最灵活）
vim.keymap.set("n", "<leader>x", function()
  print("当前行: " .. vim.fn.line("."))
end, { desc = "打印行号" })

-- 类型 4：调用插件 API
vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "查找文件" })

-- 类型 5：多步操作
vim.keymap.set("n", "<leader>sr", function()
  local word = vim.fn.expand("<cword>")
  require("telescope.builtin").grep_string({ search = word })
end, { desc = "搜索光标下的词" })
```

### opts 选项

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `desc` | string | nil | 描述（which-key 会显示） |
| `silent` | bool | false | 是否静默（不显示命令输出） |
| `noremap` | bool | true | 是否非递归（几乎总是 true） |
| `buffer` | bool \| number | false | 是否 buffer-local（true=当前 buffer，数字=指定 buffer） |
| `nowait` | bool | false | 是否立即执行（不等待后续按键） |
| `expr` | bool | false | rhs 返回值作为按键映射 |
| `replace_keycodes` | bool | true | expr 模式下是否替换特殊键码 |

```lua
-- 完整示例：带所有常用选项
vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, {
  desc = "查找文件",      -- which-key 显示
  silent = true,           -- 不显示命令输出
  noremap = true,          -- 非递归（默认就是 true）
})
```

---

## which-key 分组注册

which-key 不仅显示单个快捷键的 desc，还支持**分组**——让 `<leader>f` 下面的按键归到"查找"组。

### 分组注册方式

```lua
-- 方式 1：直接注册分组（推荐）
vim.keymap.set("n", "<leader>f", "", { desc = "+查找" })
vim.keymap.set("n", "<leader>g", "", { desc = "+Git" })
vim.keymap.set("n", "<leader>d", "", { desc = "+调试" })

-- 方式 2：用 which-key 的 register API（如果 which-key 已加载）
local ok, wk = pcall(require, "which-key")
if ok then
  wk.register({
    ["<leader>f"] = { name = "+查找" },
    ["<leader>g"] = { name = "+Git" },
    ["<leader>d"] = { name = "+调试" },
  })
end
```

**方式 1 更简单**——注册一个空的 keymap 带 desc，which-key 会自动识别为分组。
`+` 前缀是 which-key 的约定，表示这是一个分组名。

### LazyVim 默认分组

LazyVim 已经注册了这些分组：

| 前缀 | 分组名 | 说明 |
|------|--------|------|
| `<leader>f` | +查找 | Telescope 相关 |
| `<leader>g` | +Git | Git 操作 |
| `<leader>d` | +调试 | DAP 调试 |
| `<leader>c` | +代码 | LSP 代码操作 |
| `<leader>x` | +诊断 | 诊断/快速修复 |
| `<leader>s` | +搜索 | Telescope 搜索 |
| `<leader>b` | +Buffer | Buffer 操作 |
| `<leader>w` | +窗口 | 窗口操作 |
| `<leader>u` | +UI | UI 切换 |

你可以追加自己的分组：

```lua
-- 追加自定义分组
vim.keymap.set("n", "<leader>m", "", { desc = "+Markdown" })
vim.keymap.set("n", "<leader>p", "", { desc = "+项目" })
```

---

## lua/config/keymaps.lua

LazyVim 会在启动时自动加载 `lua/config/keymaps.lua`。
这是你放全局快捷键的地方。

### 文件结构

```lua
-- ~/.config/nvim/lua/config/keymaps.lua
-- LazyVim 会自动加载这个文件（在默认 keymaps 之后）
-- 你可以在这里：新增、覆盖、删除快捷键

-- ============================================================================
-- 1. 新增快捷键
-- ============================================================================

-- 快速保存
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "保存文件" })

-- 快速退出
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "退出" })

-- 清除搜索高亮
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "清除搜索高亮" })

-- ============================================================================
-- 2. 覆盖 LazyVim 默认快捷键
-- ============================================================================

-- 把 <leader>ff 从 find_files 改为 oldfiles
vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").oldfiles()
end, { desc = "最近文件" })

-- ============================================================================
-- 3. 删除不需要的默认快捷键
-- ============================================================================

-- 删除 <leader>/（全局搜索，如果你不需要）
-- vim.keymap.del("n", "<leader>/")

-- ============================================================================
-- 4. 自定义函数绑定
-- ============================================================================

-- 复制文件路径到剪贴板
vim.keymap.set("n", "<leader>fp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("已复制: " .. path)
end, { desc = "复制文件路径" })

-- 快速编辑配置文件
vim.keymap.set("n", "<leader>vc", function()
  vim.cmd("edit " .. vim.fn.stdpath("config") .. "/lua/config/keymaps.lua")
end, { desc = "编辑快捷键配置" })
```

### keymaps.lua 的加载时机

```
Neovim 启动
  ↓
加载 lua/config/options.lua（第 03 章）
  ↓
加载 lua/config/keymaps.lua ← 你的全局快捷键
  ↓
加载 lua/config/autocmds.lua（本章后面讲）
  ↓
加载 lazy.nvim → 加载插件 spec → 插件的 keys 字段生效
```

**注意**：你的 keymaps.lua 在插件加载**之前**执行。
所以如果你想绑定插件的 API，需要用 `vim.keymap.set` 的 function 形式（懒加载）：

```lua
-- ✅ 正确：function 形式，telescope 加载后才调用
vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "查找文件" })

-- ❌ 错误：顶层 require，telescope 还没加载就报错
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "查找文件" })
```

---

## lua/config/autocmds.lua

LazyVim 会自动加载 `lua/config/autocmds.lua`。
这是你放自动命令的地方。

### vim.api.nvim_create_autocmd 详解

```lua
vim.api.nvim_create_autocmd(event, opts)
```

| 参数 | 类型 | 说明 |
|------|------|------|
| `event` | string \| table | 事件名：`"BufReadPost"`、`"BufWritePre"`、`"InsertEnter"` 等 |
| `opts` | table | 选项：`pattern`、`callback`、`group`、`desc` 等 |

### opts 选项

| 选项 | 类型 | 说明 |
|------|------|------|
| `pattern` | string \| table | 文件匹配模式：`"*"`(所有)、`"*.lua"`(Lua 文件)、`"*.py"`(Python) |
| `callback` | function | 触发时执行的函数（可以接收 event 参数） |
| `command` | string | 触发时执行的 Ex 命令（和 callback 二选一） |
| `group` | number | 自动命令组（用 nvim_create_augroup 创建） |
| `desc` | string | 描述（`:autocmd` 列表会显示） |
| `once` | bool | 是否只触发一次（默认 false） |
| `buffer` | number | 是否只对指定 buffer 生效（buffer-local） |

### 常用事件

| 事件 | 触发时机 | 典型用途 |
|------|----------|----------|
| `BufReadPost` | 打开文件后 | 恢复光标位置、加载额外配置 |
| `BufNewFile` | 创建新文件 | 模板插入、设置文件头 |
| `BufWritePre` | 保存前 | 自动格式化、删除尾部空格 |
| `BufWritePost` | 保存后 | 重新加载配置、运行 linter |
| `InsertEnter` | 进入插入模式 | 切换输入法、显示补全 |
| `InsertLeave` | 离开插入模式 | 隐藏补全、保存临时文件 |
| `TextYankPost` | 复制后 | 高亮复制区域 |
| `VimResized` | 窗口大小变化 | 重新排列窗口 |
| `FileType` | 文件类型检测后 | 设置特定文件类型的选项 |
| `LspAttach` | LSP 附加到 buffer | 设置 LSP 相关快捷键 |

### autocmds.lua 示例

```lua
-- ~/.config/nvim/lua/config/autocmds.lua
-- LazyVim 会自动加载这个文件

-- ============================================================================
-- 1. 创建自动命令组（避免重复注册）
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- ============================================================================
-- 2. 保存时自动删除尾部空格
-- ============================================================================

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  pattern = "*",
  desc = "保存时删除尾部空格",
  callback = function()
    -- 保存光标位置
    local save_cursor = vim.fn.getpos(".")
    -- 删除尾部空格
    vim.cmd([[%s/\s\+$//e]])
    -- 恢复光标位置
    vim.fn.setpos(".", save_cursor)
  end,
})

-- ============================================================================
-- 3. 打开文件时恢复光标到上次位置
-- ============================================================================

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  pattern = "*",
  desc = "恢复光标到上次位置",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ============================================================================
-- 4. 高亮复制区域（短暂闪烁）
-- ============================================================================

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  pattern = "*",
  desc = "高亮复制区域",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- ============================================================================
-- 5. 特定文件类型设置
-- ============================================================================

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "lua", "python", "javascript", "typescript" },
  desc = "设置缩进为 2 空格（Lua/JS/TS）或 4 空格（Python）",
  callback = function()
    local ft = vim.bo.filetype
    if ft == "python" then
      vim.bo.tabstop = 4
      vim.bo.shiftwidth = 4
    else
      vim.bo.tabstop = 2
      vim.bo.shiftwidth = 2
    end
  end,
})

-- ============================================================================
-- 6. 保存前自动格式化（如果 LSP 可用）
-- ============================================================================

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  pattern = { "*.lua", "*.py", "*.js", "*.ts", "*.go", "*.rs" },
  desc = "保存前自动格式化",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
```

### vim.api.nvim_create_augroup

自动命令组的作用：
1. **避免重复注册**——每次 Neovim 重新加载配置时，`clear = true` 会清空组内所有旧命令
2. **批量管理**——可以一次性删除组内所有命令

```lua
-- 创建组（clear = true 表示重新加载时清空旧命令）
local augroup = vim.api.nvim_create_augroup("MyGroup", { clear = true })

-- 所有命令都归到这个组
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  -- ...
})

-- 删除整个组的所有命令
vim.api.nvim_del_augroup_by_name("MyGroup")
```

---

## buffer-local 快捷键

有些快捷键只对特定 buffer 生效（比如只在 Markdown 文件里绑定预览键）。

### 基本用法

```lua
-- 只对当前 buffer 生效
vim.keymap.set("n", "<leader>p", function()
  print("预览当前文件")
end, {
  desc = "预览",
  buffer = true,  -- ← 关键：buffer-local
})

-- 对指定 buffer 号生效
vim.keymap.set("n", "<leader>p", function()
  print("预览")
end, {
  desc = "预览",
  buffer = 5,  -- ← 指定 buffer 号
})
```

### 结合 autocmd 使用

最常见的用法是在 `LspAttach` 或 `FileType` 事件里绑定 buffer-local 快捷键：

```lua
-- LSP 附加到 buffer 时，绑定 LSP 相关快捷键
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  desc = "LSP 快捷键",
  callback = function(event)
    local buf = event.buf

    -- 只对当前 buffer 生效的快捷键
    vim.keymap.set("n", "gd", function()
      vim.lsp.buf.definition()
    end, { desc = "跳转到定义", buffer = buf })

    vim.keymap.set("n", "gr", function()
      vim.lsp.buf.references()
    end, { desc = "查找引用", buffer = buf })

    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover()
    end, { desc = "悬停文档", buffer = buf })

    vim.keymap.set("n", "<leader>ca", function()
      vim.lsp.buf.code_action()
    end, { desc = "代码操作", buffer = buf })
  end,
})
```

### buffer-local vs 全局

| 类型 | 生效范围 | 适用场景 |
|------|----------|----------|
| 全局（默认） | 所有 buffer | 通用快捷键（保存、退出、搜索） |
| buffer-local | 单个 buffer | 特定文件类型的快捷键（LSP、Markdown 预览） |

---

## 反模式：什么不该做

### ❌ 用 vim.api.nvim_set_keymap 代替 vim.keymap.set

```lua
-- ❌ 坏：nvim_set_keymap 已被弃用
vim.api.nvim_set_keymap("n", "<leader>x", ":echo 'hi'<CR>", { noremap = true, silent = true })

-- ✅ 正确：用 vim.keymap.set
vim.keymap.set("n", "<leader>x", function() print("hi") end, { desc = "打招呼" })
```

### ❌ 用 LazyVim.safe_keymap_set

```lua
-- ❌ 坏：safe_keymap_set 是 LazyVim 内部 API，不在公开文档里
LazyVim.safe_keymap_set("n", "<leader>x", function() ... end)

-- ✅ 正确：用 vim.keymap.set（Neovim 原生 API，稳定、有文档）
vim.keymap.set("n", "<leader>x", function() ... end, { desc = "..." })
```

### ❌ 不写 desc

```lua
-- ❌ 坏：which-key 只显示按键，不显示功能
vim.keymap.set("n", "<leader>x", function() some_action() end)

-- ✅ 正确：带 desc
vim.keymap.set("n", "<leader>x", function() some_action() end, { desc = "执行某操作" })
```

### ❌ 在顶层 require 插件

```lua
-- ❌ 坏：插件可能还没加载
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "查找文件" })

-- ✅ 正确：用 function 形式（懒加载）
vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "查找文件" })
```

### ❌ 不用 augroup 管理自动命令

```lua
-- ❌ 坏：每次重新加载配置都会追加一个新的 autocmd，导致重复执行
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function() vim.cmd("%s/\\s\\+$//e") end,
})

-- ✅ 正确：用 augroup + clear = true
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  pattern = "*",
  callback = function() vim.cmd("%s/\\s\\+$//e") end,
})
```

---

## 运行验证

本章的 Lua 文件验证：

```bash
cd lazyvim/18-custom-keymaps

# 验证 init.lua
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

# 验证 keymaps.lua
nvim --headless -u NONE -c "luafile lua/config/keymaps.lua" -c 'qa!'

# 验证 autocmds.lua
nvim --headless -u NONE -c "luafile lua/config/autocmds.lua" -c 'qa!'
```

预期：退出码 0，无错误。

---

## 下一步

你已经掌握了 Neovim 的两大配置原语：**快捷键** 和 **自动命令**。

- **第 19 章「Extras 系统」**：LazyVim 的 Extras 是什么、怎么启用、怎么写自己的 Extra
- **第 20 章「性能优化」**：保持配置健康、启动飞快

> 💡 **本章核心**：记住三个要点——
> 1. 用 `vim.keymap.set`（不是 `nvim_set_keymap` 或 `safe_keymap_set`）
> 2. 永远带 `desc`（which-key 需要它）
> 3. 自动命令用 `augroup` 管理（避免重复注册）

---

## 代码

- [`lua/init.lua`](./lua/init.lua) — bootstrap 教学（pcall 保护）
- [`lua/config/keymaps.lua`](./lua/config/keymaps.lua) — 全局快捷键示例
- [`lua/config/autocmds.lua`](./lua/config/autocmds.lua) — 自动命令示例
- [`exercises/`](./exercises/README.md) — 5 道练习题

**上一章**：[17-plugin-patterns](../17-plugin-patterns/)（插件配置模式）
**下一章**：[19-extras](../19-extras/)（Extras 系统）
