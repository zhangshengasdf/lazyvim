# 第09章 Telescope 模糊搜索 — 搜索一切的瑞士军刀

> **Telescope 是你按得最多的插件**——找文件、搜代码、切 buffer、查帮助，
> 全部通过 `<leader>` 前缀的几个键搞定。
> 本章拆解 Telescope 的核心 picker、keys 懒加载模式、fzf-native 扩展，
> 学完后你不再需要 `find` 命令或文件管理器来找文件。

---

## TL;DR

> **30 秒速读**：`<leader>ff` 搜文件名、`<leader>sg` 搜文件内容、`<leader>fb` 切 buffer、`<leader>fr` 最近文件、`<leader>ss` LSP 符号——五个键覆盖 90% 搜索场景。Telescope 用 `keys` 懒加载，按键才加载。
> 
> **如果只记一件事**：自定义 Telescope 配置时用 `opts = function(_, opts) ... end` 扩展默认值，用 `opts = {...}` 会把 LazyVim 的布局和 picker 设置全部覆盖。

---

## 本章目标

学完本章，你将能够：

1. **熟练使用 5 个核心 picker**：`<leader>ff` 找文件、`<leader>sg` 全文搜索、`<leader>fb` 切 buffer、`<leader>fr` 最近文件、`<leader>ss` LSP 符号
2. **理解 keys 懒加载**：为什么 Telescope 不在启动时加载、keys 字段的工作原理
3. **配置 fzf-native 扩展**：C 实现的 fzf 排序算法，搜索结果更精准
4. **自定义 Telescope**：修改布局、过滤规则、picker 选项
5. **掌握 extend 模式**：用 `opts = function` 扩展 LazyVim 的默认配置

> ⚠️ **前置条件**：完成第 06 章（理解 lazy.nvim spec 和懒加载策略）和第 07 章（理解 Leader 键体系）。
> 本章是 Part 2「核心工作流」的第三章——搜索是日常开发中最频繁的操作。

---

## 为什么需要 Telescope

用 `:!find . -name "*.lua"` 找文件？用 `:grep pattern` 搜代码？
这些命令能用，但体验很差：

- **没有预览**：找到文件名但看不到内容
- **没有模糊匹配**：必须精确输入文件名
- **没有实时反馈**：输完命令才知道结果
- **没有快捷键**：每次都要打完整命令

Telescope 把这些全解决了。一个浮窗，左边是结果列表，右边是文件预览，
输入几个字母就能模糊匹配，按 `<CR>` 直接打开。

---

## 5 个核心 picker

Telescope 的每个搜索功能叫一个 picker。LazyVim 默认绑定了这些快捷键：

### `<leader>ff` — 查找文件

```
按 <leader>ff → 弹出浮窗 → 输入文件名（模糊匹配）→ <CR> 打开
```

这是你用得最多的键。它在当前项目目录下搜索所有文件名，
支持模糊匹配：输入 `tlc` 可以匹配 `telescope.lua`。

**实用技巧**：
- 输入 `!node_modules` 排除目录（`!` 前缀表示排除）
- 输入 `*.lua` 只看 Lua 文件（`*` 是通配符）
- 按 `<C-u>` 清空输入框
- 按 `<C-d>` 删除光标前的单词

### `<leader>sg` — 全文搜索（live_grep）

```
按 <leader>sg → 弹出浮窗 → 输入搜索词（实时搜索）→ <CR> 打开文件并定位到匹配行
```

用 `ripgrep`（rg）在项目里全文搜索。和 `<leader>ff` 的区别：
- `<leader>ff` 搜文件名
- `<leader>sg` 搜文件内容

**实用技巧**：
- 输入即搜索，不需要按回车
- 支持正则表达式：`function\s+\w+` 搜函数定义
- 按 `<C-f>` 切换到 grep 命令模式（可以传额外参数）

### `<leader>fb` — 切换缓冲区

```
按 <leader>fb → 显示所有打开的缓冲区 → 输入名称过滤 → <CR> 切换到该 buffer
```

比 `:b <Tab>` 好用太多。模糊匹配 buffer 名称，带预览。

### `<leader>fr` — 最近文件（oldfiles）

```
按 <leader>fr → 显示最近打开的文件列表 → 输入名称过滤 → <CR> 打开
```

读取 Neovim 的 `v:oldfiles` 列表，显示你之前打开过的文件。
关闭 Neovim 后重新打开，之前的文件记录还在。

### `<leader>ss` — LSP 文档符号

```
按 <leader>ss → 显示当前文件的所有函数/类/变量 → 输入名称过滤 → <CR> 跳转到定义
```

需要 LSP 已经启动（第 12 章详解）。它列出当前文件的所有符号：
函数、类、变量、方法。输入 `setup` 就能快速跳转到 `setup()` 函数。

> 💡 **`<leader>ss` 依赖 LSP**。如果还没装 LSP，这个键会显示"没有结果"。
> 先完成第 12 章（LSP + Mason）后，这个键就活了。

---

## Telescope 窗口操作

在 Telescope 浮窗里，你可以用这些快捷键：

| 快捷键 | 作用 |
|--------|------|
| `<CR>` | 打开选中的文件（在当前窗口） |
| `<C-x>` | 水平分割打开 |
| `<C-v>` | 垂直分割打开 |
| `<C-t>` | 在新标签页打开 |
| `<C-u>` | 清空输入框 |
| `<C-d>` | 删除光标前的单词 |
| `<C-f>` | 切换到 grep 命令模式 |
| `<C-n>` | 下一个结果 |
| `<C-p>` | 上一个结果 |
| `<Esc>` | 关闭浮窗（Normal 模式下） |
| `<C-c>` | 关闭浮窗（任何模式下） |

> 💡 **`<C-x>` 和 `<C-v>` 很实用**——你可能想在搜索结果旁边同时看两个文件，
> 用 `<C-v>` 垂直分割打开，不用退出搜索。

---

## keys 懒加载模式详解

Telescope 是典型的"命令式工具"——你不搜东西时它完全没用。
所以 LazyVim 用 `keys` 懒加载：Neovim 启动时不加载 Telescope，
只有你按下 `<leader>ff` 等键时，lazy.nvim 才加载它。

### 为什么不用 event 懒加载？

```
event = "BufReadPost"  →  每次打开文件都加载（浪费）
keys = { "<leader>ff" } →  只有按键时才加载（精确）
```

Telescope 不需要"每次打开文件时就绪"，它只在你主动搜索时才需要。
用 `keys` 比 `event` 更省资源。

### keys 字段的工作原理

```lua
keys = {
  { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件" },
  { "<leader>sg", "<cmd>Telescope live_grep<CR>",  desc = "全文搜索" },
}
```

当你按下 `<leader>ff` 时，lazy.nvim 做了三件事：
1. 检测到 Telescope 还没加载
2. 加载 Telescope（执行 setup、load_extension）
3. 执行 `<cmd>Telescope find_files<CR>`（打开 find_files picker）

整个过程在 100ms 内完成，你感觉不到延迟。

### LazyVim 默认的 Telescope keys

LazyVim 为 Telescope 定义了这些快捷键（部分）：

| 快捷键 | Picker | 说明 |
|--------|--------|------|
| `<leader>ff` | find_files | 查找文件 |
| `<leader>fg` | live_grep | 全文搜索 |
| `<leader>fb` | buffers | 切换缓冲区 |
| `<leader>fr` | oldfiles | 最近文件 |
| `<leader>fh` | help_tags | 查帮助 |
| `<leader>fw` | grep_string | 搜光标下的单词 |
| `<leader>fd` | diagnostics | 诊断列表 |
| `<leader>fs` | lsp_document_symbols | 文档符号 |
| `<leader>ss` | lsp_document_symbols | 文档符号（别名） |
| `<leader>sS` | lsp_workspace_symbols | 工作区符号 |
| `<leader>sg` | live_grep | 全文搜索 |
| `<leader>sw` | grep_string | 搜选中的文本 |
| `<leader>sd` | diagnostics | 诊断列表 |
| `<leader>s.` | resume | 继续上次搜索 |
| `<leader>sr` | resume | 继续上次搜索（别名） |
| `<leader>,` | buffers | 切换缓冲区 |

> 💡 **`<leader>s` 前缀是搜索组**。按 `<leader>s` 等 0.5 秒，which-key 会显示所有搜索相关快捷键。
> `<leader>f` 前缀也有几个常用 picker。两者有重叠，用哪个都行。

---

## fzf-native 扩展

Telescope 默认用 Lua 实现的排序算法。`telescope-fzf-native.nvim` 是 C 实现的 fzf 排序算法，速度更快、匹配更准。

### 为什么需要 fzf-native

| 排序器 | 语言 | 速度 | 匹配质量 |
|--------|------|------|----------|
| 默认排序器 | Lua | 一般 | 基础模糊匹配 |
| fzf-native | C | 快 10 倍 | fzf 算法（和 fzf 命令行工具一样） |

fzf-native 的匹配算法和 `fzf` 命令行工具一样：
- 支持连续字符匹配（`tlc` 匹配 `telescope` 的 `t`-`l`-`c`）
- 支持大小写智能匹配（全小写时忽略大小写）
- 支持路径匹配（`src/ts` 匹配 `src/typescript`）

### LazyVim 的 fzf-native 配置

LazyVim 默认安装并配置了 fzf-native。你不需要手动配置。
但如果你想知道它是怎么工作的：

```lua
-- LazyVim 的 Telescope spec（简化版）
{
  "nvim-telescope/telescope.nvim",
  dependencies = {
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",  -- 安装后编译 C 代码
      cond = function()
        return vim.fn.executable("make") == 1  -- 有 make 才装
      end,
    },
  },
  config = function(_, opts)
    require("telescope").setup(opts)
    pcall(require("telescope").load_extension, "fzf")  -- pcall 保护
  end,
}
```

> 💡 **`pcall` 保护很重要**。如果 fzf-native 没编译成功（比如没装 C 编译器），
> `pcall` 让它静默失败，不会报错。Telescope 会回退到默认排序器。

---

## 自定义 Telescope

### 修改布局

```lua
-- 在 lua/plugins/telescope.lua 里
opts = function(_, opts)
  opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
    -- 布局策略：vertical（上下排列）/ horizontal（左右排列）/ center
    layout_strategy = "vertical",
    layout_config = {
      vertical = {
        prompt_position = "top",    -- 输入框在顶部
        preview_height = 0.5,      -- 预览占一半高度
      },
      width = 0.9,                 -- 浮窗宽度占 90%
      height = 0.9,                -- 浮窗高度占 90%
    },
  })
end,
```

### 修改文件忽略规则

```lua
opts = function(_, opts)
  opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
    file_ignore_patterns = {
      "node_modules",
      ".git/",
      "dist/",
      "build/",
      "%.lock",       -- 锁文件
      "%.min%.js",    -- 压缩后的 JS
    },
  })
end,
```

### 修改 find_files 的搜索命令

```lua
opts = function(_, opts)
  opts.pickers = vim.tbl_deep_extend("force", opts.pickers or {}, {
    find_files = {
      -- 默认用 fd（快），也可以用 find
      find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
      -- 如果想搜隐藏文件：
      -- find_command = { "fd", "--type", "f", "--hidden", "--strip-cwd-prefix" },
    },
  })
end,
```

---

## 反模式（什么不该做）

### ❌ 用 `opts = {...}` 覆盖 Telescope 的 defaults

```lua
-- ❌ 坏：覆盖了 LazyVim 的所有默认 defaults
opts = {
  defaults = {
    layout_strategy = "vertical",
  },
}

-- ✅ 正确：用 function extend
opts = function(_, opts)
  opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
    layout_strategy = "vertical",
  })
end,
```

### ❌ 用 `event = "BufReadPost"` 加载 Telescope

```lua
-- ❌ 坏：每次打开文件都加载 Telescope（浪费启动时间）
event = "BufReadPost",

-- ✅ 正确：用 keys 懒加载（按键才加载）
keys = { "<leader>ff", "<leader>sg" },
```

### ❌ 不带 desc 的 keys

```lua
-- ❌ 坏：which-key 只显示按键不显示功能
keys = { "<leader>ff", "<leader>sg" }

-- ✅ 正确：用 table 形式带 desc
keys = {
  { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件" },
  { "<leader>sg", "<cmd>Telescope live_grep<CR>",  desc = "全文搜索" },
}
```

### ❌ 手动 require telescope（不走 lazy.nvim）

```lua
-- ❌ 坏：在配置文件里直接 require（绕过懒加载）
local telescope = require("telescope")
telescope.setup({})

-- ✅ 正确：让 lazy.nvim 管理加载（通过 keys 或 event 触发）
```

### ❌ 不装 ripgrep 就用 live_grep

```
# ripgrep 是 <leader>sg（live_grep）的依赖
# 没有 ripgrep，按 <leader>sg 会报错

# 安装：
# macOS: brew install ripgrep
# Ubuntu: sudo apt install ripgrep
```

---

## 常见错误

> 概念懂了，实际操作还是会踩坑。

| 错误 | 症状 | 解决 |
|------|------|------|
| 用 `opts = {...}` 覆盖 Telescope defaults | 布局变成默认样式，LazyVim 的 horizontal 策略丢失 | 改成 `opts = function(_, opts) opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {...}) end` |
| 没装 ripgrep 就按 `<leader>sg` | live_grep 报错 `rg: command not found` | macOS: `brew install ripgrep`；Ubuntu: `sudo apt install ripgrep` |
| 用 `event = "BufReadPost"` 替代 `keys` 加载 Telescope | 每次打开文件都加载 Telescope，启动时间增加 15ms+ | 改回 `keys = { "<leader>ff", "<leader>sg" }`，按键才加载 |
| 手动 `require("telescope")` 绕过 lazy.nvim | 配置被 lazy.nvim 的 spec 覆盖，你的修改不生效 | 让 lazy.nvim 管理加载，通过 `opts` 或 `config` 传配置 |

---

## 运行验证

本章的 Lua 文件验证语法：

```bash
cd lazyvim/09-telescope

# 验证 init.lua（pcall 保护，没有 Telescope 也能通过）
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

# 验证 telescope.lua（return { ... } 形式，直接 luafile 不会报错）
nvim --headless -u NONE -c "luafile lua/plugins/telescope.lua" -c 'qa!'
```

预期：退出码 0，无错误。

> 💡 **真实环境验证**：如果你装了 LazyVim，把 `lua/plugins/telescope.lua` 复制到
> `~/.config/nvim/lua/plugins/` 下，运行 `:Lazy sync`，然后按 `<leader>ff` 测试。

---

## 下一步

Telescope 解决了"搜索"的问题。接下来的 **第 10 章「Neo-tree」** 解决"浏览"的问题：

- **文件树**：目录结构一目了然
- **文件操作**：创建、删除、重命名、移动文件
- **bufferline**：标签页管理
- **dashboard**：启动页快捷入口

搜索 + 浏览 = 你在项目里导航的两个核心能力。有了它们，你不再需要鼠标。

> 💡 **本章核心**：记住 5 个键——`<leader>ff`（文件）、`<leader>sg`（内容）、`<leader>fb`（buffer）、`<leader>fr`（最近）、`<leader>ss`（符号）。
> 它们覆盖了 90% 的搜索场景。

---

## 代码

- [`lua/init.lua`](./lua/init.lua) — Telescope 配置演示（pcall 保护）
- [`lua/plugins/telescope.lua`](./lua/plugins/telescope.lua) — Telescope spec（keys 懒加载 + opts extend）
- [`exercises/`](./exercises/README.md) — 4 道练习题（picker 选择、keys 懒加载、fzf 扩展、自定义配置）

**上一章**：[08-which-key](../08-which-key/)（快捷键提示）
**下一章**：[10-neo-tree](../10-neo-tree/)（文件管理器）
