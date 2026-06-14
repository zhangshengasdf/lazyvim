# 第20章 练习 — 性能优化与健康检查

> 做练习前先读完 [本章 README](../README.md)。练习答案先自己想，实在不会再看参考。

---

## 练习 1：读懂 `:checkhealth` 输出

**题目**：以下是某用户的 `:checkhealth lazyvim` 输出（节选），分析每个 WARNING 并给出修复方案：

```
────────────────────────────────────────────
lazyvim: require("lazyvim.health").check()

Checking ~
- OK: Neovim version >= 0.9.0
- OK: Git >= 2.19.0
- WARNING: ripgrep not found. Install https://github.com/BurntSushi/ripgrep
- WARNING: fd not found. Install https://github.com/sharkdp/fd
- OK: lazy.nvim installed

Checking providers ~
- WARNING: No Python provider (disabled). Set `vim.g.loaded_python3_provider` to 1 to enable.
- WARNING: No Node provider (disabled). Set `vim.g.loaded_node_provider` to 1 to enable.
- WARNING: No Ruby provider (disabled). Set `vim.g.loaded_ruby_provider` to 1 to enable.
- OK: Perl provider disabled (good for perf)
```

**问题**：
1. 哪些 WARNING 必须修复？为什么？
2. 哪些 WARNING 可以忽略？为什么？
3. 写出修复命令（针对必须修复的项）。

**参考答案**：

必须修复的：
- `ripgrep not found`：Telescope 全文搜索依赖 ripgrep，没有它 `<leader>fg` 不工作。
  修复：`brew install ripgrep`（macOS）或 `sudo apt install ripgrep`（Ubuntu）
- `fd not found`：Telescope 文件搜索依赖 fd，没有它 `<leader>ff` 变慢（回退到 find）。
  修复：`brew install fd`（macOS）或 `sudo apt install fd-find`（Ubuntu），Ubuntu 需要 `sudo ln -s $(which fdfind) /usr/local/bin/fd`

可以忽略的：
- Python/Node/Ruby provider 警告：这些是你主动禁用的（`vim.g.loaded_*_provider = 0`），
  说明你不需要这些语言的 Neovim 插件。WARNING 只是提醒你"provider 被禁用了"，
  不是说环境有问题。如果你确实需要某个 provider，去掉对应的 `vim.g.loaded_*_provider = 0` 即可。

---

## 练习 2：分析 `:Lazy profile` 输出

**题目**：以下是某用户的 `:Lazy profile` 输出，分析并回答问题：

```
Startuptime: 187.3ms

  loaded  2.1ms  folke/tokyonight.nvim          (colorscheme)
  loaded  1.8ms  folke/lazy.nvim                 (startup)
  loaded 45.2ms  nvim-treesitter/nvim-treesitter  (BufReadPost)
  loaded 32.1ms  neovim/nvim-lspconfig           (BufReadPost)
  loaded 28.7ms  hrsh7th/nvim-cmp                (InsertEnter)
  loaded 15.3ms  folke/which-key.nvim            (VeryLazy)
  loaded 12.4ms  lewis6991/gitsigns.nvim          (BufReadPost)
  loaded  8.7ms  folke/telescope.nvim             (BufReadPost)
  loaded  5.2ms  nvim-neo-tree/neo-tree.nvim      (BufReadPost)
  loaded  3.1ms  folke/todo-comments.nvim         (VeryLazy)
  loaded  2.8ms  folke/trouble.nvim               (VeryLazy)
  loaded  1.2ms  echasnovski/mini.ai              (BufReadPost)
  loaded  0.8ms  echasnovski/mini.pairs           (BufReadPost)
```

**问题**：
1. 找出最慢的 3 个插件，计算它们占总启动时间的百分比。
2. 哪些插件可以从 `event = "BufReadPost"` 降级为 `ft` 或 `keys`？列出具体方案。
3. 优化后的预期启动时间大约是多少？

**参考答案**：

1. 最慢的 3 个：
   - nvim-treesitter: 45.2ms (24.1%)
   - nvim-lspconfig: 32.1ms (17.1%)
   - nvim-cmp: 28.7ms (15.3%)
   - 合计: 106.0ms (56.6%)

2. 可降级的插件：
   - `telescope.nvim`：从 `event = "BufReadPost"` 改为 `keys = { "<leader>ff", "<leader>fg", "<leader>fb" }`。Telescope 是命令式工具，不需要在打开文件时就加载。
   - `neo-tree.nvim`：从 `event = "BufReadPost"` 改为 `cmd = "Neotree"` 或 `keys = { "<leader>e" }`。文件树是按需打开的。
   - `nvim-lspconfig`：可以改为 `ft = { "lua", "python", "typescript" }` 等你实际用的语言。但要注意：如果用 `ft`，打开新文件类型时 LSP 不会自动启动，需要重新打开文件。

3. 预期优化后：
   - telescope: 8.7ms → 0ms（懒加载到按键时）
   - neo-tree: 5.2ms → 0ms（懒加载到命令时）
   - nvim-lspconfig: 32.1ms → 0ms（懒加载到打开特定文件时）
   - 节省: ~46ms
   - 预期启动时间: 187.3ms - 46ms ≈ 141ms
   - 如果再禁用不需要的 provider 和内置插件，可以进一步压到 100ms 以内。

---

## 练习 3：写出完整的性能优化 init.lua

**题目**：根据以下需求，写出 `init.lua` 的关键配置片段（不需要 bootstrap 部分）：

需求：
- 禁用 Perl 和 Ruby provider
- 禁用内置的 gzip、tarPlugin、zipPlugin、tohtml、tutor
- 设置 lazyredraw = true
- 设置 timeoutlen = 300
- 保留 matchparen（你没装替代插件）
- 保留 netrwPlugin（你偶尔用 :Explore）

写出 `vim.g` 设置、`vim.opt` 设置、`performance.rtp.disabled_plugins` 配置。

**参考答案**：

```lua
-- 禁用不需要的 provider
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- 性能选项
vim.opt.lazyredraw = true
vim.opt.timeoutlen = 300

-- lazy.setup({ ... }) 里的 performance 字段
performance = {
  rtp = {
    reset = true,
    disabled_plugins = {
      "gzip",
      "tarPlugin",
      "tohtml",
      "tutor",
      "zipPlugin",
      -- 注意：matchparen 和 netrwPlugin 没有禁用（按需求保留）
    },
  },
},
```

---

## 练习 4：排查 LSP 不工作的问题

**题目**：你打开一个 `.py` 文件，发现没有补全、没有跳转定义、没有诊断。
按以下步骤排查，写出每步的命令和预期输出：

1. 检查 LSP 是否安装
2. 检查 LSP 是否附加到当前 buffer
3. 检查 LSP 配置是否正确
4. 检查是否有错误日志

**参考答案**：

```vim
" 步骤 1：检查 LSP 是否安装
:Mason
" 预期：Mason UI 打开，看 python (pyright 或 pylsp) 是否在已安装列表
" 如果没有：搜索 python，按 i 安装 pyright

" 步骤 2：检查 LSP 是否附加到当前 buffer
:LspInfo
" 预期：显示 attached servers 列表
" 如果为空：LSP 没有启动，可能是 ft 懒加载没触发
" 如果有但 status 不是 "running"：LSP 启动失败，看 error message

" 步骤 3：检查 LSP 配置
:checkhealth lsp
" 预期：显示 LSP 配置详情
" 看有没有 WARNING 或 ERROR

" 步骤 4：检查错误日志
:Lazy debug
" 预期：启用 debug 模式，重启后查看日志
" cat ~/.local/state/nvim/lazy-debug.log
" 搜索 "lsp" 或 "pyright" 相关的错误信息
```

常见修复：
- LSP 没安装 → `:Mason` 里安装 pyright
- LSP 没附加 → 检查 `ft = { "python" }` 是否在 spec 里
- LSP 启动失败 → 检查 Python 版本是否满足 pyright 要求（需要 Node.js）

---

## 如何使用本章代码

```bash
cd lazyvim/20-performance

# 验证所有 Lua 文件语法
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/performance.lua" -c 'qa!'
# 预期：退出码 0

# 真实环境测试（如果你装了 LazyVim）：
# cp lua/plugins/performance.lua ~/.config/nvim/lua/plugins/20-perf.lua
# nvim  → :Lazy profile → 对比前后启动时间
```

做完所有练习后，你已经掌握了 LazyVim 性能优化的完整能力。
进入 [实战项目](../projects/)，把 20 章的知识组装成完整的配置方案。
