# 第05章 配置目录架构 — `lua/config/` 与 `lua/plugins/` 的合并语义

> **LazyVim 不是黑盒，它是一套"约定优于配置"的契约**——你把文件放到约定位置，
> 它就自动加载。本章拆解这套契约：`lua/config/` 四个文件各干什么、
> `lua/plugins/` 的 spec 如何与 LazyVim 默认 spec **合并**、`lazy-lock.json` 怎么管理版本。
> 学完本章，你打开任何 LazyVim 用户的 `~/.config/nvim/` 都能一眼看懂他的配置。

---

## TL;DR

> **30 秒速读**：`lua/config/` 放选项/快捷键/自动命令（自动 source），`lua/plugins/` 放插件 spec（必须 return table），两者都用 `opts = function` 扩展默认配置。
> 
> **如果只记一件事**：扩展列表型配置用 `opts = function(_, opts) vim.list_extend(opts.X, {...}) end`，不要直接覆盖。

## 本章目标

学完本章，你将能够：

1. **区分 `lua/config/` 和 `lua/plugins/`**：知道什么内容该放哪个目录
2. **说清四个 config 文件**：`options.lua`、`keymaps.lua`、`autocmds.lua`、`lazy.lua` 各自的职责
3. **理解自动加载机制**：LazyVim 如何 source `config/` 目录、收集 `plugins/` 目录的 spec
4. **掌握合并语义**（核心概念）：你的 spec 与 LazyVim 默认 spec 如何 merge
5. **管理 `lazy-lock.json`**：版本锁定文件的用途、`.gitignore` 策略

> ⚠️ **前置条件**：完成第 04 章（LazyVim 已装好，知道目录结构概览）。
> 本章是 Part 1 的"骨架理解"核心，第 06 章（lazy.nvim spec 格式）依赖本章的合并语义。

---

## `lua/config/` 四个文件详解

LazyVim 约定：`~/.config/nvim/lua/config/` 下的这四个文件会被**自动 source**（按固定顺序）：

### 1. `options.lua` — vim 选项

放 `vim.opt.X = value` 或 `vim.o.X = value` 语句。这是"Neovim 本身的设置"——
行号、缩进、编码、配色等。

```lua
-- lua/config/options.lua
vim.opt.number = true           -- 显示行号
vim.opt.relativenumber = true   -- 相对行号
vim.opt.tabstop = 2             -- Tab 显示为 2 空格
vim.opt.shiftwidth = 2          -- 自动缩进每级 2 空格
vim.opt.expandtab = true        -- Tab 转空格
vim.opt.termguicolors = true    -- 启用真彩色
vim.g.mapleader = " "           -- Leader 键设为空格
```

> 💡 **`vim.opt` vs `vim.o` vs `vim.g`**：
> - `vim.opt.X` — 设置选项（带类型检查，推荐）
> - `vim.o.X` — 直接访问选项（字符串/数字/布尔）
> - `vim.g.X` — 全局变量（如 `vim.g.mapleader`）
> 一般用 `vim.opt` 即可，`vim.g` 只用于全局变量（leader、colorscheme 等）。

### 2. `keymaps.lua` — 快捷键

放 `vim.keymap.set(mode, lhs, rhs, opts)` 语句。**用 `vim.keymap.set`**，
不要用已弃用的 `vim.api.nvim_set_keymap`，更不要用内部 API `LazyVim.safe_keymap_set`。

```lua
-- lua/config/keymaps.lua
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "保存文件" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "退出" })
vim.keymap.set("n", "<leader>nh", ":nohlsearch<CR>", { desc = "清除高亮" })

-- 带 desc 的 keymap 会被 which-key 自动拾取（第 08 章详解）
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { desc = "新标签页" })
```

> ⚠️ **反模式**：用 `vim.keymap.set` 时**始终带 `desc` 字段**。不带 desc 的 keymap
> 在 which-key 里只会显示按键，不显示功能描述，等于没用。

### 3. `autocmds.lua` — 自动命令

放 `vim.api.nvim_create_autocmd(event, opts)` 语句。autocmd 是"事件触发器"——
打开某类文件、进入某种模式时自动执行的代码。

```lua
-- lua/config/autocmds.lua

-- 打开 YAML 文件时自动设 2 空格缩进
vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
  desc = "YAML 文件用 2 空格缩进",
})

-- 进入 insert 模式时禁用相对行号，退出时恢复
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    vim.opt.relativenumber = false
  end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    vim.opt.relativenumber = true
  end,
})
```

### 4. `lazy.lua` — lazy.nvim setup 配置（可选）

这个文件**不常见**——大多数时候你不需要它。它的作用是覆盖 `init.lua` 里
`require("lazy").setup({...})` 的配置。如果你不创建 `lazy.lua`，LazyVim 用 `init.lua` 的默认配置。

**什么时候用 `lazy.lua`**：当你想改 lazy.nvim 的 `install`、`checker`、`performance` 等全局行为，
但不想动 `init.lua`（保持 starter 的 `init.lua` 不变，方便升级）。

```lua
-- lua/config/lazy.lua（可选，大多数人不写）
return {
  -- 等价于 init.lua 里 require("lazy").setup({...}) 的参数
  install = { colorscheme = { "catppuccin", "habamax" } },
  checker = { enabled = true, notify = true },  -- 改成有更新通知
}
```

### 四个文件的加载顺序

LazyVim 在启动时按以下顺序 source 这四个文件（顺序很重要）：

```
1. options.lua    ← 先设选项（其他文件可能依赖某些选项）
2. keymaps.lua    ← 再设快捷键（依赖 leader 键已设好）
3. autocmds.lua   ← 再注册 autocmd（依赖选项和键位就绪）
4. lazy.lua       ← 最后配置 lazy.nvim（覆盖 init.lua 的 setup）
```

---

## `lua/plugins/` 目录 — spec 文件

### 每个 `.lua` 文件返回一个 spec table

`lua/plugins/` 下的每个 `.lua` 文件**必须返回一个 table**（或 table 列表）。
这个 table 就是 lazy.nvim 的 **spec**（插件规格）。第 06 章详解 spec 格式，这里先看结构：

```lua
-- lua/plugins/example.lua
return {
  -- 一个 spec table
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        layout_strategy = "horizontal",
      },
    },
  },
}
```

也可以返回多个 spec（列表）：

```lua
-- lua/plugins/multiple.lua
return {
  { "folke/todo-comments.nvim", opts = {} },
  { "tpope/vim-fugitive",       cmd = { "Git", "G" } },
  { "kdheepak/lazygit.nvim",    cmd = "LazyGit" },
}
```

### 文件命名约定

文件名**任意**——lazy.nvim 会收集 `lua/plugins/` 下所有 `.lua` 文件。
但社区约定按插件名或功能命名：

```
lua/plugins/
├── telescope.lua       ← 望远镜（模糊搜索）
├── neo-tree.lua        ← 文件树
├── lsp.lua             ← LSP 相关
├── completion.lua      ← 补全相关
├── git.lua             ← Git 集成
└── formatting.lua      ← 格式化
```

> 💡 **每个插件一个文件** 比把所有 spec 塞进一个 `init.lua` 更好维护。
> 你删某个插件时，直接删对应文件即可，不用在大文件里找。

---

## 自动加载机制 — LazyVim 如何 source 这两个目录

LazyVim 在 `require("lazy").setup` 的 spec 里加了这样两行（第 04 章的 `init.lua`）：

```lua
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },  -- LazyVim 默认插件
    { import = "plugins" },                               -- 你的插件
  },
})
```

`{ import = "plugins" }` 是 lazy.nvim 的**目录导入**语法——
它会扫描 `lua/plugins/` 下所有 `.lua` 文件，把每个文件 `return` 的 table 收集成 spec 列表。

**那 `lua/config/` 呢？** LazyVim 本体（`lazyvim.plugins` 里）定义了一个特殊 spec，
在启动时 source 你的 `config/` 目录：

```lua
-- 简化版 LazyVim 内部逻辑（你不需要写这个）
{
  "LazyVim/LazyVim",
  opts = function()
    -- 扫描 lua/config/options.lua、keymaps.lua、autocmds.lua、lazy.lua
    -- 如果存在就 source
  end,
}
```

所以 `lua/config/` 是 LazyVim 的**约定**（convention）——你不写就不会加载，写了就自动 source。

---

## 合并语义（核心概念）— 你的 spec 与 LazyVim 默认 spec 如何 merge

这是本章最重要的小节，也是新手最容易踩坑的地方。

### 问题背景

LazyVim 已经为每个内置插件定义了 spec（比如 Telescope、LSP、Treesitter）。
你想定制这些插件时，**不是覆盖** LazyVim 的 spec，而是**合并**（merge）。

### merge 规则

lazy.nvim 按插件 URL（或 short url）匹配 spec，然后**深度合并**：

| 字段类型 | 合并策略 |
|----------|----------|
| `opts`（table） | **深度合并**：你的 opts 和默认 opts 递归合并，同名 key 你的覆盖默认的 |
| `opts`（function） | 你的 function 接收默认 opts，可以修改后返回（**extend 模式**） |
| `keys`（table） | **列表追加**：你的 keys 追加到默认 keys 后面 |
| `cmd`/`event`/`ft`（table） | **列表追加**：同上 |
| `config`（function） | **覆盖**：你的 config 完全替换默认的（慎用！） |
| `enabled`（bool） | **覆盖**：可以禁用 LazyVim 默认插件 |
| `priority`/`lazy`/`tag` 等 | **覆盖**：你的值替换默认的 |

### ❌ 反模式：覆盖列表型字段（最常见错误）

```lua
-- ❌ 坏：直接覆盖 ensure_installed 列表
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "lua", "vim", "vimdoc" },  -- 覆盖了 LazyVim 默认列表！
    },
  },
}
```

**后果**：LazyVim 默认会装 `bash`、`c`、`css`、`html`、`javascript`... 等十几种解析器，
你的配置把 `ensure_installed` **整体覆盖**成只有 3 种——LazyVim 默认的那些全没了。

### ✅ 正确模式：extend 列表型字段

```lua
-- ✅ 正确：用 opts = function 接收默认 opts，再 extend
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- opts 是 LazyVim 默认的 opts（已经包含 ensure_installed 列表）
      -- vim.list_extend 把你的列表追加到默认列表后面
      vim.list_extend(opts.ensure_installed, {
        "lua",
        "vim",
        "vimdoc",
      })
      -- 不需要 return，function 直接修改 opts（引用传递）
    end,
  },
}
```

**关键点**：
- `opts = function(_, opts) ... end` 接收两个参数：`(plugin_spec, default_opts)`
- 第一个参数用 `_` 表示"不用"（Lua 约定）
- `default_opts` 是 LazyVim 默认的 opts table，**引用传递**——你直接修改它
- `vim.list_extend(target, source)` 把 source 列表的元素追加到 target 后面
- **不需要 `return`**（修改引用即生效）

> 💡 **什么时候用 table vs function**：
> - `opts = { ... }`：你想**设置全新的、与默认无关的**选项（比如默认没有的字段）
> - `opts = function(_, opts) vim.list_extend(opts.X, {...}) end`：你想**扩展默认的列表**
>
> 简单口诀：**table 用于覆盖单个字段，function 用于扩展列表**。

### merge 流程图

```
LazyVim 默认 spec                      你的 spec
{                                       {
  "nvim-treesitter/nvim-treesitter",      "nvim-treesitter/nvim-treesitter",
  opts = {                                  opts = function(_, opts)
    ensure_installed = {                      vim.list_extend(opts.ensure_installed, {
      "bash",                                   { "rust", "toml" },
      "c",                                    })
      "css",                                end,
      -- ... 还有 10+ 种                     },
    },                                    }
    highlight = { enabled = true },
  },
}                                       }
                  │
                  ▼  按插件 URL 匹配，深度合并
                  │
                  ▼
              最终 spec（传给插件的 setup）
              {
                "nvim-treesitter/nvim-treesitter",
                opts = {
                  ensure_installed = {
                    "bash", "c", "css",        -- 默认的保留
                    -- ...
                    "rust", "toml",            -- 你追加的
                  },
                  highlight = { enabled = true },  -- 默认的非列表字段也保留
                },
              }
```

---

## `lazy-lock.json` — 版本锁定文件

### 作用

`lazy-lock.json` 记录每个插件的**具体 commit hash**，是"插件版本快照"：

```json
{
  "LazyVim": { "branch": "main", "commit": "abc1234", "version": false },
  "bufferline.nvim": { "branch": "main", "commit": "def5678", "version": false },
  "lazy.nvim": { "branch": "main", "commit": "ghi9012", "version": false }
  -- ...
}
```

### 为什么需要它

没有 `lazy-lock.json`，每次 `:Lazy install` 都会装**最新版**插件——
可能在某次更新后引入 breaking change，你的配置突然就不能用了。
有了锁定文件，`install` 会按记录的 commit hash 装，保证可复现。

### `.gitignore` 策略

| 场景 | 是否 commit `lazy-lock.json` |
|------|------------------------------|
| **个人配置仓库** | ✅ **commit**（保证多台机器版本一致） |
| **配置模板/ starter** | 可选（想始终装最新版就 gitignore） |
| **团队共享配置** | ✅ **commit**（团队成员版本一致） |

**建议**：除非你有特殊理由，否则 commit `lazy-lock.json`。这和 `package-lock.json`、
`poetry.lock` 是同一个道理。

### `:Lazy restore` — 还原到锁定版本

如果你手动 `:Lazy update` 升级了插件，发现某个插件新版有 bug，
可以用 `:Lazy restore` 把所有插件还原到 `lazy-lock.json` 记录的版本。

---

## 配置加载顺序（ASCII 图）

把前面所有内容串起来，完整的加载顺序是：

```
$ nvim
  │
  ▼
1. Neovim 读取 ~/.config/nvim/init.lua
  │
  ▼
2. init.lua: bootstrap lazy.nvim（没装就 clone）
  │
  ▼
3. init.lua: require("lazy").setup({
  │     spec = {
  │       { "LazyVim/LazyVim", import = "lazyvim.plugins" },
  │       { import = "plugins" },
  │     }
  │   })
  │
  ▼
4. lazy.nvim 收集所有 spec：
  │   - LazyVim 的默认 spec（来自 lazyvim/plugins/ 目录）
  │   - 你的 spec（来自 ~/.config/nvim/lua/plugins/ 目录）
  │   - 按插件 URL 匹配，深度合并
  │
  ▼
5. LazyVim 自动 source 你的 lua/config/ 目录（按顺序）：
  │   (a) lua/config/options.lua
  │   (b) lua/config/keymaps.lua
  │   (c) lua/config/autocmds.lua
  │   (d) lua/config/lazy.lua（如果存在）
  │
  ▼
6. lazy.nvim 按懒加载策略加载插件（event/ft/cmd/keys 触发时才加载）
  │
  ▼
7. Neovim 就绪，等待用户操作
```

**关键理解**：步骤 4（spec 合并）发生在步骤 5（config source）**之前**。
所以 `lua/config/autocmds.lua` 里可以安全地引用已加载的插件 API。

---

## 反模式（什么不该做）

### ❌ 在 `lua/plugins/` 写裸语句（不放 spec）

```lua
-- ❌ 坏：lua/plugins/my-settings.lua
vim.opt.number = true
vim.keymap.set("n", "<leader>w", ":w<CR>")
return {}  -- 即使加了 return {} 绕过报错，vim.opt 也会在错误时机执行

-- ✅ 正确：放 lua/config/options.lua 和 lua/config/keymaps.lua
```

### ❌ 覆盖列表型字段而不是 extend

```lua
-- ❌ 坏：覆盖 LazyVim 默认的 ensure_installed
return {
  { "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "lua" } },  -- 默认的 10+ 种全没了
  },
}

-- ✅ 正确：用 function extend
return {
  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "lua" })
    end,
  },
}
```

### ❌ 手动 source `lua/config/`

```lua
-- ❌ 坏：在 init.lua 里手动 require config
require("config.options")
require("config.keymaps")

-- ✅ 正确：LazyVim 自动 source，不需要手动 require
```

### ❌ 把 `lazy-lock.json` 加进 `.gitignore`

```gitignore
# ❌ 坏
lazy-lock.json

# ✅ 正确：commit 它（除非你写的是给别人 fork 的 starter）
```

**后果**：换机器时装到最新版插件，可能引入 breaking change，配置突然不能用。

---

## 常见错误

> 概念懂了，实际操作还是会踩坑。这些是 Vim/Neovim 新手最常犯的错误。

| 错误 | 症状 | 解决 |
|------|------|------|
| `opts = { ensure_installed = { "lua" } }` 覆盖默认列表 | Treesitter 只剩你写的几种语言，其他语言高亮没了 | 用 `opts = function(_, opts) vim.list_extend(opts.ensure_installed, {...}) end` 扩展 |
| `lua/plugins/` 文件没 return table | lazy.nvim 报错：spec 必须是 table | 每个文件必须 `return { spec }` 或 `return { spec1, spec2 }` |
| 在 `init.lua` 里手动 `require("config.options")` | 重复加载或加载顺序出错 | LazyVim 自动 source `lua/config/`，不需要手动 require |
| 用 `vim.keymap.set` 时忘了写 `desc` | which-key 里只显示按键，没有功能描述 | 每个 keymap 都加 `{ desc = "说明" }`，让 which-key 能显示 |
| 改了 `lazy-lock.json` 但没 commit | 换机器后插件版本不一致，行为不同 | commit `lazy-lock.json`，和 `package-lock.json` 一个道理 |

---

## 运行验证

本章的 `lua/` 目录演示了 config/ 和 plugins/ 的组织方式。验证语法：

```bash
cd lazyvim/05-config-architecture

# 验证 init.lua（和第 04 章类似，演示用）
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

# 验证 options.lua（纯 vim.opt 语句，可直接 luafile）
nvim --headless -u NONE -c "luafile lua/config/options.lua" -c 'qa!'

# 验证 keymaps.lua（纯 vim.keymap.set 语句）
nvim --headless -u NONE -c "luafile lua/config/keymaps.lua" -c 'qa!'

# 验证 plugins/example.lua（必须 return table，用 luafile 加载不会报错）
nvim --headless -u NONE -c "luafile lua/plugins/example.lua" -c 'qa!'

# 用 shared/verify.lua 验证 options 是否真的设上了
nvim --headless -u NONE \
  -c "luafile lua/config/options.lua" \
  -c "lua verify = dofile('../shared/verify.lua')" \
  -c 'lua print(verify.check_opt("number", true))' \
  -c 'qa!'
```

预期：所有命令退出码 0，最后一个命令打印 `[n] ... number = true (OK)` 之类。

---

## 下一步

你已经理解了 LazyVim 的目录架构和合并语义。但 spec 的**每个字段**（opts、keys、event、
ft、cmd、config、dependencies、enabled...）还没详细讲——

**第 06 章「lazy.nvim 插件管理器」** 会逐个字段拆解 spec 格式，并用对比表格说明
`event` vs `ft` vs `keys` vs `cmd` 四种懒加载策略的取舍。

> 💡 **本章核心**：记住"extend 不 overwrite"——扩展列表型配置永远用
> `opts = function(_, opts) vim.list_extend(opts.X, {...}) end`。
> 这是 LazyVim 配置的第一条铁律。

---

## 代码

- [`lua/init.lua`](./lua/init.lua) — 演示 config/ 目录的组织方式
- [`lua/config/options.lua`](./lua/config/options.lua) — 示例 options 配置
- [`lua/config/keymaps.lua`](./lua/config/keymaps.lua) — 示例 keymaps 配置
- [`lua/plugins/example.lua`](./lua/plugins/example.lua) — 示例 plugin spec
- [`exercises/`](./exercises/README.md) — 4 道练习题（创建 config 文件、理解合并语义）

**上一章**：[04-lazyvim-intro](../04-lazyvim-intro/)（LazyVim 简介与安装）
**下一章**：[06-lazy-nvim](../06-lazy-nvim/)（lazy.nvim 插件管理器详解）
