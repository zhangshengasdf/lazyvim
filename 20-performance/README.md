# 第20章 性能优化与健康检查 — 让配置跑得快、活得久

> **一句话钩子**：你的 Neovim 启动要 2 秒以上？每次打开大文件都要等 3 秒？LSP 莫名其妙罢工？
> 这不是 Neovim 的问题，而是你的配置还没优化过。跨过这道坎，
> 你会发现启动时间从秒级压到毫秒级，大文件编辑丝滑流畅，LSP 再也不闹脾气。

这是教程的最后一章。前 19 章你学会了从零搭建 LazyVim 配置，这一章帮你把配置打磨成生产级状态——启动快、无警告、大文件不卡。

---

## 本章目标

学完本章，你将能够：

1. **运行 `:checkhealth` 诊断配置健康**：读懂输出，修复 LSP/Treesitter/终端相关的警告
2. **用 `:Lazy profile` 分析启动耗时**：找到最慢的插件，量化优化效果
3. **优化懒加载策略**：把 `event` 降级为 `keys`/`ft`/`cmd`，减少不必要的加载
4. **禁用 Neovim 内置插件和 provider**：`vim.g.loaded_*_provider = 0` + `performance.rtp.disabled_plugins`
5. **调整 `vim.opt` 性能选项**：`lazyredraw`、`synmaxcol`、`timeoutlen` 等
6. **排查常见问题**：Treesitter 解析器缺失、LSP 启动失败、大文件卡顿
7. **用 `:Lazy debug` 抓取调试日志**：提交 issue 时附带完整诊断信息

> ⚠️ **前置条件**：完成第 04-06 章（装好 LazyVim，理解 lazy.nvim spec 和懒加载）。
> 本章是 Part 6 的唯一章节，也是整个教程的收尾。前 19 章的知识在这里汇总。

---

## 第一步：建立基准线

优化之前先量。没有基准线的优化是瞎猜。

```bash
nvim --startuptime /tmp/startup.log -c 'qa!'
tail -1 /tmp/startup.log          # "finished in XXms"
```

**健康基准线**：

| 指标 | 优秀 | 合格 | 需要优化 |
|------|------|------|----------|
| 启动时间 | < 50ms | 50-100ms | > 100ms |
| 插件总数 | 30-50 | 50-80 | > 100 |
| 懒加载比例 | > 80% | 60-80% | < 60% |
| `:checkhealth` 警告 | 0 | 1-2 | > 3 |

---

## `:checkhealth` 健康检查

`:checkhealth` 是 Neovim 内置的诊断工具，检查你的环境是否健康。
LazyVim 扩展了它的检查范围。

### 运行方式

```vim
:checkhealth           " 完整检查（输出很长）
:checkhealth lazyvim   " 只检查 LazyVim 相关
:checkhealth lsp       " 只检查 LSP
:checkhealth treesitter " 只检查 Treesitter
:checkhealth provider  " 只检查 provider（Python/Node/Ruby/Perl）
```

### 常见输出解读

```
────────────────────────────────────────────
lazyvim: require("lazyvim.health").check()

Checking ~
- OK: Neovim version >= 0.9.0
- OK: Git >= 2.19.0
- OK: ripgrep found (rg 14.1.0)
- WARNING: fd not found. Install https://github.com/sharkdp/fd
- OK: lazy.nvim installed
- OK: Treesitter parsers installed

Checking providers ~
- WARNING: No Python provider. Run :checkhealth provider
- WARNING: No Node provider. Run :checkhealth provider
- OK: Perl provider disabled (good for perf)
```

| 级别 | 含义 | 处理方式 |
|------|------|----------|
| `OK` | 正常 | 不用管 |
| `WARNING` | 可能有问题 | 建议修复，但不致命 |
| `ERROR` | 必须修复 | 某功能完全不工作 |

### 常见 WARNING 修复速查

| WARNING | 原因 | 修复命令（macOS / Ubuntu） |
|---------|------|---------------------------|
| `No clipboard tool found` | Linux 缺剪贴板工具 | `brew install xclip` / `sudo apt install xclip` |
| `fd not found` | Telescope 文件搜索依赖 | `brew install fd` / `sudo apt install fd-find` |
| `ripgrep not found` | Telescope 全文搜索依赖 | `brew install ripgrep` / `sudo apt install ripgrep` |
| `No Python provider` | 你主动禁用了（`vim.g.loaded_python3_provider = 0`） | 通常可忽略，除非你需要 pynvim |

> 💡 Ubuntu 的 `fd` 命令名是 `fdfind`，需要 `sudo ln -s $(which fdfind) /usr/local/bin/fd`。

---

## `:Lazy profile` 启动时间分析

这是性能调优的核心工具。它显示每个插件的加载耗时。

### 运行方式

```vim
:Lazy profile
```

输出类似：

```
Startuptime: 48.3ms

  loaded  2.1ms  folke/tokyonight.nvim          (colorscheme)
  loaded  1.8ms  folke/lazy.nvim                 (startup)
  loaded  3.2ms  nvim-treesitter/nvim-treesitter  (BufReadPost)
  loaded 12.4ms  neovim/nvim-lspconfig           (BufReadPost)
  loaded  8.7ms  hrsh7th/nvim-cmp                (InsertEnter)
  loaded  0.9ms  folke/which-key.nvim            (VeryLazy)
  loaded  0.3ms  lewis6991/gitsigns.nvim          (BufReadPost)
  ...
```

### 读懂 profile 输出

| 列 | 含义 |
|------|------|
| `loaded` / `skipped` | 插件是否已加载 |
| 时间（ms） | 该插件的加载耗时 |
| 插件名 | 插件标识 |
| 括号内 | 触发加载的事件/按键 |

**找最慢的 5 个插件**，它们占了 80% 的启动时间。

### 优化策略：event → keys/ft/cmd

profile 里看到 `event = "BufReadPost"` 的插件如果启动时就加载了，
说明它加载得太早。考虑降级：

```
降级路径（从宽到窄）：
  event = "BufReadPost"   → 每次打开文件都加载（最宽）
  event = "VeryLazy"      → Neovim 启动后 100ms 加载（中等）
  ft = { "lua", "python" } → 只打开特定文件类型时加载（窄）
  keys = { "<leader>xx" }  → 只按键时加载（最窄）
  cmd = { "SomeCmd" }      → 只运行命令时加载（最窄）
```

**实际案例**：

```lua
-- 优化前：每次打开文件都加载（12ms）
{ "neovim/nvim-lspconfig", event = "BufReadPost" }

-- 优化后：只在打开特定文件类型时加载（0ms，按需加载）
{ "neovim/nvim-lspconfig", ft = { "lua", "python", "typescript", "go" } }
```

> ⚠️ **不要过度懒加载**：`nvim-lspconfig` 如果用 `keys` 懒加载，
> 打开文件后 LSP 不会自动启动，需要按键才触发。这通常不是你想要的。
> 语言专属插件用 `ft` 最合理。

---

## 禁用 Neovim 内置插件和 provider

Neovim 自带一些你大概率用不到的内置插件和 provider。禁用它们可以减少 10-30ms。

### 禁用 provider（vim.g.loaded_*_provider）

```lua
-- lua/init.lua 顶部（必须在 lazy.nvim 加载之前）
vim.g.loaded_perl_provider = 0   -- 大多数人不用 Perl
vim.g.loaded_ruby_provider = 0   -- 大多数人不用 Ruby
-- vim.g.loaded_python3_provider = 0  -- 只用 LSP 补全时可禁用
-- vim.g.loaded_node_provider = 0     -- 不用 coc.nvim 时可禁用
```

| Provider | 常见依赖插件 | 禁用建议 |
|----------|-------------|----------|
| Python3 | rope、jedi、pynvim | 只用 LSP 补全时可禁用 |
| Node | coc.nvim、markdown-preview | 不用 coc.nvim 时可禁用 |
| Ruby | neovim-ruby-host | 大多数人可禁用 |
| Perl | 无常见依赖 | 除非写 Perl，否则禁用 |

### 禁用内置 runtime 插件（performance.rtp.disabled_plugins）

Neovim 自带的 Vim 时代内置插件，现代插件已完全取代：

```lua
performance = {
  rtp = {
    disabled_plugins = {
      "gzip",          -- 读写 .gz 文件
      "matchit",       -- % 跳转增强（treesitter 已替代）
      "matchparen",    -- 括号匹配（mini.pairs 已替代）
      "netrwPlugin",   -- 内置文件浏览器（Neo-tree 已替代）
      "tarPlugin",     -- 读写 .tar
      "tohtml",        -- buffer 转 HTML
      "tutor",         -- Vim 教程
      "zipPlugin",     -- 读写 .zip
    },
  },
},
```

> ⚠️ 禁用 `matchparen` 前确认你装了 mini.pairs 或 nvim-autopairs。
> 禁用 `netrwPlugin` 后 `:Explore` 会失效（你已有 Neo-tree）。

---

## `vim.opt` 性能选项

```lua
-- lua/config/options.lua
vim.opt.lazyredraw = true     -- 宏录制时禁用重绘（大文件卡顿时有用）
vim.opt.synmaxcol = 300       -- 语法高亮最大列数（超过不解析，防大文件卡顿）
vim.opt.timeoutlen = 300      -- 按键序列等待时间（默认 1000，300 是好平衡）
vim.opt.updatetime = 200      -- CursorHold 触发间隔（默认 4000，200 更响应式）
vim.opt.swapfile = false      -- 有 git 时可关（减少磁盘写入）
vim.opt.undofile = true       -- 持久化撤销历史（推荐开）
```

### 大文件优化

当文件超过一定大小，Treesitter、LSP、语法高亮都会拖慢。
LazyVim 内置了大文件检测（> 1MB 或 > 10000 行时自动禁用 Treesitter），
你不需要手动配置。自定义阈值见下方"常见问题排查"。

---

## 常见问题排查

### Treesitter 解析器缺失

**症状**：打开某语言文件没有语法高亮。

```vim
:checkhealth treesitter   " 查看缺失的解析器
:TSInstall lua            " 安装单个解析器
:TSUpdate                 " 更新所有已安装的解析器
```

推荐在 spec 里用 `ensure_installed` 自动安装（extend 不 overwrite，第 06 章铁律）：

```lua
{ "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, { "lua", "vim", "markdown" })
  end }
```

### LSP 启动失败

**症状**：打开文件没有补全、跳转、诊断。

```vim
:checkhealth lsp    " LSP 全面检查
:LspInfo            " 当前 buffer 的 LSP 状态
:Mason              " 查看已安装的 LSP 列表
```

| 症状 | 原因 | 修复 |
|------|------|------|
| `LSP server not found` | LSP 没装 | `:Mason` 里安装对应 LSP |
| `LSP server failed to start` | 二进制损坏 | `:Mason` 里重装 |
| `No LSP attached` | ft 懒加载没触发 | 确认 `ft` 包含你的文件类型 |

### 大文件卡顿

LazyVim 内置了大文件检测（文件 > 1MB 或行数 > 10000 时自动禁用 Treesitter）。
如需自定义阈值：

```lua
-- lua/config/autocmds.lua
vim.api.nvim_create_autocmd("BufReadPre", {
  desc = "大文件禁用 Treesitter",
  group = vim.api.nvim_create_augroup("bigfile", { clear = true }),
  pattern = "*",
  callback = function(args)
    if vim.fn.getfsize(args.match) > 1500000 or vim.fn.line("$") > 10000 then
      vim.bo.syntax = ""
      vim.treesitter.stop()
    end
  end,
})
```

---

## `:Lazy debug` 调试模式

当其他方法都找不到问题时，用 `:Lazy debug` 抓取完整日志。

```vim
:Lazy debug    " 启用详细日志，重启 Neovim 收集
```

日志写到 `~/.local/state/nvim/lazy-debug.log`。适用场景：
- 插件加载顺序异常或依赖冲突
- 懒加载不触发
- 提交 GitHub issue 时附带日志

---

## 优化清单（可量化）

按以下顺序优化，每步用 `:Lazy profile` 对比：

| 步骤 | 操作 | 预期收益 |
|------|------|----------|
| 1 | `:Lazy profile` 记录基准线 | 建立基准 |
| 2 | 禁用不需要的 provider | 5-15ms |
| 3 | 禁用内置 runtime 插件（`disabled_plugins`） | 5-10ms |
| 4 | `event` → `ft`/`keys` 降级 | 10-30ms |
| 5 | `lazyredraw` + `synmaxcol` | 大文件流畅 |
| 6 | 减少插件总数 | 5-20ms |
| 7 | `:checkhealth` 修复所有 WARNING | 配置健康 |

**目标**：启动 < 50ms，`:checkhealth` 无 ERROR，WARNING < 2。

---

## 反模式（什么不该做）

### ❌ 盲目禁用所有内置插件

```lua
-- ❌ 坏：禁用了 matchparen 但没装替代插件，括号匹配消失了
disabled_plugins = { "matchit", "matchparen", ... }

-- ✅ 正确：确认有替代再禁用
-- matchparen → mini.pairs 或 nvim-autopairs
-- netrwPlugin → Neo-tree
-- gzip/tar/zip → 你真的不需要读压缩文件？
```

### ❌ 用 `event` 代替 `ft` 加载语言插件

```lua
-- ❌ 坏：所有文件打开都加载 Go LSP（浪费 10ms）
{ "ray-x/go.nvim", event = "BufReadPost" }

-- ✅ 正确：只在打开 Go 文件时加载
{ "ray-x/go.nvim", ft = { "go", "gomod" } }
```

### ❌ 把 `timeoutlen` 设太低

```lua
-- ❌ 坏：50ms 太快，按键序列来不及完成
vim.opt.timeoutlen = 50

-- ✅ 正确：200-300ms 是个好平衡
vim.opt.timeoutlen = 300
```

### ❌ 不记录基准线就优化

```
❌ 坏：凭感觉改配置，不知道有没有效果
✅ 正确：先 nvim --startuptime /tmp/before.log，优化后再测，对比数据
```

### ❌ 给所有插件都加 `lazy = false`

```lua
-- ❌ 坏：50 个插件全部 lazy = false，启动 500ms
-- ✅ 正确：只给配色和 UI 框架加 lazy = false，其他用 event/ft/keys/cmd
```

---

## 运行验证

本章的 `lua/init.lua` 演示了性能优化配置，`lua/plugins/performance.lua` 包含插件级优化。

```bash
cd lazyvim/20-performance

# 验证 init.lua（含 disabled_plugins 和 provider 禁用）
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

# 验证 performance.lua（lazy.nvim performance spec）
nvim --headless -u NONE -c "luafile lua/plugins/performance.lua" -c 'qa!'
```

预期：退出码 0，无错误。

> 💡 **真实环境验证**：把 `lua/plugins/performance.lua` 复制到
> `~/.config/nvim/lua/plugins/` 下，重启 Neovim，运行 `:Lazy profile` 对比前后。

---

## 下一步

恭喜你完成了整个 LazyVim 渐进式教程！20 章的旅程：

- **Part 0（Ch01-03）**：Vim 模态编辑基本功
- **Part 1（Ch04-06）**：LazyVim 架构和 lazy.nvim
- **Part 2（Ch07-10）**：Leader 键、which-key、Telescope、Neo-tree
- **Part 3（Ch11-14）**：Treesitter、LSP、补全、格式化
- **Part 4（Ch15-16）**：Git 集成和 DAP 调试
- **Part 5（Ch17-19）**：插件配置模式、自定义快捷键、Extras
- **Part 6（Ch20，本章）**：性能优化与健康检查

你已具备从零搭建、深度定制、性能优化 LazyVim 的完整能力。

**接下来**：进入 [实战项目](../projects/)，把知识组装成 4 套完整配置方案。

---

## 代码

- [`lua/init.lua`](./lua/init.lua) — 禁用 provider + disabled_plugins 配置
- [`lua/plugins/performance.lua`](./lua/plugins/performance.lua) — lazy.nvim performance 优化 spec
- [`exercises/`](./exercises/README.md) — 4 道练习题（健康检查、profile 分析、优化实操、debug 日志）

**上一章**：[19-extras](../19-extras/)（LazyVim Extras）
**下一章**：[projects/](../projects/)（实战项目）
