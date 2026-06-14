# 第14章 格式化与代码检查 — conform.nvim 与 nvim-lint

> **代码能跑不代表代码好看**。缩进不一致、引号风格混用、未使用的变量满屏飞。
> 格式化工具帮你自动统一风格，代码检查工具帮你提前发现 bug。
> 本章拆解 LazyVim 的两个工具：**conform.nvim**（格式化）和 **nvim-lint**（代码检查）。
> 学完本章，你的代码风格会自动保持一致，lint 警告会在保存前就告诉你哪里有问题。

---

## 本章目标

学完本章，你将能够：

1. **理解 conform.nvim 的工作方式**：格式化器配置、手动/自动触发
2. **配置格式化器**：prettier/stylua/black 的安装与选项
3. **控制自动格式化**：`<leader>uf` / `<leader>uF` 开关的含义
4. **理解 nvim-lint 的工作方式**：linter 配置、触发时机
5. **配置 linter**：eslint/luacheck/pylint 的安装与选项

> ⚠️ **前置条件**：完成第 12 章（LSP 已配置好）。格式化和代码检查虽然不依赖 LSP，
> 但 LSP 的诊断功能（第 12 章）和 nvim-lint 的检查功能是互补的。

---

## 为什么需要格式化和代码检查

### 格式化：统一风格

| 痛点 | 格式化如何解决 |
|------|----------------|
| 团队缩进风格不一致（2 空格 vs 4 空格） | 保存时自动格式化，统一风格 |
| 引号混用（单引号 vs 双引号） | prettier 自动统一 |
| 手动对齐太累 | 格式化器自动对齐 |
| Code review 时争论风格 | 让工具管风格，人管逻辑 |

### 代码检查：提前发现 bug

| 痛点 | linter 如何解决 |
|------|-----------------|
| 变量定义了但没用 | eslint/luacheck 标记 unused variable |
| 函数参数类型不对 | 类型检查器标记类型错误 |
| 潜在的运行时错误 | linter 静态分析发现隐患 |
| 代码风格违规 | linter 标记不符合规范的写法 |

LazyVim 用 **conform.nvim** 做格式化，**nvim-lint** 做代码检查。
这两个工具替代了之前的 null-ls/none-ls（已废弃）。

> ⚠️ **不要用 null-ls/none-ls**：LazyVim 从 v10 开始用 conform + nvim-lint 替代了
> null-ls。如果你在网上看到教程让你装 `nvimtools/none-ls.nvim`，那是过时的方案。

---

## conform.nvim — 格式化引擎

### 架构概览

conform.nvim 的核心概念：

```
┌─────────────────────────────────────────────────┐
│                 conform.nvim                     │
│  (负责：调用格式化器、应用格式化结果)            │
├─────────────────────────────────────────────────┤
│              格式化器 (formatters)                │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│  │ prettier │ │  stylua  │ │  black   │        │
│  │ JS/TS/   │ │  Lua     │ │  Python  │        │
│  │ JSON/CSS │ │          │ │          │        │
│  └──────────┘ └──────────┘ └──────────┘        │
├─────────────────────────────────────────────────┤
│              触发方式                            │
│  <leader>cf: 手动格式化（当前 buffer）           │
│  保存时自动格式化（可开关）                      │
└─────────────────────────────────────────────────┘
```

### 默认按键映射

| 按键 | 功能 |
|------|------|
| `<leader>cf` | 格式化当前 buffer（手动触发） |
| `<leader>cF` | 格式化选中的范围（visual 模式） |

### 自动格式化开关

LazyVim 提供了两个快捷键控制自动格式化：

| 按键 | 功能 |
|------|------|
| `<leader>uf` | 切换当前 buffer 的自动格式化（开/关） |
| `<leader>uF` | 切换全局自动格式化（开/关） |

**区别**：
- `<leader>uf` 只影响当前 buffer（比如你想在某个文件里关闭自动格式化）
- `<leader>uF` 影响所有 buffer（全局开关）

> 💡 **什么时候关自动格式化**：当你在编辑别人的代码、不想改动格式时，
> 或者格式化器对某种文件类型支持不好时，可以临时关闭。

---

## 格式化器配置

### LazyVim 默认的格式化器

LazyVim 已经为常见语言配好了格式化器：

| 文件类型 | 格式化器 | 说明 |
|----------|----------|------|
| Lua | stylua | Lua 代码格式化器 |
| JavaScript/TypeScript | prettier | JS/TS/JSON/CSS/HTML 格式化器 |
| Python | black | Python 代码格式化器 |
| Go | gofumpt / goimports | Go 代码格式化器 |
| Rust | rustfmt | Rust 代码格式化器 |
| Markdown | prettier | Markdown 格式化器 |

### `formatters_by_ft` — 按文件类型指定格式化器

conform.nvim 的核心配置是 `formatters_by_ft`，它定义了每种文件类型用哪个格式化器：

```lua
-- LazyVim 默认配置（你不需要写，这里演示结构）
formatters_by_ft = {
  lua = { "stylua" },
  python = { "black" },
  javascript = { "prettier" },
  typescript = { "prettier" },
  json = { "prettier" },
  css = { "prettier" },
  html = { "prettier" },
  markdown = { "prettier" },
  go = { "gofumpt", "goimports" },  -- 多个格式化器按顺序执行
}
```

> 💡 **多个格式化器**：`go = { "gofumpt", "goimports" }` 表示先跑 gofumpt，
> 再跑 goimports。它们是串行执行的，前一个的输出作为后一个的输入。

### 追加自定义格式化器

如果你想给某种文件类型添加新的格式化器，用 **extend 模式**：

```lua
-- lua/plugins/formatting.lua
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- ✅ 正确：用 vim.list_extend 追加新格式化器
      -- 默认的 prettier 保留，后面追加 eslint
      vim.list_extend(opts.formatters_by_ft.javascript, { "eslint" })
    end,
  },
}
```

### 配置格式化器选项

如果你想修改某个格式化器的选项（比如 prettier 的 tab 宽度）：

```lua
-- lua/plugins/formatting.lua
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- 修改 prettier 的选项
      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = {
        prepend_args = { "--tab-width", "2" },
      }
    end,
  },
}
```

---

## nvim-lint — 代码检查引擎

### 架构概览

nvim-lint 的核心概念：

```
┌─────────────────────────────────────────────────┐
│                   nvim-lint                      │
│  (负责：调用 linter、解析诊断结果)               │
├─────────────────────────────────────────────────┤
│                linter (检查器)                   │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│  │  eslint  │ │ luacheck │ │  pylint  │        │
│  │ JS/TS    │ │  Lua     │ │  Python  │        │
│  └──────────┘ └──────────┘ └──────────┘        │
├─────────────────────────────────────────────────┤
│              触发方式                            │
│  保存时自动检查 / 打开文件时检查                 │
│  诊断结果显示在行内（虚拟文本）和 signcolumn     │
└─────────────────────────────────────────────────┘
```

### 默认触发时机

nvim-lint 在以下时机自动运行：
- **BufReadPost**：打开文件时
- **BufWritePost**：保存文件时
- **InsertLeave**：退出插入模式时（某些 linter）

### LazyVim 默认的 linter

| 文件类型 | linter | 说明 |
|----------|--------|------|
| JavaScript/TypeScript | eslint | JS/TS 代码检查 |
| Lua | luacheck | Lua 代码检查（LazyVim 自带配置） |
| Python | pylint / ruff | Python 代码检查 |
| Markdown | markdownlint | Markdown 格式检查 |
| YAML | yamllint | YAML 格式检查 |

### 追加自定义 linter

如果你想给某种文件类型添加新的 linter，用 **extend 模式**：

```lua
-- lua/plugins/formatting.lua
return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- ✅ 正确：用 table.insert 追加新 linter
      -- 默认的 eslint 保留，后面追加 stylelint
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.css = opts.linters_by_ft.css or {}
      table.insert(opts.linters_by_ft.css, "stylelint")
    end,
  },
}
```

### 配置 linter 选项

如果你想修改某个 linter 的选项（比如 eslint 的规则）：

```lua
-- lua/plugins/formatting.lua
return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- 修改 eslint 的选项
      opts.linters = opts.linters or {}
      opts.linters.eslint = {
        args = { "--no-warn-ignored", "--format", "json" },
      }
    end,
  },
}
```

---

## 安装格式化器和 linter

conform.nvim 和 nvim-lint 只是"调度器"，它们调用外部的格式化器和 linter。
你需要确保这些外部工具已安装。

### 安装方式

| 工具 | 安装方式 |
|------|----------|
| stylua | `cargo install stylua` 或 `brew install stylua` |
| prettier | `npm install -g prettier` |
| black | `pip install black` |
| eslint | 项目本地 `npm install eslint`（推荐） |
| luacheck | `luarocks install luacheck` 或 `brew install luacheck` |
| pylint | `pip install pylint` |

### Mason 安装（推荐）

LazyVim 集成了 Mason（第 12 章），可以通过 Mason 安装格式化器和 linter：

```vim
:MasonInstall stylua
:MasonInstall prettier
:MasonInstall black
:MasonInstall eslint
:MasonInstall luacheck
```

> 💡 **Mason 只管安装**：Mason 负责把工具装到 Neovim 能找到的路径，
> 但不负责配置。配置在 conform.nvim 和 nvim-lint 的 spec 里完成。

---

## 格式化 vs LSP 格式化

你可能会问：LSP 不是有格式化功能吗？为什么还要 conform.nvim？

| 特性 | LSP 格式化 | conform.nvim |
|------|-----------|--------------|
| 触发方式 | `vim.lsp.buf.format()` | `<leader>cf` 或保存时自动 |
| 格式化器 | 依赖 LSP 服务器 | 独立的外部工具 |
| 多格式化器 | 不支持 | 支持串行执行多个 |
| 性能 | LSP 服务器常驻内存 | 每次调用启动进程 |
| 灵活性 | LSP 服务器决定 | 你可以完全控制 |

**LazyVim 的策略**：
- 如果 LSP 服务器支持格式化（比如 tsserver、gopls），优先用 LSP
- 如果 LSP 不支持或你想要更精细的控制，用 conform.nvim
- 两者可以共存，不会冲突

> 💡 **实际体验**：大多数时候你不需要关心是 LSP 还是 conform 在格式化。
> 按 `<leader>cf` 或保存文件，代码自动变好看就行。

---

## 反模式（什么不该做）

### ❌ 用 null-ls/none-ls

```lua
-- ❌ 坏：用已废弃的 null-ls
return {
  { "nvimtools/none-ls.nvim", opts = { ... } },
}

-- ✅ 正确：用 conform.nvim + nvim-lint
return {
  { "stevearc/conform.nvim", opts = { ... } },
  { "mfussenegger/nvim-lint", opts = { ... } },
}
```

### ❌ 用 `opts = { formatters_by_ft = {...} }` 覆盖默认格式化器

```lua
-- ❌ 坏：覆盖了 LazyVim 默认的所有格式化器
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },  -- 只剩 lua 的，JS/Python/Go 的格式化器全没了
      },
    },
  },
}

-- ✅ 正确：用 function extend
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- 追加新的文件类型
      opts.formatters_by_ft.toml = { "taplo" }
    end,
  },
}
```

### ❌ 不装格式化器就期望自动格式化

```
症状：按 <leader>cf 没反应，或报错 "stylua not found"
原因：stylua 没装（conform.nvim 只是调度器，需要外部工具）
修复：:MasonInstall stylua 或 cargo install stylua
```

### ❌ 同时用 LSP 格式化和 conform.nvim 格式化同一种语言

```lua
-- ❌ 坏：LSP 和 conform 都格式化 JavaScript，保存时格式化两次
-- LSP: tsserver 格式化
-- conform: prettier 格式化
-- 结果：两次格式化可能冲突

-- ✅ 正确：选一个。LazyVim 默认会处理好这个冲突，不需要你操心。
```

---

## 工作流示例

### 场景 1：手动格式化

```
你写了一段乱七八糟的 Lua 代码
           │
           ▼
按 <leader>cf（格式化当前 buffer）
           │
           ▼
conform.nvim 调用 stylua
           │
           ▼
代码自动格式化：缩进统一、对齐整齐
```

### 场景 2：保存时自动格式化 + lint

```
你修改了 JavaScript 文件，按 :w 保存
           │
           ▼
conform.nvim 自动调用 prettier 格式化
           │
           ▼
nvim-lint 自动调用 eslint 检查
           │
           ▼
┌─────────────────────────────────────┐
│ 行 10: ⚠ unused variable 'foo'     │  ← eslint 警告
│ 行 15: ⚠ missing semicolon         │  ← eslint 警告
└─────────────────────────────────────┘
           │
           ▼
你看到警告，修复后再次保存
           │
           ▼
警告消失，代码格式化+检查都通过
```

### 场景 3：临时关闭自动格式化

```
你在编辑一个遗留项目的文件，不想改动格式
           │
           ▼
按 <leader>uf（切换当前 buffer 的自动格式化）
           │
           ▼
状态栏显示"格式化已禁用"
           │
           ▼
你修改代码，保存时不会自动格式化
           │
           ▼
改完后再次按 <leader>uf，重新启用
```

---

## 运行验证

本章的 `lua/plugins/formatting.lua` 是一个可运行的 spec。验证语法：

```bash
cd lazyvim/14-formatting

# 验证 init.lua（演示格式化/检查引擎初始化）
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

# 验证 formatting.lua（return { ... } 形式，直接 luafile 不会报错）
nvim --headless -u NONE -c "luafile lua/plugins/formatting.lua" -c 'qa!'

# 预期：退出码 0，无错误
```

> 💡 **真实环境验证**：把 `lua/plugins/formatting.lua` 复制到
> `~/.config/nvim/lua/plugins/` 下，运行 `:Lazy sync`，重启 Neovim，
> 打开一个 Lua 文件，按 `<leader>cf` 看看有没有格式化。

---

## 下一步

你已经掌握了补全（第 13 章）和格式化/检查（本章）。
接下来 **Part 4「开发工作流」** 会进入日常开发的最后两个核心能力：

- **第 15 章「Git 集成」**：gitsigns 行内标记、lazygit、diff 视图
- **第 16 章「DAP 调试」**：断点调试、变量查看、调用栈

> 💡 **本章核心**：conform.nvim 管格式化，nvim-lint 管代码检查，
> 两者都是"调度器"（调用外部工具）。追加配置用 extend 模式，不要覆盖默认配置。
> 记住 `<leader>cf` 手动格式化，`<leader>uf` 切换自动格式化。

---

## 代码

- [`lua/init.lua`](./lua/init.lua) — conform + nvim-lint 初始化演示（pcall guard）
- [`lua/plugins/formatting.lua`](./lua/plugins/formatting.lua) — 格式化器/linter 配置（extend 模式）
- [`exercises/`](./exercises/README.md) — 4 道练习题（格式化器配置、linter 配置、自动格式化开关）

**上一章**：[13-completion](../13-completion/)（自动补全）
**下一章**：[15-git](../15-git/)（Git 集成）
