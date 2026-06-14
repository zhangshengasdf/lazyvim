# 项目 1：全栈 TypeScript 配置 — 让 LazyVim 成为 TS/React/Tailwind IDE

> **你学了 19 章理论，现在该组装了。** 这个项目把 Ch09-19 的知识拼成一套完整的
> TypeScript 全栈开发配置：LSP 补全、Prettier 格式化、ESLint 检查、Tailwind 支持、
> 调试器，全部就绪。复制到 `~/.config/nvim/` 就能用。

---

## TL;DR

> **30 秒速读**：把 Ch09-19 的知识组装成完整的 TypeScript 全栈配置——vtsls LSP + Prettier + ESLint + Tailwind + DAP，复制即用。
> 
> **如果只记一件事**：每个 spec 文件都用 extend 模式（`opts = function`），不覆盖 LazyVim 默认值。

---

## 项目目标

为 TypeScript/React/Tailwind CSS 全栈开发配置 LazyVim，实现：

1. **LSP**：vtsls（或 typescript-tools.nvim）提供跳转、补全、诊断
2. **格式化**：prettier 保存时自动格式化（JS/TS/JSON/CSS/HTML/Markdown）
3. **代码检查**：eslint 实时 lint（未使用变量、类型错误、风格违规）
4. **Tailwind CSS**：tailwindcss-language-server 提供类名补全和颜色预览
5. **调试器**：js-debug-adapter 调试 Node.js 和浏览器代码
6. **Treesitter**：JS/TS/TSX/CSS/JSON/Markdown 语法高亮和文本对象

学完本项目，你的 Neovim 会和 VS Code 的 TypeScript 体验一样好，甚至更快。

---

## 钩子：从"能用"到"好用"

LazyVim 开箱即用已经支持 TypeScript：装好 LazyVim，打开 `.ts` 文件，LSP 自动启动，
补全能用，`gd` 能跳转。

但"能用"和"好用"之间差着一条鸿沟：

| 问题 | "能用"状态 | "好用"状态 |
|------|-----------|-----------|
| 格式化 | 手动按 `<leader>cf` | 保存时自动格式化（prettier） |
| Lint | LSP 诊断（有限） | eslint 实时检查（更全面） |
| Tailwind | 无补全 | 类名补全 + 颜色预览 |
| 调试 | `console.log` | 断点调试（dap-ui） |
| Inlay Hints | 默认关闭 | 参数名、类型标注显示 |

这个项目的目标就是帮你跨过这条鸿沟。

---

## 所需 Extras

LazyVim 的 Extras 系统（第 19 章）提供了预配置的语言支持。
对于 TypeScript 全栈开发，推荐启用以下 Extras：

| Extra | 路径 | 提供的能力 |
|-------|------|-----------|
| TypeScript | `lazyvim.plugins.extras.lang.typescript` | vtsls LSP、inlay hints、import 整理 |
| Tailwind CSS | `lazyvim.plugins.extras.lang.tailwindcss` | tailwindcss LSP、类名补全 |
| JSON | `lazyvim.plugins.extras.lang.json` | jsonls LSP、schemastore |
| Prettier | `lazyvim.plugins.extras.formatting.prettier` | conform.nvim prettier 配置 |
| ESLint | `lazyvim.plugins.extras.linting.eslint` | nvim-lint eslint 配置 |

启用方式：在 Neovim 中运行 `:LazyExtras`，搜索并启用上述 Extra。
或在 `lua/plugins/extras.lua` 中用 `import` 声明（见第 19 章）。

> 本项目的配置文件是**独立于 Extras 的完整方案**。你可以只用本项目的配置，
> 也可以配合 Extras 使用（本项目的配置会 extend Extras 的默认值）。

---

## 完整配置方案

### 架构图

```
~/.config/nvim/
├── lua/
│   ├── config/
│   │   └── options.lua          ← 项目 1 提供：TS 专属选项
│   └── plugins/
│       ├── lsp.lua              ← 项目 1 提供：vtsls LSP 配置
│       ├── formatting.lua       ← 项目 1 提供：prettier 格式化
│       ├── linting.lua          ← 项目 1 提供：eslint 检查
│       └── extra.lua            ← 项目 1 提供：Tailwind + 调试器
└── init.lua                     ← LazyVim 入口（不需要改）
```

### 各文件职责

| 文件 | 对应章节 | 核心配置 |
|------|----------|----------|
| `lua/config/options.lua` | Ch03（选项） | tab 宽度、自动保存、inlay hints |
| `lua/plugins/lsp.lua` | Ch12（LSP） | vtsls 服务器配置、settings |
| `lua/plugins/formatting.lua` | Ch14（格式化） | prettier 格式化器、tab 宽度、引号风格 |
| `lua/plugins/linting.lua` | Ch14（检查） | eslint linter 配置 |
| `lua/plugins/extra.lua` | Ch16（DAP）+ Ch11（Treesitter） | Tailwind LSP、js-debug、Treesitter 语言 |

### 配置合并关系

```
LazyVim 默认 spec
      │
      ▼
lua/plugins/lsp.lua        ← extend servers（追加 vtsls settings）
      │
      ▼
lua/plugins/formatting.lua ← extend formatters_by_ft（追加 prettier 选项）
      │
      ▼
lua/plugins/linting.lua    ← extend linters_by_ft（追加 eslint）
      │
      ▼
lua/plugins/extra.lua      ← 新增 Tailwind LSP + js-debug + Treesitter 语言
```

每个文件都用 **extend 模式**（`opts = function(_, opts)`），不覆盖 LazyVim 默认值。

---

## 各文件详解

### lua/config/options.lua

设置 TypeScript 开发的专属选项：

```lua
-- tab 宽度：JS/TS 社区标准是 2 空格
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- 自动保存时格式化（由 conform.nvim 执行）
vim.g.autoformat = true

-- inlay hints（参数名、类型标注）
vim.g.inlay_hints = true
```

这些选项会影响所有 buffer。如果你只想对 TS 文件设置 tab 宽度，
可以用 `autocmd FileType typescript` 做 buffer-local 设置（见练习 1）。

### lua/plugins/lsp.lua

配置 vtsls（或 typescript-tools.nvim）语言服务器：

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayFunctionParameterTypeHints = true,
              },
            },
          },
        },
      },
    },
  },
}
```

关键点：
- 用 `opts = { servers = { vtsls = {...} } }` 声明服务器（Ch12 模式）
- 空 table `{}` 表示用默认配置
- settings 里启用 inlay hints（参数名、类型标注）

### lua/plugins/formatting.lua

配置 prettier 格式化器：

```lua
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.typescript = { "prettier" }
      opts.formatters_by_ft.typescriptreact = { "prettier" }
      -- prettier 选项
      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = {
        prepend_args = { "--tab-width", "2", "--single-quote" },
      }
    end,
  },
}
```

关键点：
- 用 `opts = function` extend（Ch14 模式），不覆盖默认格式化器
- `prepend_args` 传参给 prettier CLI

### lua/plugins/linting.lua

配置 eslint linter：

```lua
return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.typescript = { "eslint" }
      opts.linters_by_ft.typescriptreact = { "eslint" }
    end,
  },
}
```

关键点：
- 用 `table.insert` 或直接赋值追加（Ch14 模式）
- eslint 需要项目本地安装（`npm install eslint`）

### lua/plugins/extra.lua

追加 Tailwind LSP、js-debug 调试器、Treesitter 语言：

```lua
return {
  -- Tailwind CSS LSP（类名补全 + 颜色预览）
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {},
      },
    },
  },
  -- js-debug 调试器
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "mxsdev/nvim-dap-vscode-js",
        config = function()
          local ok, dap_js = pcall(require, "dap-vscode-js")
          if ok then
            dap_js.setup({ debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter" })
          end
        end,
      },
    },
  },
  -- Treesitter 追加语言
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "typescript",
        "tsx",
        "css",
        "json",
        "jsonc",
        "markdown",
        "markdown_inline",
      })
    end,
  },
}
```

关键点：
- Tailwind LSP 和 vtsls 共存于同一个 `nvim-lspconfig` spec（lazy.nvim 会合并）
- js-debug 用 `keys` 懒加载（Ch16 模式）
- Treesitter 用 `vim.list_extend` extend（Ch11 模式）

---

## 反模式（什么不该做）

### ❌ 用 `opts = { servers = { vtsls = {...} } }` 覆盖所有服务器

```lua
-- ❌ 坏：覆盖了 LazyVim 默认的 lua_ls、jsonls 等
return {
  { "neovim/nvim-lspconfig", opts = { servers = { vtsls = {...} } } },
}

-- ✅ 正确：用 extend 追加
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.vtsls = { settings = { ... } }
    end,
  },
}
```

### ❌ 同时装 vtsls 和 typescript-tools.nvim

```lua
-- ❌ 坏：两个 TS 语言服务器同时运行，补全和诊断冲突
servers = {
  vtsls = {},
  tsserver = {},  -- 冲突！
}

-- ✅ 正确：只用一个（vtsls 是 LazyVim 推荐的）
servers = {
  vtsls = {},
}
```

### ❌ 不装 prettier 就期望自动格式化

```
症状：保存时代码没格式化
原因：prettier 没装（conform.nvim 只是调度器）
修复：npm install -g prettier 或 :MasonInstall prettier
```

### ❌ 不装 eslint 就期望 lint 警告

```
症状：保存时没有 eslint 警告
原因：eslint 没装（nvim-lint 只是调度器）
修复：项目本地 npm install eslint，或全局 npm install -g eslint
```

### ❌ 用 `lazy = false` 加载 nvim-dap

```lua
-- ❌ 坏：启动时加载调试器
{ "mfussenegger/nvim-dap", lazy = false }

-- ✅ 正确：用 keys 懒加载
{ "mfussenegger/nvim-dap", keys = { "<leader>db" } }
```

## 常见错误

> 概念懂了，实际操作还是会踩坑。

| 错误 | 症状 | 解决 |
|------|------|------|
| 不装 prettier 就期望自动格式化 | 保存时代码没格式化 | `npm install -g prettier` 或 `:MasonInstall prettier` |
| 同时装 vtsls 和 tsserver | 补全和诊断冲突，出现重复提示 | 只用 vtsls（LazyVim 推荐） |
| `opts = { servers = { vtsls = {...} } }` 覆盖全部 | 覆盖了 LazyVim 默认的 lua_ls、jsonls 等 | 用 `opts = function` + 直接赋值 `opts.servers.vtsls = {...}` |
| Tailwind 类名没补全 | 打开 TSX 文件没有 class 提示 | 启用 `lang.tailwindcss` Extra 或手动配 tailwindcss LSP |

---

## 运行验证

所有 Lua 文件可以独立验证语法：

```bash
cd lazyvim/projects/01-ts-fullstack

# 验证 options.lua
nvim --headless -u NONE -c "luafile lua/config/options.lua" -c 'qa!'

# 验证所有 spec 文件
nvim --headless -u NONE -c "luafile lua/plugins/lsp.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/formatting.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/linting.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/extra.lua" -c 'qa!'
# 预期：全部退出码 0
```

> 真实环境验证：把 `lua/` 目录复制到 `~/.config/nvim/`，运行 `:Lazy sync`，
> 打开一个 `.ts` 文件，测试 `gd`（跳转）、`<leader>cf`（格式化）、保存时自动格式化。

---

## 下一步

完成本项目后，你已经有了完整的 TypeScript 全栈开发环境。
继续 [项目 2：Python 后端配置](../02-python-backend/)，学习如何为另一种语言做同样的事。

如果想深入了解每个配置的原理，回到对应章节复习：
- LSP 配置 → [第 12 章](../../12-lsp-mason/)
- 格式化/检查 → [第 14 章](../../14-formatting/)
- DAP 调试 → [第 16 章](../../16-dap/)
- Treesitter → [第 11 章](../../11-treesitter/)
- Extras → [第 19 章](../../19-extras/)

---

## 代码

- [`lua/config/options.lua`](./lua/config/options.lua) — TS 专属选项
- [`lua/plugins/lsp.lua`](./lua/plugins/lsp.lua) — vtsls LSP 配置
- [`lua/plugins/formatting.lua`](./lua/plugins/formatting.lua) — prettier 格式化
- [`lua/plugins/linting.lua`](./lua/plugins/linting.lua) — eslint 检查
- [`lua/plugins/extra.lua`](./lua/plugins/extra.lua) — Tailwind + 调试器 + Treesitter
- [`exercises/`](./exercises/README.md) — 3 道练习
