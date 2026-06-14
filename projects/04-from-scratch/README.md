# 项目 4：从零手搓迷你 Neovim 配置 — 理解 LazyVim 为你做了什么

> **钩子**：你用了 20 章学 LazyVim，配置文件都是在它的框架里写 spec。
> 但你有没有想过：如果没有 LazyVim，你从零开始配置 Neovim 会是什么样？
> lazy.nvim 怎么 bootstrap？Telescope 怎么配？LSP 怎么接？
> 本项目带你亲手搭建一个"麻雀虽小、五脏俱全"的 Neovim 配置，
> 你会发现 LazyVim 帮你省了多少活。

---

## 项目目标

完成本项目后，你将：

1. **从零搭建**一套完整的 Neovim 配置（不依赖 LazyVim）
2. **理解** lazy.nvim 的 bootstrap 流程（不是魔法，只有 10 行代码）
3. **手写**每个插件的 spec（Telescope、Treesitter、LSP、补全、Git、配色）
4. **对比**自己的配置和 LazyVim 的默认配置，量化 LazyVim 帮你省了多少
5. **做出选择**：什么场景用 LazyVim，什么场景从零开始

这不是"把 LazyVim 配置复制一遍"的练习。
你写的每一行代码都必须独立于 LazyVim——不 import 它的模块，不继承它的 spec。

---

## 为什么要做这个项目

### LazyVim 是捷径，但不是黑盒

前 19 章你学会了在 LazyVim 框架内配置：
写 spec、extend 列表、注册快捷键。这些都很方便，但方便的代价是抽象。

当你遇到以下情况时，需要理解底层：

| 场景 | 你需要知道什么 |
|------|--------------|
| LazyVim 升级后你的配置炸了 | 哪些是 LazyVim 的默认行为，哪些是你覆盖的 |
| 想用一个 LazyVim 不支持的插件 | 怎么独立写 spec、配 LSP、接补全 |
| 性能优化 | 哪些插件最重、哪些可以砍掉 |
| 为团队写配置模板 | 怎么从零搭建一套可复用的配置 |

### 与 Kickstart.nvim 的关系

Kickstart.nvim 是 Neovim 官方推荐的"教学配置"——一个 `init.lua` 文件包含所有核心功能。
本项目的结构与 Kickstart.nvim 相似（都是从零搭建），但有三个关键区别：

| 对比项 | Kickstart.nvim | 本项目 |
|--------|---------------|--------|
| 语言 | 单文件 `init.lua` | 拆分成 `init.lua` + `lua/plugins/*.lua` |
| 目标 | "能用就行" | "理解为什么" |
| 注释 | 英文，简洁 | 中文，详细讲解每一步 |
| 依赖 | 不依赖任何发行版 | 不依赖 LazyVim，但讲解它做了什么 |

---

## 文件结构

```
04-from-scratch/
├── README.md                  ← 你在这里
├── init.lua                   ← 完整从零配置（主入口）
├── lua/
│   └── plugins/
│       ├── telescope.lua      ← Telescope 模糊搜索
│       ├── treesitter.lua     ← Treesitter 语法高亮
│       ├── lsp.lua            ← LSP + Mason + 补全
│       ├── git.lua            ← Git 集成
│       └── colorscheme.lua    ← 配色方案
└── exercises/
    └── README.md              ← 3 道思考题
```

---

## 配置架构总览

```
init.lua（主入口）
│
├── 1. 基础选项（vim.opt.*）
│   行号、缩进、搜索、分屏方向...
│
├── 2. 基础快捷键（vim.keymap.set）
│   Leader 键、窗口导航、buffer 切换...
│
├── 3. lazy.nvim bootstrap（安装插件管理器）
│   自动下载 lazy.nvim 到本地
│
└── 4. lazy.setup({ specs })
    ├── plugins/telescope.lua   ← 模糊搜索
    ├── plugins/treesitter.lua  ← 语法高亮
    ├── plugins/lsp.lua         ← LSP + 补全
    ├── plugins/git.lua         ← Git 标记
    └── plugins/colorscheme.lua ← 配色
```

对比 LazyVim 的架构：

```
LazyVim 的架构（你已经熟悉的）
│
├── lua/config/options.lua     ← LazyVim 帮你写的
├── lua/config/keymaps.lua     ← LazyVim 帮你写的
├── lua/config/autocmds.lua    ← LazyVim 帮你写的
├── lua/config/lazy.lua        ← lazy.nvim bootstrap
│
└── lazy.nvim spec（来自 LazyVim 仓库）
    ├── 50+ 个插件的默认配置
    ├── which-key 快捷键提示
    ├── Telescope 预配置
    ├── Treesitter 预配置
    ├── LSP + Mason 预配置
    ├── 补全预配置
    ├── Git 预配置
    ├── 配色预配置
    └── 你的扩展（lua/plugins/*.lua）
```

**LazyVim 帮你做了什么**：上面那个大列表里的每一项。
从零搭建意味着你得自己写每一项。

---

## 核心概念：lazy.nvim Bootstrap

这是从零配置的第一步，也是最关键的一步。
lazy.nvim 不是 Neovim 内置的，你需要"自举"（bootstrap）它：

```lua
-- 1. 确定 lazy.nvim 的安装路径
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- 2. 如果没装过，从 GitHub 克隆
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

-- 3. 把 lazy.nvim 加到 runtimepath（这样 require("lazy") 才能找到它）
vim.opt.rtp:prepend(lazypath)

-- 4. 用 lazy.setup() 加载插件
require("lazy").setup({
  spec = {
    -- 插件 spec 放在这里
    { import = "plugins" },  -- 自动加载 lua/plugins/*.lua
  },
})
```

只有 4 步，没有魔法。LazyVim 的 `lua/config/lazy.lua` 做的事情完全一样。

---

## 与 LazyVim 的功能对照表

| 功能 | LazyVim 提供 | 本项目（从零） | 你写的代码量 |
|------|-------------|---------------|------------|
| 行号、缩进 | 自动配置 | `vim.opt.*` | ~15 行 |
| Leader 键体系 | `<Space>` + 6 大类 | `vim.g.mapleader` | ~5 行 |
| lazy.nvim bootstrap | 自动 | 手写 bootstrap | ~15 行 |
| Telescope | 预配置 + 扩展 | 手写 spec + opts | ~30 行 |
| Treesitter | 预配置 + ensure_installed | 手写 spec | ~20 行 |
| LSP + Mason | 预配置 + 服务器列表 | 手写 lspconfig + mason | ~40 行 |
| 补全 | nvim-cmp 预配置 | 手写 sources + mapping | ~30 行 |
| Git 标记 | gitsigns 预配置 | 手写 spec | ~15 行 |
| 配色 | tokyonight 预配置 | 手写 spec | ~10 行 |
| which-key | 预配置 | 不配置（精简版） | 0 行 |
| 状态栏 | lualine 预配置 | 不配置（精简版） | 0 行 |
| 文件树 | Neo-tree 预配置 | 不配置（用 netrw） | 0 行 |
| 格式化 | conform.nvim 预配置 | 不配置（精简版） | 0 行 |
| 补全 snippet | LuaSnip 预配置 | 不配置（精简版） | 0 行 |
| **总计** | **~2000 行 Lua** | **~165 行 Lua** | **你写的** |

这个表格回答了练习 1 的问题：LazyVim 帮你省了大约 1800 行配置代码。

---

## 反模式

### ❌ 不要 `import = "lazyvim.plugins"`

```lua
-- ❌ 坏：这会加载 LazyVim 的所有默认 spec，等于没从零开始
require("lazy").setup({
  spec = {
    { import = "lazyvim.plugins" },  -- 这是 LazyVim！
    { import = "plugins" },
  },
})

-- ✅ 正确：只加载自己的 spec
require("lazy").setup({
  spec = {
    { import = "plugins" },  -- 只有你自己的 spec
  },
})
```

### ❌ 不要复制 LazyVim 的 spec 结构

LazyVim 的 spec 有很多"约定"（opts_extend、keys 模式等）。
从零配置不需要这些——直接写 `require("xxx").setup({})` 就行。

```lua
-- ❌ 坏：照搬 LazyVim 的 opts_extend 模式（这里没有 LazyVim 的合并逻辑）
{
  "nvim-telescope/telescope.nvim",
  opts_extend = { "defaults" },
  opts = { defaults = { layout_strategy = "horizontal" } },
}

-- ✅ 正确：直接用 config 函数
{
  "nvim-telescope/telescope.nvim",
  config = function()
    require("telescope").setup({
      defaults = { layout_strategy = "horizontal" },
    })
  end,
}
```

### ❌ 不要忘记 bootstrap 的 `vim.loop.fs_stat` 检查

```lua
-- ❌ 坏：每次都克隆（浪费时间，而且会冲突）
vim.fn.system({ "git", "clone", "...", lazypath })

-- ✅ 正确：先检查是否已存在
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "...", lazypath })
end
```

### ❌ 不要用 `vim.api.nvim_set_keymap`（已弃用）

```lua
-- ❌ 坏：旧 API，没有 desc 字段
vim.api.nvim_set_keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { noremap = true })

-- ✅ 正确：新 API，有 desc 字段
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "查找文件" })
```

---

## 验证

### 在教程环境中验证

```bash
cd lazyvim/projects/04-from-scratch

# 验证 init.lua 语法
nvim --headless -u NONE -c "luafile init.lua" -c 'qa!'
echo "init.lua exit: $?"

# 验证所有 spec 文件
for f in lua/plugins/*.lua; do
  nvim --headless -u NONE -c "luafile $f" -c 'qa!'
  echo "$f exit: $?"
done
```

预期：所有文件退出码 0（init.lua 的 pcall guard 会打印 demo 消息后正常退出）。

### 在真实环境中验证

```bash
# 备份现有配置
mv ~/.config/nvim ~/.config/nvim.bak

# 复制本项目到 Neovim 配置目录
cp -r lazyvim/projects/04-from-scratch ~/.config/nvim

# 启动 Neovim（会自动 bootstrap lazy.nvim 并安装插件）
nvim

# 检查插件状态
:Lazy

# 检查 LSP
:LspInfo

# 检查健康
:checkhealth
```

> ⚠️ 真实环境验证前，一定备份现有配置。本项目会覆盖 `~/.config/nvim/`。

---

## 下一步

- 完成 [exercises/](./exercises/) 中的 3 道思考题
- 如果你想回到 LazyVim，恢复备份即可：`mv ~/.config/nvim.bak ~/.config/nvim`
- 如果你想深入理解某个插件的配置，回到对应的章节

---

## 代码

- [`init.lua`](./init.lua) — 完整从零配置（主入口）
- [`lua/plugins/telescope.lua`](./lua/plugins/telescope.lua) — Telescope 模糊搜索
- [`lua/plugins/treesitter.lua`](./lua/plugins/treesitter.lua) — Treesitter 语法高亮
- [`lua/plugins/lsp.lua`](./lua/plugins/lsp.lua) — LSP + Mason + 补全
- [`lua/plugins/git.lua`](./lua/plugins/git.lua) — Git 集成
- [`lua/plugins/colorscheme.lua`](./lua/plugins/colorscheme.lua) — 配色方案
- [`exercises/README.md`](./exercises/README.md) — 3 道思考题

**上一个项目**：[03-markdown-writing](../03-markdown-writing/)（Markdown 写作环境）
**回到教程首页**：[../../README.md](../../README.md)
