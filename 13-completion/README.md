# 第13章 自动补全 — nvim-cmp 与补全来源

> **你有没有这种经历**：明明记得函数名的前几个字母，却要手敲完整拼写，
> 还得检查大小写、参数顺序、返回类型。自动补全把这件事从"记忆考验"变成了"选择题"。
> 本章拆解 LazyVim 的补全引擎 nvim-cmp：补全来源有哪些、按键怎么配、
> snippet 引擎怎么选、外观怎么调。学完本章，你的 Neovim 补全体验会接近 VS Code。

---

## 本章目标

学完本章，你将能够：

1. **理解 nvim-cmp 的架构**：引擎、来源、映射三者的关系
2. **配置补全来源**：buffer/path/lsp/snippet 四种来源的优先级和开关
3. **自定义按键映射**：Tab/Shift-Tab 导航、`<CR>` 确认、`<C-Space>` 手动触发
4. **选择 snippet 引擎**：LuaSnip vs mini.snippets 的取舍
5. **调整补全外观**：图标、格式、窗口样式

> ⚠️ **前置条件**：完成第 12 章（LSP 已配置好）。补全的核心来源之一是 LSP，
> 没有 LSP 就没有函数签名、类型提示这些最有价值的补全项。

---

## 为什么需要自动补全

手工敲代码的痛点：

| 痛点 | 补全如何解决 |
|------|--------------|
| 函数名拼写错误 | LSP 补全给出精确候选，Tab 选中 |
| 忘记参数顺序 | 补全菜单显示函数签名 |
| 重复输入长路径 | path 补全自动补文件路径 |
| snippet 记不住 | snippet 引擎展开代码模板 |
| buffer 里已有的变量名 | buffer 补全从当前文件提取 |

LazyVim 默认用 **nvim-cmp** 作为补全引擎，它的好处是**来源可插拔**：
你可以自由组合 buffer、path、LSP、snippet 等来源，每个来源的优先级可调。

---

## nvim-cmp 架构概览

nvim-cmp 有三个核心概念：

```
┌─────────────────────────────────────────────────┐
│                   nvim-cmp 引擎                  │
│  (负责：弹出菜单、按键映射、选择确认)            │
├─────────────────────────────────────────────────┤
│                  补全来源 (sources)               │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐           │
│  │buffer│ │ path │ │ lsp  │ │snippet│           │
│  │当前文│ │文件路│ │语言服│ │代码模│           │
│  │件内容│ │径    │ │务器  │ │板    │           │
│  └──────┘ └──────┘ └──────┘ └──────┘           │
├─────────────────────────────────────────────────┤
│               按键映射 (mapping)                 │
│  Tab/Shift-Tab: 导航   <CR>: 确认               │
│  <C-Space>: 手动触发   <C-e>: 关闭菜单          │
└─────────────────────────────────────────────────┘
```

**来源的优先级**：nvim-cmp 按 `priority` 排序，数字大的排在前面。
LazyVim 默认的优先级是：lsp > snippet > path > buffer。

---

## LazyVim 默认的补全配置

LazyVim 已经为你配好了 nvim-cmp，开箱即用。你不需要从零写配置，
只需要理解它配了什么、怎么覆盖。

### 默认按键映射

| 按键 | 模式 | 功能 |
|------|------|------|
| `<Tab>` | 插入模式 | 选中下一个补全项 / 跳到下一个 snippet 占位符 |
| `<S-Tab>` | 插入模式 | 选中上一个补全项 / 跳到上一个 snippet 占位符 |
| `<CR>` | 插入模式 | 确认选中项（插入补全文本） |
| `<C-Space>` | 插入模式 | 手动触发补全菜单 |
| `<C-e>` | 插入模式 | 关闭补全菜单 |
| `<C-n>` | 插入模式 | 选中下一个补全项（备选，不用 Tab 时） |
| `<C-p>` | 插入模式 | 选中上一个补全项 |

> 💡 **Tab 的双重角色**：`<Tab>` 在补全菜单弹出时选择下一个候选，
> 在 snippet 展开时跳到下一个占位符。如果菜单没弹出，`<Tab>` 就是正常的缩进。
> 这种"上下文感知"是 nvim-cmp 的亮点。

### 默认补全来源

```lua
-- LazyVim 内置的 sources 配置（你不需要写）
sources = {
  { name = "nvim_lsp", priority = 1000 },  -- LSP 补全（函数、变量、类型）
  { name = "luasnip",  priority = 750 },   -- snippet 补全
  { name = "path",     priority = 500 },   -- 文件路径补全
  { name = "buffer",   priority = 250 },   -- 当前 buffer 内容补全
}
```

---

## 补全来源详解

### 1. buffer 来源 — 从当前文件提取

buffer 来源扫描当前 buffer（和已打开的其他 buffer）里的单词，作为补全候选。
它是最基础的来源，不需要任何外部工具。

**适用场景**：变量名、函数名、注释里的关键词。

**特点**：
- 不需要 LSP，纯文本匹配
- 只匹配已打开的 buffer 内容
- 优先级最低（当 LSP 有结果时，buffer 结果排在后面）

### 2. path 来源 — 文件路径补全

当你在引号里输入 `./` 或 `/` 时，path 来源自动弹出文件路径候选。
它用 `fd` 命令（第 09 章提到的文件搜索工具）扫描文件系统。

**适用场景**：import 语句、require 路径、配置文件里的路径。

**特点**：
- 依赖 `fd` 命令（LazyVim 推荐安装）
- 支持相对路径和绝对路径
- 自动补全目录和文件名

### 3. LSP 来源 — 语言服务器补全（最有价值）

LSP 来源从语言服务器获取补全候选。这是**最有价值**的来源，
因为它理解代码语义：知道函数签名、类型信息、可用成员。

**适用场景**：函数调用、方法链、类型补全、import 语句。

**特点**：
- 理解代码语义（不是纯文本匹配）
- 提供函数签名、文档、类型信息
- 依赖第 12 章配置的 LSP
- 优先级最高

### 4. snippet 来源 — 代码模板

snippet 是预定义的代码模板，比如输入 `fn` 展开为函数骨架。
LazyVim 默认用 **LuaSnip** 作为 snippet 引擎。

**适用场景**：函数定义、循环结构、import 模板、常用代码片段。

**特点**：
- 需要 snippet 引擎（LuaSnip 或 mini.snippets）
- 支持占位符跳转（Tab 跳到下一个 `$1`、`$2`）
- 社区有大量预定义 snippet（friendly-snippets）

---

## 补全来源配置 — extend 模式

如果你想追加或修改补全来源，用 **extend 模式**（第 06 章的铁律）：

### 追加新的来源

```lua
-- lua/plugins/completion.lua
return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",  -- 新来源：emoji 补全
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      -- ✅ 正确：用 table.insert 追加新来源（不覆盖默认来源）
      local cmp = require("cmp")
      table.insert(opts.sources, { name = "emoji", priority = 100 })
    end,
  },
}
```

> ⚠️ **铁律**：追加来源用 `table.insert(opts.sources, ...)` 或
> `vim.list_extend(opts.sources, ...)`，**不要**用 `opts = { sources = {...} }` 直接覆盖。

### 调整来源优先级

```lua
-- lua/plugins/completion.lua
return {
  {
    "hrsh7th/nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      -- 修改 buffer 来源的优先级（让它排在 path 前面）
      for _, source in ipairs(opts.sources) do
        if source.name == "buffer" then
          source.priority = 600  -- 原来是 250，现在比 path(500) 高
        end
      end
    end,
  },
}
```

---

## snippet 引擎选择

LazyVim 支持两种 snippet 引擎，你可以通过 Extras 切换：

### LuaSnip（默认）

LazyVim 默认用 **LuaSnip**，它是最成熟的 snippet 引擎：

```lua
-- LazyVim 默认配置（你不需要写）
{
  "L3MON4D3/LuaSnip",
  build = "make install_jsregexp",
  dependencies = {
    "rafamadriz/friendly-snippets",  -- 社区 snippet 集合
  },
  opts = {
    history = true,
    delete_check_events = "TextChanged",
  },
}
```

**LuaSnip 的特点**：
- 支持 VS Code 格式的 snippet（friendly-snippets 里的）
- 支持 Lua 格式的 snippet（更灵活）
- 历史记录（可以回退到之前的 snippet 展开）
- 社区 snippet 最丰富

### mini.snippets（备选）

mini.snippets 是 `echasnovski/mini.snippets` 提供的轻量方案：

```lua
-- 如果你想用 mini.snippets 替代 LuaSnip
-- 在 LazyVim Extras 里启用：:LazyExtras → mini.snippets
{
  "echasnovski/mini.snippets",
  dependencies = { "rafamadriz/friendly-snippets" },
  opts = {},
}
```

**mini.snippets 的特点**：
- 更轻量（mini.nvim 生态的一部分）
- 配置更简单
- 与 mini.nvim 其他模块风格一致

### 怎么选

| 场景 | 推荐 |
|------|------|
| 刚入门，想要最多 snippet | LuaSnip（默认） |
| 已经用 mini.nvim 生态 | mini.snippets |
| 不想折腾 | 保持默认（LuaSnip） |

---

## 补全外观自定义

nvim-cmp 的外观可以通过 `formatting` 和 `window` 配置调整。

### 补全项格式

```lua
-- lua/plugins/completion.lua
return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      -- 自定义补全项格式：显示来源名称 + 图标
      opts.formatting = {
        format = function(entry, vim_item)
          -- 显示来源名称（LSP、Buffer、Path、Snippet）
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            luasnip  = "[Snippet]",
            buffer   = "[Buffer]",
            path     = "[Path]",
          })[entry.source.name]
          return vim_item
        end,
      }
    end,
  },
}
```

### 窗口样式

```lua
-- lua/plugins/completion.lua
return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      -- 补全菜单的窗口样式
      opts.window = {
        completion = {
          border = "rounded",        -- 圆角边框
          winhighlight = "Normal:Pmenu,FloatBorder:Pmenu",
        },
        documentation = {
          border = "rounded",        -- 文档浮窗也用圆角
        },
      }
    end,
  },
}
```

> 💡 **LazyVim 已经配好了外观**：默认就有图标（LSP kind icons）、
> 来源名称、圆角边框。大多数情况下你不需要改。上面的代码是演示如何覆盖。

---

## 关闭补全

有时候补全很烦人（比如写 Markdown 时）。LazyVim 提供了快捷键：

| 按键 | 功能 |
|------|------|
| `<leader>uc` | 切换补全开关（开/关） |

或者在配置里永久关闭特定文件类型的补全：

```lua
-- lua/plugins/completion.lua
return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      -- 在 Markdown 文件里禁用补全
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          require("cmp").setup.buffer({ enabled = false })
        end,
        desc = "Markdown 禁用补全",
      })
    end,
  },
}
```

---

## 反模式（什么不该做）

### ❌ 用 `opts = { sources = {...} }` 覆盖默认来源

```lua
-- ❌ 坏：覆盖了 LazyVim 默认的 lsp/snippet/path 来源
return {
  {
    "hrsh7th/nvim-cmp",
    opts = {
      sources = {
        { name = "buffer" },  -- 只剩 buffer 来源，LSP 补全没了！
      },
    },
  },
}

-- ✅ 正确：用 table.insert 追加
return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })
    end,
  },
}
```

### ❌ 忘记给来源设 priority

```lua
-- ❌ 坏：没设 priority，新来源排在最后（默认 priority = 0）
table.insert(opts.sources, { name = "emoji" })

-- ✅ 正确：设合理的 priority
table.insert(opts.sources, { name = "emoji", priority = 100 })
```

### ❌ 在 Tab 映射里写死 snippet 跳转逻辑

```lua
-- ❌ 坏：自己写 Tab 映射，覆盖了 LazyVim 的上下文感知逻辑
vim.keymap.set("i", "<Tab>", function()
  if require("luasnip").expand_or_jumpable() then
    require("luasnip").expand_or_jump()
  else
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true))
  end
end)

-- ✅ 正确：LazyVim 已经配好了 Tab 的上下文感知，不需要自己写
```

### ❌ 不装 LSP 就期望有函数补全

```
症状：输入 require("cmp"). 后没有方法候选
原因：没有 LSP（cmp-nvim-lsp 来源没有数据）
修复：按第 12 章配好 LSP + Mason
```

---

## 补全工作流示例

### 场景 1：输入函数名

```
你输入: require("cmp").
           │
           ▼
nvim-cmp 触发 LSP 补全
           │
           ▼
┌─────────────────────────┐
│ setup()          [LSP]  │  ← LSP 知道 cmp 模块有哪些方法
│ config()         [LSP]  │
│ mapping          [LSP]  │
│ sources          [LSP]  │
└─────────────────────────┘
           │
           ▼
你按 Tab 选择 setup()，按 <CR> 确认
           │
           ▼
require("cmp").setup(
```

### 场景 2：输入文件路径

```
你输入: require("
           │
           ▼
nvim-cmp 触发 path 补全
           │
           ▼
┌─────────────────────────┐
│ ./config/        [Path] │
│ ./plugins/       [Path] │
│ ./utils/         [Path] │
└─────────────────────────┘
           │
           ▼
你继续输入 pl，菜单过滤到 plugins/
```

### 场景 3：snippet 展开

```
你输入: fn
           │
           ▼
nvim-cmp 触发 snippet 补全
           │
           ▼
┌─────────────────────────┐
│ function ...    [Snip]  │  ← LuaSnip 提供的 snippet
│ function(x) ... [Snip]  │
└─────────────────────────┘
           │
           ▼
你按 <CR> 确认，snippet 展开为:
function ${1:name}(${2:args})
  ${0:body}
end
           │
           ▼
光标停在 ${1:name}，你输入函数名
           │
           ▼
按 Tab 跳到 ${2:args}，输入参数
           │
           ▼
再按 Tab 跳到 ${0:body}，开始写函数体
```

---

## 运行验证

本章的 `lua/plugins/completion.lua` 是一个可运行的 spec。验证语法：

```bash
cd lazyvim/13-completion

# 验证 init.lua（演示补全引擎初始化）
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

# 验证 completion.lua（return { ... } 形式，直接 luafile 不会报错）
nvim --headless -u NONE -c "luafile lua/plugins/completion.lua" -c 'qa!'

# 预期：退出码 0，无错误
```

> 💡 **真实环境验证**：把 `lua/plugins/completion.lua` 复制到
> `~/.config/nvim/lua/plugins/` 下，运行 `:Lazy sync`，重启 Neovim，
> 打开一个 Lua 文件，输入 `require("cmp").` 看看有没有 LSP 补全菜单弹出。

---

## 下一步

补全让输入更快，但代码风格的一致性还需要**格式化**和**代码检查**。

**第 14 章「格式化与代码检查」** 会讲：
- **conform.nvim**：保存时自动格式化（prettier/stylua/black）
- **nvim-lint**：实时代码检查（eslint/luacheck/pylint）
- 自动格式化开关（`<leader>uf` 切换）

> 💡 **本章核心**：nvim-cmp 的补全来源是可插拔的——
> buffer、path、LSP、snippet 四种来源各有分工，LSP 是最有价值的那个。
> 追加来源用 `table.insert(opts.sources, ...)`，不要覆盖默认来源。

---

## 代码

- [`lua/init.lua`](./lua/init.lua) — nvim-cmp 初始化演示（pcall guard）
- [`lua/plugins/completion.lua`](./lua/plugins/completion.lua) — 补全来源配置（extend 模式）
- [`exercises/`](./exercises/README.md) — 4 道练习题（来源配置、按键映射、snippet 引擎选择）

**上一章**：[12-lsp-mason](../12-lsp-mason/)（LSP 与 Mason）
**下一章**：[14-formatting](../14-formatting/)（格式化与代码检查）
