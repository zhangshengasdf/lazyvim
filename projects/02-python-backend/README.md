# 项目 2：Python 后端配置 — 让 LazyVim 成为 Python IDE

> **项目 1 帮你配好了 TypeScript，这个项目用同样的方法配 Python。**
> pyright 类型检查、black 格式化、ruff 代码检查、debugpy 断点调试……
> 四件套配齐，你的 Python 后端开发体验不输 PyCharm。

---

## TL;DR

> **30 秒速读**：Python 后端四件套——pyright 类型检查 + black 格式化 + ruff lint + debugpy 调试，配置模式和 TS 项目一样。
> 
> **如果只记一件事**：pyright 会自动查找 `.venv` 虚拟环境，但你得先激活它或把 `.venv` 放在项目根目录。

---

## 项目目标

为 Python 后端开发配置 LazyVim，实现：

1. **LSP**：pyright 提供类型检查、跳转、补全、诊断
2. **格式化**：black 保存时自动格式化（PEP 8 风格）
3. **代码检查**：ruff 实时 lint（比 pylint 快 10-100 倍）
4. **调试器**：debugpy 断点调试（支持 FastAPI/Flask/Django）
5. **Treesitter**：Python/HTML/SQL/YAML 语法高亮和文本对象

学完本项目，你的 Neovim 会成为一台高效的 Python 后端开发机器。

---

## 钩子：Python 开发者的 Neovim 困境

打开一个 Python 文件，你会遇到这些问题：

| 问题 | 原因 | 后果 |
|------|------|------|
| `import requests` 后 `requests.get` 没有补全 | pyright 没配好 | 手动查文档 |
| 保存时代码没有自动格式化 | black 没配好 | 风格不一致 |
| pylint 太慢，每次保存等 3 秒 | pylint 是纯 Python 实现 | 开发体验差 |
| 调试只能用 `print` | debugpy 没配好 | 排查 bug 低效 |
| 虚拟环境识别不到 | pyright 不知道 venv 路径 | 类型检查报错 |

这个项目把这 5 个问题全部解决。

---

## 所需 Extras

LazyVim 的 Extras 系统（第 19 章）提供了预配置的 Python 支持：

| Extra | 路径 | 提供的能力 |
|-------|------|-----------|
| Python | `lazyvim.plugins.extras.lang.python` | pyright LSP、debugpy DAP、ruff linter |
| JSON | `lazyvim.plugins.extras.lang.json` | jsonls LSP、schemastore |

启用方式：在 Neovim 中运行 `:LazyExtras`，搜索并启用 `python` Extra。

> 本项目的配置文件是**独立于 Extras 的完整方案**。
> 如果你同时启用 Python Extra，本项目的配置会 extend Extra 的默认值。

---

## 完整配置方案

### 架构图

```
~/.config/nvim/
├── lua/
│   └── plugins/
│       ├── lsp.lua              ← 项目 2 提供：pyright LSP 配置
│       ├── formatting.lua       ← 项目 2 提供：black 格式化
│       ├── linting.lua          ← 项目 2 提供：ruff 检查
│       └── dap.lua              ← 项目 2 提供：debugpy 调试器
└── init.lua                     ← LazyVim 入口（不需要改）
```

### 各文件职责

| 文件 | 对应章节 | 核心配置 |
|------|----------|----------|
| `lua/plugins/lsp.lua` | Ch12（LSP） | pyright 服务器配置、虚拟环境检测 |
| `lua/plugins/formatting.lua` | Ch14（格式化） | black 格式化器、行宽设置 |
| `lua/plugins/linting.lua` | Ch14（检查） | ruff linter 配置（替代 pylint） |
| `lua/plugins/dap.lua` | Ch16（DAP） | debugpy 调试器、FastAPI/Flask 启动配置 |

### 配置合并关系

```
LazyVim 默认 spec
      │
      ▼
lua/plugins/lsp.lua        ← extend servers（追加 pyright settings）
      │
      ▼
lua/plugins/formatting.lua ← extend formatters_by_ft（追加 black 选项）
      │
      ▼
lua/plugins/linting.lua    ← extend linters_by_ft（追加 ruff）
      │
      ▼
lua/plugins/dap.lua        ← 追加 debugpy + FastAPI/Flask 调试配置
```

每个文件都用 **extend 模式**（`opts = function(_, opts)`），不覆盖 LazyVim 默认值。

---

## 各文件详解

### lua/plugins/lsp.lua

配置 pyright 语言服务器：

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
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
- pyright 是 TypeScript 团队开发的 Python 类型检查器
- `typeCheckingMode` 有三个级别：`off` / `basic` / `strict`
- `autoSearchPaths` 自动搜索项目中的导入路径
- 虚拟环境检测：pyright 会自动查找 `.venv` 或 `venv` 目录

### lua/plugins/formatting.lua

配置 black 格式化器：

```lua
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.python = { "black" }
      opts.formatters = opts.formatters or {}
      opts.formatters.black = {
        prepend_args = { "--line-length", "88" },
      }
    end,
  },
}
```

关键点：
- black 的默认行宽是 88（PEP 8 推荐 79，black 用 88 更宽松）
- 用 `prepend_args` 传参给 black CLI
- black 不支持太多配置选项（这是它的设计理念：少争论，多写代码）

### lua/plugins/linting.lua

配置 ruff linter（替代 pylint）：

```lua
return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.python = { "ruff" }
    end,
  },
}
```

关键点：
- ruff 用 Rust 写的，比 pylint 快 10-100 倍
- ruff 同时支持 linting 和 formatting（但这里只用它做 linting）
- ruff 的规则覆盖了 pylint、flake8、isort 等多个工具

### lua/plugins/dap.lua

配置 debugpy 调试器：

```lua
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "mfussenegger/nvim-dap-python",
        config = function()
          local ok, dap_python = pcall(require, "dap-python")
          if ok then
            dap_python.setup("python")
          end
        end,
      },
    },
    keys = {
      { "<leader>dP", function() require("dap-python").debug_selection() end, desc = "DAP: 调试选中的 Python 代码" },
    },
  },
}
```

关键点：
- nvim-dap-python 是 Python 调试适配器
- `setup("python")` 使用系统 python 或虚拟环境中的 python
- 支持 FastAPI/Flask/Django 的调试（需要配置 launch 参数）

---

## pyright vs pylsp vs jedi

Python 有三个主流语言服务器，选哪个？

| 语言服务器 | 优势 | 劣势 | LazyVim 推荐 |
|-----------|------|------|-------------|
| **pyright** | 类型检查强、速度快、VS Code 同款 | 不支持重构（rename 有限） | 是 |
| **pylsp** | 插件生态丰富、支持重构 | 慢、配置复杂 | 否 |
| **jedi** | 轻量、补全快 | 功能少、没有类型检查 | 否 |

**结论**：用 pyright。它是 TypeScript 团队开发的，类型检查和补全都是最好的。
LazyVim 默认用 pyright，不需要换。

---

## ruff vs pylint vs flake8

Python linter 之争：

| linter | 速度 | 规则覆盖 | 配置 | 推荐 |
|--------|------|----------|------|------|
| **ruff** | 极快（Rust） | 覆盖 pylint + flake8 + isort | pyproject.toml | 是 |
| **pylint** | 慢（Python） | 最全面 | .pylintrc | 否（太慢） |
| **flake8** | 中等 | 基础 | setup.cfg | 否（功能少） |

**结论**：用 ruff。它用 Rust 写的，速度快 10-100 倍，规则覆盖最全面。
而且 ruff 还能做 formatting（替代 black），但这里我们用 black 做格式化（分工更清晰）。

---

## 反模式（什么不该做）

### ❌ 同时装 pyright 和 pylsp

```lua
-- ❌ 坏：两个 Python 语言服务器同时运行，补全和诊断冲突
servers = {
  pyright = {},
  pylsp = {},  -- 冲突！
}

-- ✅ 正确：只用 pyright
servers = {
  pyright = {},
}
```

### ❌ 用 pylint 而不是 ruff

```
症状：保存文件时等 3 秒才有 lint 结果
原因：pylint 是纯 Python 实现，分析整个项目很慢
修复：换 ruff（Rust 实现，快 10-100 倍）
```

### ❌ 不配置虚拟环境就用 pyright

```
症状：pyright 报错 "cannot import module 'fastapi'"
原因：pyright 不知道你的虚拟环境在哪里
修复：pyright 会自动查找 .venv 或 venv 目录
     如果不在标准位置，在 pyrightconfig.json 里配置 venvPath
```

### ❌ 用 `opts = { servers = { pyright = {...} } }` 覆盖

```lua
-- ❌ 坏：覆盖了 LazyVim 默认的其他服务器
return {
  { "neovim/nvim-lspconfig", opts = { servers = { pyright = {...} } } },
}

-- ✅ 正确：用 extend 追加
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.pyright = { settings = { ... } }
    end,
  },
}
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
| pyright 报 "cannot import module" | 类型检查找不到第三方库 | 确认 `.venv` 在项目根目录，或配 `pyrightconfig.json` 的 `venvPath` |
| 用 pylint 而不是 ruff | 保存文件等 3 秒才有 lint 结果 | 换 ruff（Rust 实现，快 10-100 倍） |
| 同时装 pyright 和 pylsp | 补全和诊断冲突 | 只用 pyright |
| debugpy 断点不生效 | 设了断点但程序直接跑完 | 确认用 `<leader>dc` 启动调试，且 `:Mason` 里 debugpy 已安装 |

---

## 运行验证

所有 Lua 文件可以独立验证语法：

```bash
cd lazyvim/projects/02-python-backend

# 验证所有 spec 文件
nvim --headless -u NONE -c "luafile lua/plugins/lsp.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/formatting.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/linting.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/dap.lua" -c 'qa!'
# 预期：全部退出码 0
```

> 真实环境验证：把 `lua/plugins/` 目录复制到 `~/.config/nvim/lua/plugins/`，
> 运行 `:Lazy sync`，打开一个 `.py` 文件，测试 `gd`（跳转）、`<leader>cf`（格式化）。

---

## 下一步

完成本项目后，你已经有了完整的 Python 后端开发环境。
继续 [项目 3：Markdown 写作](../03-markdown-writing/)，或者回到教程主线：

- LSP 配置原理 → [第 12 章](../../12-lsp-mason/)
- 格式化/检查原理 → [第 14 章](../../14-formatting/)
- DAP 调试原理 → [第 16 章](../../16-dap/)
- Extras 系统 → [第 19 章](../../19-extras/)

---

## 代码

- [`lua/plugins/lsp.lua`](./lua/plugins/lsp.lua) — pyright LSP 配置
- [`lua/plugins/formatting.lua`](./lua/plugins/formatting.lua) — black 格式化
- [`lua/plugins/linting.lua`](./lua/plugins/linting.lua) — ruff 检查
- [`lua/plugins/dap.lua`](./lua/plugins/dap.lua) — debugpy 调试器
- [`exercises/`](./exercises/README.md) — 3 道练习
