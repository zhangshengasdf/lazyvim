# 第12章 LSP 语言服务与 Mason — 让 Neovim 真正"懂"代码

> **Treesitter 让 Neovim 看清代码的形状，LSP 让它理解代码的含义。**
> 跳转到定义、查看引用、悬停文档、自动补全、诊断错误……这些 IDE 级别的能力全靠 LSP。
> 而 Mason 让你不用手动安装语言服务器，一条命令搞定一切。
> 本章带你理解 LSP 的工作原理，掌握核心操作快捷键，学会配置 2-3 个典型语言服务器。
> 学完本章，你的 Neovim 能和 VS Code 一样"懂"你的代码。

---

## 本章目标

学完本章，你将能够：

1. **理解 LSP 协议**：客户端-服务器模型、能力协商、消息类型
2. **使用 Mason 安装语言服务器**：`:Mason` 交互界面，自动检测缺失工具
3. **掌握核心 LSP 操作**：`gd`/`gr`/`K`/`<leader>ca`/`<leader>cr` 等快捷键
4. **查看和导航诊断信息**：`<leader>cd`/`]d`/`[d`，理解诊断级别
5. **自定义语言服务器配置**：为 lua_ls、pyright、ts_ls 写自定义设置

> **前置条件**：完成第 11 章（理解 Treesitter）。LSP 和 Treesitter 是互补的——
> Treesitter 提供语法层能力（高亮、文本对象），LSP 提供语义层能力（跳转、补全、诊断）。

---

## 钩子：为什么你的 Neovim 不"懂"代码

打开一个 Python 文件，光标停在 `requests.get` 上，按 `gd`。

没有任何反应。

因为 Neovim 默认不知道 `requests` 是什么、`get` 方法定义在哪里。
它只是一个文本编辑器——看到的是字符，不是"导入的库"和"方法定义"。

现在装一个 Python 语言服务器（pyright），再按 `gd`。

光标跳到了 `requests` 库的 `get` 方法定义处，哪怕那个文件在 `site-packages/` 深处。

**这就是 LSP 的魔力**：它让编辑器从"看文本"升级到"懂代码"。

---

## LSP 是什么

LSP（Language Server Protocol，语言服务器协议）由微软在 2016 年提出，
目的是让一个语言服务器可以被任何编辑器使用，而不是每种编辑器单独写一套代码分析工具。

### 核心模型

```
Neovim（客户端）  ←→  语言服务器（LSP Server）
   │                      │
   │ 打开文件             │ 分析代码
   │ 发送文档内容         │ 返回诊断/补全/定义位置
   │ 请求跳转定义         │ 返回文件+行列号
   └──────────────────────┘
        JSON-RPC 协议
```

**关键点**：语言服务器是一个独立进程，通过 JSON-RPC 与 Neovim 通信。
每种语言有自己的服务器（pyright 对应 Python，ts_ls 对应 TypeScript）。

### LSP 提供的核心能力

| 能力 | 说明 | 对应快捷键 |
|------|------|------------|
| **Goto Definition** | 跳转到符号的定义处 | `gd` |
| **Goto References** | 查看符号的所有引用 | `gr` |
| **Hover** | 悬停显示文档/类型信息 | `K` |
| **Code Action** | 代码操作（快速修复、重构） | `<leader>ca` |
| **Rename** | 重命名符号（所有引用同步更新） | `<leader>cr` |
| **Signature Help** | 函数签名提示（插入模式） | `<C-k>` |
| **Completion** | 自动补全 | 第 13 章详解 |
| **Diagnostics** | 错误/警告/提示 | `<leader>cd`/`]d`/`[d` |
| **Format** | 代码格式化 | `<leader>cf` |
| **Workspace Symbols** | 工作区符号搜索 | `<leader>cs` |

### LSP 消息类型

| 类型 | 方向 | 说明 | 示例 |
|------|------|------|------|
| **Request** | 客户端 → 服务器 | 编辑器请求信息 | "这个符号定义在哪？" |
| **Response** | 服务器 → 客户端 | 服务器返回结果 | "定义在 file.py:42" |
| **Notification** | 双向 | 单向通知，不需要回复 | "文件内容变了" / "诊断结果更新" |

---

## Mason：语言服务器安装管理器

Mason 是 LazyVim 内置的工具安装管理器，专门用来安装和管理 LSP 服务器、
DAP 调试器、linting 工具、格式化工具。它的理念和 npm/pip 类似——
一条命令安装，自动处理依赖和路径。

### 打开 Mason

```vim
:Mason              " 打开 Mason 交互界面
:MasonInstall <pkg> " 安装指定包
:MasonUninstall <pkg> " 卸载指定包
:MasonUpdate        " 更新所有已安装的包
:MasonLog           " 查看安装日志
```

### Mason 交互界面

运行 `:Mason` 后会看到一个分栏界面：

```
  Installed (12)
  ─────────────────────
  ✓ lua-language-server
  ✓ pyright
  ✓ typescript-language-server
  ✓ rust-analyzer
  ✓ css-lsp
  ✓ html-lsp
  ✓ json-lsp
  ✓ eslint-lsp
  ✓ stylua
  ✓ prettier
  ✓ black
  ✓ ruff

  Available (200+)
  ─────────────────────
    gopls
    clangd
    ...
```

在界面中：
- `i` 安装光标下的包
- `u` 更新
- `X` 卸载
- `g?` 查看所有快捷键

### Mason 安装路径

Mason 把工具安装到 `~/.local/share/nvim/mason/` 下：

```
~/.local/share/nvim/mason/
├── bin/           ← 可执行文件（会自动加入 PATH）
│   ├── lua-language-server
│   ├── pyright
│   └── typescript-language-server
├── packages/      ← 工具的完整安装目录
│   ├── lua-language-server/
│   ├── pyright/
│   └── typescript-language-server/
└── registries/    ← 包注册表缓存
```

### mason-lspconfig：Mason 和 lspconfig 的桥梁

LazyVim 内置了 `mason-lspconfig.nvim`，它做了两件事：

1. **自动安装**：你在 `servers` 配置里声明的语言服务器，Mason 会自动安装
2. **自动配置**：安装完成后，自动调用 `lspconfig` 配置服务器

所以你只需要在 spec 里声明"我要用哪些服务器"，剩下的全自动。

---

## 核心 LSP 操作

### 跳转和导航

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `gd` | Goto Definition | 跳转到符号定义处（最常用） |
| `gD` | Goto Declaration | 跳转到声明处（头文件中的前向声明） |
| `gr` | Goto References | 查看符号的所有引用位置（Telescope 浮窗） |
| `gI` | Goto Implementation | 跳转到接口的实现 |
| `gy` | Goto Type Definition | 跳转到类型定义处 |

> 💡 **记忆法**：`g` = goto，`d` = definition，`r` = references，`I` = implementation，`y` = tYpe。

### 信息查看

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `K` | Hover | 悬停显示文档/类型信息（Normal 模式） |
| `<C-k>` | Signature Help | 函数签名提示（Insert 模式） |

按 `K` 时，会弹出一个浮窗，显示光标下符号的文档。
对于函数，会显示参数列表、返回类型、文档字符串。

### 代码操作

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `<leader>ca` | Code Action | 代码操作菜单（快速修复、重构建议） |
| `<leader>cr` | Rename Symbol | 重命名符号（所有引用同步更新） |
| `<leader>cf` | Format | 格式化当前文件/选区 |

**Code Action** 是最强大的 LSP 功能之一。当你看到一个诊断警告时，
按 `<leader>ca` 会显示可用的修复方案：

```
  Code Actions:
  ─────────────────────
  1. Add missing import: 'os'
  2. Add type annotation: str
  3. Disable pylint warning for this line
  4. Extract to variable
```

### 诊断（Diagnostics）

诊断是语言服务器报告的问题（错误、警告、提示、信息）。

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `<leader>cd` | Line Diagnostics | 显示当前行的诊断详情（浮窗） |
| `]d` | Next Diagnostic | 跳转到下一个诊断 |
| `[d` | Previous Diagnostic | 跳转到上一个诊断 |
| `<leader>xx` | Diagnostics (Telescope) | Telescope 显示所有诊断 |
| `<leader>xX` | Buffer Diagnostics | 当前 buffer 所有诊断 |

诊断级别：

| 级别 | 图标 | 含义 | 示例 |
|------|------|------|------|
| Error | `E` | 语法错误、类型错误 | `undefined variable 'foo'` |
| Warning | `W` | 潜在问题 | `unused variable 'x'` |
| Info | `I` | 信息提示 | `consider using list comprehension` |
| Hint | `H` | 改进建议 | `can be simplified to 'return x'` |

---

## 查看 LSP 状态

### `:LspInfo` 命令

```vim
:LspInfo            " 显示当前 buffer 的 LSP 客户端信息
```

输出示例：

```
  Language client log: ~/.local/state/nvim/lsp.log
  Detected filetype: python

  1 client(s) attached to this buffer:

  Client: pyright (id: 1, bufnr: [1])
    filetypes:       python
    cmd:             pyright-langserver --stdio
    root directory:   ~/projects/my-app
    cmd version:     pyright 1.1.350

  Configured servers list: lua_ls, pyright, ts_ls
```

### `:LspLog` 命令

```vim
:LspLog             " 打开 LSP 日志文件（调试用）
```

如果 LSP 行为异常（不响应、补全不工作），先看日志。

### `:checkhealth lspconfig` 命令

```vim
:checkhealth lspconfig  " 检查 LSP 配置健康状态
```

---

## 配置语言服务器

LazyVim 通过 `nvim-lspconfig` 插件配置语言服务器。
你需要在 `lua/plugins/lsp.lua` 里声明要用哪些服务器及其选项。

### 基本结构

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- 你要用的语言服务器
        lua_ls = { ... },
        pyright = { ... },
        ts_ls = { ... },
      },
    },
  },
}
```

### 示例 1：Lua 语言服务器（lua_ls）

lua_ls 是 Lua 的语言服务器，LazyVim 已内置。
但如果你想让它识别 Neovim 的 API，需要额外配置：

```lua
servers = {
  lua_ls = {
    settings = {
      Lua = {
        workspace = {
          -- 添加 Neovim 运行时文件到工作区
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,  -- 不询问是否添加第三方库
        },
        diagnostics = {
          -- 识别 `vim` 全局变量（避免 "undefined global 'vim'" 警告）
          globals = { "vim" },
        },
        completion = {
          callSnippet = "Replace",  -- 补全函数时展开参数片段
        },
        telemetry = {
          enable = false,  -- 关闭遥测
        },
      },
    },
  },
}
```

> 💡 LazyVim 已经为 lua_ls 做了合理的默认配置（包括识别 `vim` 全局变量和运行时库）。
> 上面的配置展示的是如何在默认基础上微调。

### 示例 2：Python 语言服务器（pyright）

pyright 是 Python 的类型检查器和语言服务器：

```lua
servers = {
  pyright = {
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic",  -- basic/strict/off
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace",  -- 分析整个工作区（不只是打开的文件）
        },
      },
    },
  },
}
```

> ⚠️ **pyright vs pylsp**：pyright 专注于类型检查和补全，pylint/ruff 负责 linting。
> LazyVim 默认用 pyright，一般不需要换。

### 示例 3：TypeScript 语言服务器（ts_ls）

ts_ls 是 TypeScript/JavaScript 的官方语言服务器：

```lua
servers = {
  ts_ls = {
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
    },
  },
}
```

### 多服务器配置

一个 `servers` table 可以声明多个服务器：

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = { Lua = { diagnostics = { globals = { "vim" } } } },
        },
        pyright = {
          settings = { python = { analysis = { typeCheckingMode = "basic" } } },
        },
        ts_ls = {},  -- 用默认配置（空 table）
      },
    },
  },
}
```

> 💡 **空 table `{}` 表示用默认配置**。不是所有服务器都需要自定义设置。
> 用默认配置时，Mason 会自动安装，lspconfig 会用它的默认 settings。

---

## LSP 与 Treesitter 的关系

| 维度 | Treesitter | LSP |
|------|-----------|-----|
| **理解层次** | 语法（代码的形状） | 语义（代码的含义） |
| **工作范围** | 当前文件 | 整个项目/工作区 |
| **需要安装** | 解析器（.so 文件） | 语言服务器（独立进程） |
| **实时性** | 即时（编辑时更新语法树） | 稍有延迟（分析需要时间） |
| **高亮** | 基于语法节点（精确） | 语义高亮（基于类型信息） |
| **跳转** | 基于语法树（文本对象） | 基于语义分析（跨文件跳转） |
| **补全** | 基于当前文件的语法 | 基于整个项目的类型信息 |

**两者配合**：Treesitter 负责高亮和文本对象（快、准），LSP 负责跳转、补全、诊断（跨文件、语义级）。
缺了任何一个，Neovim 的代码智能都会大打折扣。

---

## 反模式（什么不该做）

### ❌ 手动下载语言服务器二进制文件

```bash
# ❌ 坏：手动下载到 /usr/local/bin/
curl -L https://github.com/.../lua-language-server -o /usr/local/bin/lua-language-server

# ✅ 正确：用 Mason 自动管理
:MasonInstall lua-language-server
```

### ❌ 不配置 servers 就抱怨 LSP 不工作

```lua
-- ❌ 坏：没声明服务器，LSP 不会启动
return {
  { "neovim/nvim-lspconfig" },  -- 没有 servers 配置
}

-- ✅ 正确：声明你需要的服务器
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {},
        pyright = {},
      },
    },
  },
}
```

### ❌ 用 `vim.api.nvim_set_keymap` 设置 LSP 快捷键

```lua
-- ❌ 坏：已弃用的 API
vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {})

-- ✅ 正确：LSP 快捷键由 on_attach 自动绑定，不需要手动设置
-- LazyVim 已经为所有 LSP 操作绑定了默认快捷键
```

### ❌ 在 servers 配置里写 require

```lua
-- ❌ 坏：servers 里的值会在插件加载前求值，此时 lspconfig 还没加载
servers = {
  lua_ls = require("my-lua-config"),  -- 报错！
}

-- ✅ 正确：直接写 table，不要 require
servers = {
  lua_ls = {
    settings = { Lua = { diagnostics = { globals = { "vim" } } } },
  },
}
```

### ❌ 同时装多个同语言的 LSP

```lua
-- ❌ 坏：pyright 和 pylsp 同时运行，补全和诊断冲突
servers = {
  pyright = {},
  pylsp = {},  -- 冲突！
}

-- ✅ 正确：每种语言只用一个 LSP
servers = {
  pyright = {},  -- 只用 pyright
}
```

---

## 运行验证

本章的 `lua/plugins/lsp.lua` 包含 3 个典型语言服务器的配置示例。

```bash
cd lazyvim/12-lsp-mason

# 验证 init.lua（pcall guard 模式）
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
# 预期：退出码 0

# 验证 lsp.lua（return { ... } 形式）
nvim --headless -u NONE -c "luafile lua/plugins/lsp.lua" -c 'qa!'
# 预期：退出码 0（spec table 被创建并丢弃）
```

> 💡 **真实环境验证**：把 `lua/plugins/lsp.lua` 复制到
> `~/.config/nvim/lua/plugins/`，运行 `:Lazy sync`，然后打开对应语言的文件，
> 运行 `:LspInfo` 确认服务器已连接。

---

## 下一步

LSP 提供了代码智能的"大脑"，但自动补全还需要"眼睛"——补全引擎。
第 13 章会深入补全系统，把 LSP 和 Treesitter 的能力通过 nvim-cmp 展现出来。

- **第 13 章「补全」**：nvim-cmp 配置、补全源、片段展开
- **第 14 章「格式化」**：conform.nvim 配置、保存时自动格式化

> 💡 **本章核心**：LSP 是 Neovim 变成 IDE 的关键。Mason 让安装语言服务器变得零门槛。
> `gd`/`gr`/`K`/`<leader>ca`/`<leader>cr` 是你每天会按几百次的快捷键，务必记住。

---

## 代码

- [`lua/init.lua`](./lua/init.lua) — pcall guard 模式（LSP 模块加载保护）
- [`lua/plugins/lsp.lua`](./lua/plugins/lsp.lua) — 语言服务器配置示例
- [`exercises/`](./exercises/README.md) — 4 道练习题

**上一章**：[11-treesitter](../11-treesitter/)（Treesitter 语法引擎）
**下一章**：[13-completion](../13-completion/)（自动补全）
