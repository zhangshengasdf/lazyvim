# 项目 3：Markdown 写作环境 — 让 Neovim 成为你的写作台

> **钩子**：你有一篇博客要写，打开 VS Code，等 3 秒加载，再装几个插件，
> 终于开始写了……结果表格对不齐、预览要切窗口、拼写错误没人提醒。
> 用 Neovim 做这件事？启动 50ms，表格自动对齐，侧边实时预览，
> 而且整个配置就是一个 Git 仓库，换电脑 `git clone` 就能用。

本项目把前 19 章学到的所有知识组装起来，为 Markdown 写作、博客、文档配置一套完整的 LazyVim 环境。
你会发现 LazyVim 不只是代码编辑器——它同样擅长写作。

---

## TL;DR

> **30 秒速读**：Markdown 写作三件套——marksman LSP + markdownlint 检查 + markdown-preview 预览，加上 zen-mode 专注写作。
> 
> **如果只记一件事**：markdown-preview.nvim 需要 `build = "cd app && npm install"`，不写这个预览页面打不开。

---

## 项目目标

完成本项目后，你将拥有：

1. **Markdown LSP**：marksman 提供链接补全、标题导航、引用检查
2. **实时预览**：浏览器中同步滚动的 Markdown 预览
3. **专注模式**：zen-mode 隐藏所有 UI 干扰，只剩文字
4. **表格格式化**：自动对齐 Markdown 表格列
5. **代码检查**：markdownlint 检查常见写作错误
6. **Treesitter 高亮**：精准的 Markdown 语法高亮和文本对象

这不是一个"装几个插件"的项目——它综合运用了 Ch09-19 的核心知识：
spec 格式（Ch06）、extend 模式（Ch05）、懒加载策略（Ch06）、
LSP 配置（Ch12）、补全（Ch13）、格式化（Ch14）、Extras（Ch19）。

---

## 知识地图：哪些章节在这里用到了

```
项目 3 用到的知识
├─ Ch06 lazy.nvim spec  →  每个插件都是一个 spec
├─ Ch09 Telescope       →  <leader>fg 搜索文档内容
├─ Ch10 Neo-tree        →  侧边栏浏览文档目录
├─ Ch11 Treesitter      →  Markdown 高亮 + textobjects
├─ Ch12 LSP/Mason       →  marksman LSP 自动安装
├─ Ch13 补全            →  LSP 补全 + 路径补全
├─ Ch14 格式化          →  conform.nvim 表格格式化
├─ Ch17 插件配置模式    →  extend vs overwrite
├─ Ch18 自定义快捷键    →  写作专属快捷键
└─ Ch19 Extras          →  启用 Markdown Extra
```

---

## 所需 LazyVim Extras

本项目依赖以下 LazyVim Extras（通过 `:LazyExtras` 启用）：

| Extra | 提供的功能 | 说明 |
|-------|-----------|------|
| `lazyvim.plugins.extras.lang.markdown` | Treesitter markdown 解析器 + 基础配置 | 必须启用 |

其余功能（marksman、markdownlint、zen-mode 等）通过本项目的 spec 文件添加，
不依赖额外 Extra。

---

## 文件结构

```
03-markdown-writing/
├── README.md                  ← 你在这里
├── lua/
│   └── plugins/
│       ├── editor.lua         ← markdownlint + marksman LSP
│       ├── ui.lua             ← zen-mode + markdown-preview
│       └── formatting.lua     ← 表格格式化
└── exercises/
    └── README.md              ← 3 道练习
```

---

## 插件清单

### editor.lua — 编辑器增强

| 插件 | 功能 | 懒加载策略 |
|------|------|-----------|
| `markdownlint.nvim` | Markdown 代码检查（lint） | ft = { "markdown" } |
| `marksman` | Markdown LSP（链接、标题、引用） | 通过 LazyVim LSP 服务器配置 |

### ui.lua — 界面与预览

| 插件 | 功能 | 懒加载策略 |
|------|------|-----------|
| `zen-mode.nvim` | 专注模式（隐藏所有 UI） | keys（快捷键触发） |
| `markdown-preview.nvim` | 浏览器实时预览 | cmd + keys |

### formatting.lua — 格式化

| 插件 | 功能 | 懒加载策略 |
|------|------|-----------|
| `conform.nvim`（extend） | 表格自动对齐 | 通过 LazyVim 的 conform 继承 |

---

## 部署方式

### 方式 1：复制到 LazyVim 配置目录

```bash
# 将 spec 文件复制到你的 LazyVim 配置
cp -r lazyvim/projects/03-markdown-writing/lua/plugins/* ~/.config/nvim/lua/plugins/

# 启用 Markdown Extra
nvim -c ":LazyExtras"
# 找到 lang.markdown，按 x 启用

# 同步插件
nvim -c ":Lazy sync"
```

### 方式 2：在项目目录中验证（不安装）

```bash
cd lazyvim/projects/03-markdown-writing

# 验证所有 spec 文件语法正确
for f in lua/plugins/*.lua; do
  nvim --headless -u NONE -c "luafile $f" -c 'qa!'
done
```

---

## 使用指南：一个写作工作流示例

假设你要写一篇博客文章 `content/blog/my-post.md`：

```
1. nvim content/blog/my-post.md
   → Treesitter 高亮，marksman LSP 就绪

2. <leader>fg  →  Telescope 全文搜索已有文章
   Neo-tree    →  浏览 content/ 目录结构

3. 开始写作……
   → marksman 提供链接补全（输入 [[]] 触发）
   → markdownlint 实时检查（标题层级、列表格式等）
   → conform.nvim 保存时自动对齐表格

4. <leader>um  →  开启 Markdown 预览（浏览器打开）
   → 编辑器和浏览器同步滚动

5. <leader>z   →  进入专注模式
   → 行号、状态栏、sign column 全部隐藏
   → 只剩下你和文字

6. 写完，保存，:wq
```

---

## 反模式

### ❌ 不要同时启用多个 Markdown LSP

marksman 和 ltex（语法检查 LSP）可以共存，但不要同时装两个"基础 Markdown LSP"。
选 marksman（轻量、专注链接和标题）就够了。

### ❌ 不要给所有文件类型都加载 markdownlint

```lua
-- ❌ 坏：所有文件都加载 markdownlint
{ "mfussenegger/nvim-lint", opts = { linters_by_ft = { ["*"] = { "markdownlint" } } } }

-- ✅ 正确：只在 markdown 文件加载
{ "mfussenegger/nvim-lint", opts = { linters_by_ft = { markdown = { "markdownlint" } } } }
```

### ❌ 不要用 `opts = { ... }` 覆盖 LazyVim 的 conform 配置

```lua
-- ❌ 坏：覆盖 LazyVim 默认的格式化配置
{ "stevearc/conform.nvim", opts = { formatters_by_ft = { markdown = { "prettier" } } } }

-- ✅ 正确：用 extend 模式追加
{ "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.markdown = opts.formatters_by_ft.markdown or {}
    vim.list_extend(opts.formatters_by_ft.markdown, { "prettier" })
  end }
```

### ❌ 不要忘记 markdown-preview 的构建步骤

markdown-preview.nvim 需要 Node.js 来构建前端。`build` 字段必须写：

```lua
{ "iamcco/markdown-preview.nvim", build = "cd app && npm install" }
```

不写 `build`，插件装了但预览页面打不开。

## 常见错误

> 概念懂了，实际操作还是会踩坑。

| 错误 | 症状 | 解决 |
|------|------|------|
| markdown-preview 打不开 | 运行 `:MarkdownPreview` 没反应或空白页 | 确认 spec 里有 `build = "cd app && npm install"` |
| marksman LSP 没连接 | 打开 .md 文件没有链接补全 | `:Mason` 安装 marksman，或 `:LspInfo` 检查状态 |
| markdownlint 对所有文件生效 | 写 Python 也弹 markdownlint 警告 | `linters_by_ft` 只配 `markdown = { "markdownlint" }` |
| 表格没自动对齐 | 保存后表格列没对齐 | 确认 conform.nvim 的 `formatters_by_ft.markdown` 包含格式化器 |

---

## 验证

部署到 LazyVim 后，运行以下检查：

```bash
# 1. 检查 marksman LSP 是否连接
nvim -c "edit test.md" -c "sleep 2" -c "LspInfo" -c "qa!"
# 预期：marksman 出现在 attached servers 列表

# 2. 检查 markdownlint 是否工作
nvim -c "edit test.md" -c "sleep 2" -c "lua print(vim.inspect(require('lint').linters_by_ft))" -c "qa!"
# 预期：markdown = { "markdownlint" }

# 3. 检查 markdown-preview 命令是否可用
nvim -c "edit test.md" -c "verbose command MarkdownPreview" -c "qa!"
# 预期：命令已定义
```

在教程环境中验证 spec 语法：

```bash
cd lazyvim/projects/03-markdown-writing

for f in lua/plugins/*.lua; do
  echo "=== $f ==="
  nvim --headless -u NONE -c "luafile $f" -c 'qa!'
  echo "exit: $?"
done
```

预期：所有文件退出码 0。

---

## 下一步

- 完成 [exercises/](./exercises/) 中的 3 道练习
- 如果你想了解更多插件配置模式，回到 [第 17 章](../../17-plugin-patterns/)
- 如果你想学习自定义快捷键，回到 [第 18 章](../../18-custom-keymaps/)
- 如果你想了解 Extras 机制，回到 [第 19 章](../../19-extras/)
- 项目 4 会带你从零搭建 Neovim 配置，理解 LazyVim 到底为你做了什么

---

## 代码

- [`lua/plugins/editor.lua`](./lua/plugins/editor.lua) — markdownlint + marksman LSP
- [`lua/plugins/ui.lua`](./lua/plugins/ui.lua) — zen-mode + markdown-preview
- [`lua/plugins/formatting.lua`](./lua/plugins/formatting.lua) — 表格格式化
- [`exercises/README.md`](./exercises/README.md) — 3 道练习

**上一个项目**：[02-python-backend](../02-python-backend/)（Python 后端开发环境）
**下一个项目**：[04-from-scratch](../04-from-scratch/)（从零手搓迷你 Neovim 配置）
