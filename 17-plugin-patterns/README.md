# 第17章 插件配置模式 — opts 传递、extend 与禁用

> **你已经会写 spec 了，但 LazyVim 里 90% 的配置错误都发生在"改插件"这一步。**
> 本章把第 06 章介绍的 extend vs overwrite 复习并深化，
> 补上 opts 传递的两种形态（table vs function）、禁用插件、禁用/替换快捷键、
> 以及"完全覆盖 vs 部分修改"的决策框架。
> 学完本章，你再也不会因为改一个字段而搞崩整个配置。

---

## TL;DR

> **30 秒速读**：LazyVim 插件配置有三种操作——extend 追加、disable 禁用、override 覆盖，90% 的错误来自用错这三种。
> 
> **如果只记一件事**：列表字段（ensure_installed 等）必须用 `opts = function` + `vim.list_extend`，用 `opts = {...}` 会整体替换。

---

## 本章目标

学完本章，你将能够：

1. **区分 opts 的两种传递方式**：table 直传 vs function 接收默认值
2. **精通 extend 模式**：`vim.list_extend` 扩展列表、`vim.tbl_deep_extend` 扩展 table
3. **禁用插件**：`enabled = false` 的正确用法和注意事项
4. **禁用/替换快捷键**：`keys = { {"<leader>/", false} }` 取消默认绑定
5. **做出覆盖 vs 修改的决策**：什么时候该完全覆盖，什么时候只改一部分

> ⚠️ **前置条件**：完成第 06 章（lazy.nvim spec 格式）和第 05 章（配置目录架构）。
> 本章是 Part 5「定制扩展」的开篇——从这里开始，你不再是照抄配置，而是真正掌控 LazyVim。

---

## 钩子：一个常见的崩溃场景

你看到别人配置里有这段，照搬到自己的 `lua/plugins/` 下：

```lua
{ "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = { "python", "rust" } } }
```

重启 Neovim，Treesitter 高亮没了。打开 JavaScript 文件，一片黑白。

**为什么？** 你用 `opts = { ensure_installed = {...} }` 直接覆盖了 LazyVim 的默认列表。
默认的 `bash`、`c`、`css`、`html`、`javascript`、`json`……全被你的两个语言替换了。

这个问题的根源是：**你不理解 opts 的传递机制**。本章彻底解决它。

---

## opts 的两种传递方式

lazy.nvim 的 `opts` 字段有两种写法，行为完全不同：

### 方式 1：opts = table（直接传递）

```lua
{
  "folke/tokyonight.nvim",
  opts = {
    style = "storm",
    transparent = false,
  },
}
```

lazy.nvim 会把这个 table 传给 `require("tokyonight").setup(opts)`。

**关键行为**：如果你的 spec 和 LazyVim 默认 spec 都有 `opts = {...}`，
lazy.nvim 会做**深度合并**——同名 key 你的覆盖默认的，列表字段**整体替换**。

```
LazyVim 默认 opts:  { style = "night", on_colors = function() ... end }
你的 opts:          { style = "storm" }
合并结果:           { style = "storm", on_colors = function() ... end }
                    ↑ 你的覆盖了      ↑ 默认的保留
```

看起来不错？但对列表字段就不行了：

```
LazyVim 默认 opts:  { ensure_installed = { "bash", "c", "css", "html", ... } }
你的 opts:          { ensure_installed = { "python", "rust" } }
合并结果:           { ensure_installed = { "python", "rust" } }
                    ↑ 默认的全没了！列表整体替换！
```

### 方式 2：opts = function（接收默认值）

```lua
{
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- 第一个参数 _：插件 spec（通常不用）
    -- 第二个参数 opts：lazy.nvim 已经合并好的默认 opts（引用传递）
    vim.list_extend(opts.ensure_installed, { "python", "rust" })
  end,
}
```

**关键行为**：lazy.nvim 不再做自动合并，而是把已合并的默认 opts 作为参数传给你的函数。
你在函数里直接修改这个 table（引用传递，不需要 return）。

```
lazy.nvim 准备好默认 opts（含 ensure_installed = {"bash","c",...}）
       ↓
传给你的函数（第二个参数 opts）
       ↓
你在函数里 vim.list_extend 追加
       ↓
opts.ensure_installed = {"bash","c",...,"python","rust"}
```

### 对照表

| 场景 | 写法 | 行为 |
|------|------|------|
| 插件没有默认 opts，或你确定要覆盖 | `opts = {...}` | table 直传，深度合并 |
| 扩展列表字段（ensure_installed 等） | `opts = function(_, opts) vim.list_extend(...) end` | 函数接收默认值，手动追加 |
| 扩展 table 字段（defaults 等） | `opts = function(_, opts) opts.defaults = vim.tbl_deep_extend(...) end` | 函数接收默认值，深度合并子 table |
| 你想完全重写插件配置 | `config = function() ... end` | 不用 opts，自己调 setup |

---

## extend 模式详解

extend 模式是 LazyVim 配置的第一铁律。第 06 章介绍过基本用法，这里深入三种场景。

### 场景 1：扩展列表字段（vim.list_extend）

最常见的场景——给 `ensure_installed`、`sources`、`tools` 等列表追加元素。

```lua
-- 扩展 Treesitter 语言列表
{
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, {
      "python",
      "rust",
      "toml",
      "yaml",
    })
  end,
}

-- 扩展 Mason 工具列表
{
  "williamboman/mason.nvim",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, {
      "stylua",
      "shellcheck",
      "shfmt",
      "flake8",
    })
  end,
}
```

**`vim.list_extend(target, source)` 行为**：
- 把 `source` 的每个元素追加到 `target` 末尾
- 返回 `target`（同一引用）
- 不会去重——如果你追加了已存在的元素，会出现两次

### 场景 2：扩展 table 字段（vim.tbl_deep_extend）

当你要修改的字段是 table（dict）而不是列表时，用 `vim.tbl_deep_extend`。

```lua
-- 扩展 Telescope 的 defaults table
{
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
      layout_strategy = "vertical",
      layout_config = {
        vertical = { width = 0.9, height = 0.9 },
      },
    })
  end,
}
```

**`vim.tbl_deep_extend("force", t1, t2)` 行为**：
- 递归合并 `t2` 到 `t1`
- `"force"` 表示同名 key 用 `t2` 的值覆盖 `t1` 的
- 返回新的 table（不修改原 table）
- 注意：必须写 `opts.defaults or {}`，防止 `opts.defaults` 是 nil

### 场景 3：混合扩展（列表 + table）

有些插件同时有列表字段和 table 字段，需要两种方式一起用。

```lua
{
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    -- 扩展列表：追加 sources
    local builtins = require("null-ls").builtins
    vim.list_extend(opts.sources or {}, {
      builtins.formatting.stylua,
      builtins.diagnostics.shellcheck,
    })

    -- 扩展 table：修改 diagnostics 配置
    opts.diagnostics = vim.tbl_deep_extend("force", opts.diagnostics or {}, {
      underline = true,
      virtual_text = { spacing = 4, prefix = "●" },
    })
  end,
}
```

---

## 禁用插件（enabled = false）

有些插件 LazyVim 默认启用，但你不想用。不要去改 LazyVim 源码，在自己的 spec 里加 `enabled = false` 就行。

### 基本用法

```lua
-- 禁用滚动动画（有人觉得晃眼）
{
  "echasnovski/mini.animate",
  enabled = false,
}

-- 禁用 indent-blankline（缩进线）
{
  "lukas-reineke/indent-blankline.nvim",
  enabled = false,
}
```

### 条件禁用

`enabled` 也可以是函数，根据条件动态决定是否启用：

```lua
-- 只在 Neovim >= 0.10 时启用某个插件
{
  "folke/snacks.nvim",
  enabled = function()
    return vim.fn.has("nvim-0.10") == 1
  end,
}

-- 只在有特定命令可用时启用
{
  "toppair/peek.nvim",
  enabled = function()
    return vim.fn.executable("deno") == 1
  end,
  build = "deno task --quiet build:fast",
}
```

### 禁用 vs 不安装

| 方式 | 效果 | 适用场景 |
|------|------|----------|
| `enabled = false` | 插件已安装但不加载 | 临时禁用、可能以后还会用 |
| 不写 spec | 插件不会被安装 | 永远不需要 |
| `:Lazy clean` + 删除 spec | 删除已安装的插件 | 彻底清理 |

### 注意事项

1. **`enabled = false` 必须和插件名配对**——你不能单独写一个 `enabled = false` 没有插件名
2. **lazy.nvim 会先合并你的 spec 和默认 spec**——你的 `enabled = false` 会覆盖默认的 `enabled = true`
3. **禁用插件不影响它的依赖**——如果你禁用了 A，但 B 依赖 A，B 仍然会加载（A 的代码不执行但目录还在）

---

## 禁用/替换快捷键

LazyVim 为很多插件绑了默认快捷键。有时候你想取消某个绑定，或者换成别的键。

### 禁用快捷键

在 `keys` 字段里加 `{ lhs, false }` 就能取消默认绑定：

```lua
-- 取消 <leader>/（默认是 Telescope 的全局搜索）
{
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>/", false },
  },
}

-- 取消多个快捷键
{
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>/", false },
    { "<leader>fb", false },
  },
}
```

### 替换快捷键

先禁用旧的，再加新的：

```lua
-- 把 <leader>ff 从 find_files 换成 oldfiles（最近文件）
{
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>ff", false },  -- 禁用旧绑定
    { "<leader>fo", "<cmd>Telescope oldfiles<CR>", desc = "最近文件" },  -- 新绑定
  },
}
```

### 禁用 LazyVim 默认的非插件快捷键

LazyVim 在 `lua/config/keymaps.lua` 里定义了一些全局快捷键（不属于任何插件）。
要禁用它们，在你自己的 `lua/config/keymaps.lua` 里删除：

```lua
-- ~/.config/nvim/lua/config/keymaps.lua
-- LazyVim 会先加载自己的 keymaps，然后加载你的
-- 你在这里删除不需要的默认绑定

vim.keymap.del("n", "<leader>/")  -- 删除全局搜索绑定
vim.keymap.del("n", "<leader>ff") -- 删除文件搜索绑定
```

> 💡 **`vim.keymap.del(mode, lhs)`**：删除已注册的快捷键。
> 只能删除全局快捷键，buffer-local 快捷键需要指定 buffer 号。

### 快捷键操作速查表

| 操作 | 写法 |
|------|------|
| 禁用插件的某个 key | `keys = { {"<leader>/", false} }` |
| 替换插件的 key | `keys = { {"<leader>/", false}, {"<leader>fo", "<cmd>...<CR>", desc = "..."} }` |
| 删除全局 keymap | `vim.keymap.del("n", "<leader>/")` |
| 新增 keymap | `vim.keymap.set("n", "<leader>x", function() ... end, { desc = "..." })` |

---

## 完全覆盖 vs 部分修改：决策框架

面对一个 LazyVim 内置插件，你该怎么决定是"完全覆盖"还是"部分修改"？

### 决策树

```
你想改插件的某个配置？
│
├─ 你只想追加一个字段/列表项
│   → 用 extend（opts = function + vim.list_extend / vim.tbl_deep_extend）
│
├─ 你想修改某个字段的值（不是追加）
│   ├─ 这个字段是 table 的叶子节点（string/number/bool）
│   │   → 用 opts = { field = new_value }（table 直传，深度合并会覆盖叶子）
│   │
│   └─ 这个字段是整个 table/list，你想全部替换
│       → 用 opts = function，直接赋值 opts.field = new_value
│
├─ 你想删除某个功能
│   ├─ 删除插件 → enabled = false
│   ├─ 删除快捷键 → keys = { {"lhs", false} }
│   └─ 删除某个配置字段 → opts = function, opts.field = nil
│
└─ 你想完全重写插件配置（100% 自定义）
    → 用 config = function() require("xxx").setup({...}) end
```

### 什么时候用 table 直传就够了

```lua
-- 安全：这些字段 LazyVim 默认没有，不存在覆盖问题
{
  "folke/tokyonight.nvim",
  opts = {
    style = "storm",           -- 默认是 "night"，覆盖没问题
    transparent = false,       -- 简单值覆盖
    on_highlights = function(hl, c)  -- 函数值覆盖
      hl.CursorLine = { bg = c.dark3 }
    end,
  },
}
```

**判断标准**：如果你修改的字段都是**叶子节点**（string、number、bool、function），
不是列表或嵌套 table，用 table 直传是安全的。

### 什么时候必须用 function extend

```lua
-- 必须用 function：ensure_installed 是列表，table 直传会覆盖
{
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, { "python", "rust" })
  end,
}

-- 必须用 function：defaults 是嵌套 table，你想追加子字段
{
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
      file_ignore_patterns = { "%.git/", "node_modules/" },
    })
  end,
}
```

### 什么时候用 config 完全覆盖

```lua
-- 完全覆盖：你需要在 setup 前后做很多事
{
  "neovim/nvim-lspconfig",
  config = function()
    -- 1. setup 前：设置全局变量
    vim.diagnostic.config({ virtual_text = false })

    -- 2. setup：完全自定义
    local lspconfig = require("lspconfig")
    lspconfig.lua_ls.setup({
      settings = {
        Lua = {
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    })

    -- 3. setup 后：加载额外功能
    require("lsp_signature").setup()
  end,
}
```

**警告**：用 `config` 完全覆盖意味着 LazyVim 的默认 LSP 配置全部失效。
除非你很清楚自己在做什么，否则优先用 `opts = function` 做部分修改。

---

## 反模式：什么不该做

### ❌ 用 table 直传覆盖列表字段

```lua
-- ❌ 坏：ensure_installed 被整体替换
{ "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = { "python" } } }

-- ✅ 正确：用 function extend
{ "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts) vim.list_extend(opts.ensure_installed, { "python" }) end }
```

### ❌ 在 opts function 里 return

```lua
-- ❌ 坏：return 会被忽略（opts table 是引用传递，修改就生效）
{
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, { "python" })
    return opts  -- 多余！而且可能破坏 lazy.nvim 的合并逻辑
  end,
}

-- ✅ 正确：直接修改，不 return
{
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, { "python" })
  end,
}
```

### ❌ 用 vim.api.nvim_set_keymap 代替 vim.keymap.set

```lua
-- ❌ 坏：nvim_set_keymap 已被弃用，且不支持 callback
vim.api.nvim_set_keymap("n", "<leader>x", ":echo 'hi'<CR>", { noremap = true })

-- ✅ 正确：用 vim.keymap.set（支持 callback、自动 noremap、desc）
vim.keymap.set("n", "<leader>x", function() print("hi") end, { desc = "打招呼" })
```

### ❌ 忘记给新快捷键写 desc

```lua
-- ❌ 坏：which-key 只显示按键，不显示功能
vim.keymap.set("n", "<leader>x", function() some_action() end)

-- ✅ 正确：带 desc，which-key 会显示 "执行某操作"
vim.keymap.set("n", "<leader>x", function() some_action() end, { desc = "执行某操作" })
```

### ❌ 禁用插件时遗漏依赖关系

```lua
-- ❌ 危险：禁用了 plenary.nvim，但 telescope 依赖它
{ "nvim-lua/plenary.nvim", enabled = false }

-- ✅ 正确：只禁用叶子插件，不要禁用被依赖的库
{ "echasnovski/mini.animate", enabled = false }  -- 没有其他插件依赖它，安全
```

## 常见错误

> 概念懂了，实际操作还是会踩坑。

| 错误 | 症状 | 解决 |
|------|------|------|
| `opts = { ensure_installed = {...} }` 覆盖列表 | Treesitter 高亮消失，只剩你加的语言 | 改用 `opts = function(_, opts) vim.list_extend(...) end` |
| 在 opts function 里 return opts | 配置没生效或报错 | opts 是引用传递，直接修改就行，不需要 return |
| 禁用了被依赖的库插件 | Telescope/补全等大面积报错 | 只禁用叶子插件（如 mini.animate），不要禁用 plenary 等基础库 |
| 禁用快捷键后忘了加新的 | 按键无反应，which-key 也看不到 | 先 `{ "<leader>/", false }` 禁用，再加新的 keymap |

---

## 运行验证

本章的 Lua 文件验证：

```bash
cd lazyvim/17-plugin-patterns

# 验证 init.lua
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

# 验证 patterns.lua（return {...} 格式，直接加载不报错）
nvim --headless -u NONE -c "luafile lua/plugins/patterns.lua" -c 'qa!'
```

预期：退出码 0，无错误。

---

## 下一步

你已经掌握了插件配置的三种核心操作：**extend**、**disable**、**override**。

- **第 18 章「自定义快捷键与自动命令」**：不再局限于插件 keys 字段，直接用 `vim.keymap.set` 和 `nvim_create_autocmd` 写出完全自定义的行为
- **第 19 章「Extras 系统」**：LazyVim 的 Extras 是什么、怎么启用、怎么写自己的 Extra

> 💡 **本章核心**：记住三个决策——
> 1. 扩展列表用 `opts = function + vim.list_extend`
> 2. 禁用插件用 `enabled = false`
> 3. 禁用快捷键用 `keys = { {"lhs", false} }`

---

## 代码

- [`lua/init.lua`](./lua/init.lua) — bootstrap 教学（pcall 保护）
- [`lua/plugins/patterns.lua`](./lua/plugins/patterns.lua) — extend + disable 模式示例
- [`exercises/`](./exercises/README.md) — 5 道练习题

**上一章**：[16-dap](../16-dap/)（DAP 调试）
**下一章**：[18-custom-keymaps](../18-custom-keymaps/)（自定义快捷键与自动命令）
