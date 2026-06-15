# LazyVim 渐进式教程 — 从 Vim 零基础到配置高手

> **一句话**：从 Vim 模态编辑的基本功开始，逐步拆解 LazyVim 的每一层抽象，
> 学完后你不仅能高效使用 LazyVim，还能读懂它的源码、写出自己的插件配置。
> 全程 **Lua + Neovim 原生 API**，不依赖任何外部框架知识。

---

## 为什么有这个教程

LazyVim 是目前最流行的 Neovim 发行版——开箱即用、插件丰富、社区活跃。
但对新手来说，它太方便了，方便到像个黑盒：

1. **"一键安装，不知为何能用"**：`nvim` 一打开就有补全、LSP、文件树，
   但你不知道这些能力从哪来、怎么调、出问题去哪里排查。
2. **"改配置靠抄"**：在 `~/.config/nvim/lua/plugins/` 里粘贴别人的配置，
   碰巧能用就不管了——一旦 LazyVim 升级、插件 API 变动，你的配置就炸了。
3. **"Vim 本身不会用"**：很多人跳过了 Vim 的基本功，
   导致遇到模态编辑、文本对象、宏录制等核心能力时完全不会用。

本教程反其道而行：

### 先基本功，再框架

> **先学会 Vim 的"为什么"，再享受 LazyVim 的"怎么用"。**

我们的递进路径是：

```
Vim 生存技能  →  理解 Neovim 架构  →  拆解 LazyVim 每一层  →  自己写配置
 (Part 0)        (Part 1)            (Part 2-4)            (Part 5 + 项目)
```

- **Part 0** 用纯 Neovim（无插件）练习模态编辑、文本对象、搜索替换——这些是所有 Vim 发行版的根基。
- **Part 1** 理解 Neovim 的配置目录结构、init.lua 的加载顺序、lazy.nvim 的工作原理。
- **Part 2-4** 逐个拆解 LazyVim 内置的核心插件：which-key、Telescope、Neo-tree、Treesitter、LSP、补全……
  每一章你会知道"这个功能是哪个插件提供的、它的配置在哪里、怎么覆盖"。
- **Part 5 + 项目** 把学到的知识组装成你自己的配置，从零搭建或在 LazyVim 基础上深度定制。

这样无论 LazyVim 怎么升级，你已经掌握了底层原理，能快速适应变化。

---

## 学习路径图

教程分 **7 部分 / 20 章 / 4 个实战项目**，每章独立文件夹、可单独学习运行：

| 部分 | 章节 | 主题 | 你将学会 |
|------|------|------|----------|
| **Part 0 · Vim 生存** | 01-03 | 模态编辑 / 编辑操作 / Neovim 基础 | Vim 生存技能，不再害怕模态编辑 |
| **Part 1 · 架构** | 04-06 | LazyVim 安装 / 配置目录 / lazy.nvim | 理解 LazyVim 的骨架和插件管理器 |
| **Part 2 · 核心工作流** | 07-10 | Leader 键 / which-key / Telescope / Neo-tree | 高效导航、搜索和文件管理 |
| **Part 3 · 代码智能** | 11-14 | Treesitter / LSP+Mason / 补全 / 格式化 | 让 Neovim 变成真正的 IDE |
| **Part 4 · 开发工作流** | 15-16 | Git 集成 / DAP 调试 | 日常开发必备的 Git 和调试能力 |
| **Part 5 · 定制扩展** | 17-19 | 插件配置模式 / 自定义快捷键 / Extras | 打造属于自己的 Neovim 配置 |
| **Part 6 · 进阶** | 20 | 性能优化与健康检查 | 保持配置健康、启动飞快 |
| **实战项目 x4** | 项目1-4 | TS 全栈 / Python 后端 / Markdown 写作 / 从零手搓 | 4 个完整的 Neovim 配置方案 |

**关键路径**：Vim 生存 → 架构理解 → 核心工作流 → 代码智能 → 开发工作流 → 定制扩展 → 进阶 → 实战。

每章都包含：**概念讲解（README）+ Lua 配置代码 + 练习 + 反模式说明**。

---

## 贯穿全教程的统一示例：你的 Neovim 配置

为了让 20 章的知识连贯、不散，我们用 **同一个配置** 贯穿演进——
它叫 **「你的 Neovim 配置」**。

它会随着章节一步步长大：

| 阶段 | 你的配置会什么 | 出现章节 |
|------|----------------|----------|
| 裸 Neovim | 只有默认键位，会用 `hjkl` 移动、`i` 进入插入模式 | Part 0 |
| 能导航 | 知道配置目录在哪，装上了 lazy.nvim，会用 Leader 键 | Part 1 |
| 会搜索 | Telescope 模糊搜索文件和内容，Neo-tree 浏览目录树 | Part 2 |
| 能写代码 | Treesitter 高亮 + LSP 诊断 + 补全 + 自动格式化 | Part 3 |
| 会协作 | Git 状态一目了然，DAP 断点调试跑起来 | Part 4 |
| 有个性 | 按自己习惯重写快捷键、添加 Extras、配置专属插件 | Part 5 |
| 跑得快 | 启动时间 < 50ms，配置健康无警告 | Part 6 |
| 能实战 | 4 套完整配置方案，拿来就能用 | 项目 |

这样做的好处：你每学一章，**你的配置就多一项能力**，前后对照极其清晰，
而不是每章换一个互不相干的示例。

---

## 环境准备

| 依赖 | 版本要求 | 说明 |
|------|----------|------|
| **Neovim** | >= 0.9（推荐 0.10+） | `:version` 查看；LazyVim 官方要求 0.9+ |
| **Nerd Font** | 任意 | 图标显示必需；推荐 JetBrainsMono Nerd Font |
| **ripgrep** | 任意 | Telescope 全文搜索依赖 |
| **fd** | 任意 | Telescope 文件搜索依赖（可选但推荐） |
| **Git** | >= 2.19 | lazy.nvim 克隆插件依赖 |
| **终端** | 推荐 kitty / WezTerm / Alacritty | 支持真彩色和图片协议 |

安装示例（macOS）：

```bash
brew install neovim ripgrep fd git
# Nerd Font: brew install --cask font-jetbrains-mono-nerd-font
```

安装示例（Ubuntu/Debian）：

```bash
sudo apt install neovim ripgrep fd-find git
# Nerd Font: 从 https://www.nerdfonts.com/ 下载
```

---

## 如何使用本教程

### 1. 从第 01 章开始

进入 [01-modal-editing/](./01-modal-editing/)，按 README 的指引学习。
每章文件夹的标准结构：

```
XX-topic/
├── README.md          ← 概念讲解（必读）
├── lua/               ← 可运行的 Lua 配置代码
│   └── config.lua     ← 本章的核心配置
└── exercises/         ← 练习与参考答案
    ├── exercise-01.md
    └── reference/     ← 参考答案（先自己试！）
```

### 2. 动手实践

每章的 `lua/` 目录里有可运行的配置代码。
建议你**手动敲一遍**，不要复制粘贴——Vim 的肌肉记忆需要练习。

### 3. 验证学习效果

每章末尾有练习，用 `shared/verify.lua` 验证你的配置是否正确：

```bash
nvim --headless -u NONE -c "luafile shared/verify.lua" -c "qa!"
```

### 4. 按自己的节奏推进

20 章可以按顺序学，也可以跳着学——每章尽量自包含。
如果某一章对你来说太基础，直接跳到下一章即可。

---

## 仓库结构

```
lazyvim/
├── README.md              ← 你在这里（总导读）
├── shared/                ← 共享工具（所有章节共用）
│   ├── verify.lua         ← 配置验证工具函数
│   └── README.md          ← shared 模块说明
├── 01-modal-editing/      ← Part 0 · Vim 生存
│   ├── README.md
│   ├── lua/
│   └── exercises/
├── 02-editing-ops/
├── 03-neovim-basics/
├── 04-lazyvim-intro/      ← Part 1 · 架构
├── 05-config-architecture/
├── 06-lazy-nvim/
├── 07-leader-keys/        ← Part 2 · 核心工作流
├── 08-which-key/
├── 09-telescope/
├── 10-neo-tree/
├── 11-treesitter/         ← Part 3 · 代码智能
├── 12-lsp-mason/
├── 13-completion/
├── 14-formatting/
├── 15-git/                ← Part 4 · 开发工作流
├── 16-dap/
├── 17-plugin-patterns/    ← Part 5 · 定制扩展
├── 18-custom-keymaps/
├── 19-extras/
├── 20-performance/        ← Part 6 · 进阶
└── projects/              ← 4 个实战项目
    ├── 01-ts-fullstack/
    ├── 02-python-backend/
    ├── 03-markdown-writing/
    └── 04-from-scratch/
```

> 章节目录正在陆续创建。本文件（脚手架）是地基，后续 20 章都依赖它。

---

## 贡献指南

- **每章自包含**：尽量减少跨章依赖，便于单独学习。
- **代码可复制粘贴**：不省略关键路径，不写 `...` 占位。
- **每章一个新概念**：避免认知过载。
- **包含反模式说明**：明确告诉读者"什么不该做"。
- **用 `vim.keymap.set`**：不用 `vim.api.nvim_set_keymap`（已被弃用），也不用不存在的 `safe_keymap_set`。
- **用 extend 不 overwrite**：扩展列表型配置时用 `opts = function(_, opts) vim.list_extend(opts.X, {...}) end`，
  不要直接写 `opts = { ensure_installed = {...} }`——那会覆盖 LazyVim 默认值。
- **验证你的代码**：每章的 Lua 配置必须能通过 `shared/verify.lua` 的基本检查。

---

## 许可证

MIT（见根目录 LICENSE，后续添加）。

**下一步**：进入 [01-modal-editing/](./01-modal-editing/) 开始第一课。
从 `hjkl` 开始，一步步成为 Neovim 配置高手。
