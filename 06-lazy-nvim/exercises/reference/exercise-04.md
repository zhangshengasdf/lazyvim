# 练习 4 参考答案 — 完整 spec 设计

## 需求回顾

- 插件：`iamcco/markdown-preview.nvim`
- 功能：Markdown 实时预览
- 快捷键：`<leader>mp` 打开预览
- 构建：`cd app && npm install`
- 只在 Markdown 文件时用

## 正确 spec

```lua
return {
  {
    "iamcco/markdown-preview.nvim",
    -- 懒加载：用 ft（只在 Markdown 文件时才加载）
    ft = { "markdown" },
    -- 绑快捷键（带 desc，which-key 会拾取）
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreview<CR>", desc = "Markdown 预览" },
      { "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "停止预览" },
    },
    -- build 命令：安装后跑一次 npm install（预览服务依赖 npm 包）
    build = "cd app && npm install",
    -- 用 init 设置全局变量（即使插件还没加载也生效）
    init = function()
      vim.g.mkdp_auto_start = 0       -- 不自动打开预览（要手动按快捷键）
      vim.g.mkdp_browser = "firefox"  -- 用 Firefox 打开预览
    end,
  },
}
```

## 设计要点解析

### 1. 为什么用 `ft` 而不是 `cmd` 或 `keys`？

`ft = { "markdown" }` 确保只在打开 `.md` 文件时才加载。
如果你主要不写 Markdown，这个插件永远不会加载，不拖慢启动。

也可以同时用 `ft` 和 `keys`——但 `ft` 已经覆盖了"打开 Markdown 文件"的场景，
`keys` 在 `ft` 触发后才有意义。

### 2. 为什么用 `init` 而不是 `opts`？

markdown-preview.nvim 是一个**Vimscript + Node.js** 插件，它用全局变量（`vim.g.mkdp_*`）
配置，而不是 `setup(opts)` 函数。所以用 `init`（在插件加载前执行，但全局变量已设）。

> ⚠️ `init` 在 Neovim 启动时全局执行（即使插件因 `ft` 懒加载还没加载），
> 所以 `vim.g.mkdp_*` 在 Markdown 文件打开前就设好了。

### 3. `build` 命令什么时候执行？

- **安装时**（第一次 `:Lazy install`）
- **更新时**（每次 `:Lazy update` 后，如果插件有更新）

`build` 可以是字符串（shell 命令）或 function（Lua 代码）。

## 进阶：用 cmd 而非 ft 的版本

如果你想更激进地懒加载（连 Markdown 文件都不预加载插件，只在真正要预览时才加载）：

```lua
{
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  keys = {
    { "<leader>mp", "<cmd>MarkdownPreview<CR>", desc = "Markdown 预览" },
  },
  build = "cd app && npm install",
  init = function()
    vim.g.mkdp_auto_start = 0
  end,
},
```

这样插件只在运行 `:MarkdownPreview` 或按 `<leader>mp` 时才加载，更省资源。
但代价是第一次按快捷键会有短暂延迟（要加载插件）。

**回到 [练习题](../README.md)**
