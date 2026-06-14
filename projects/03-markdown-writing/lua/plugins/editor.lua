--- lua/plugins/editor.lua — Markdown 编辑器增强（项目 3）
---
--- 本文件配置两个核心编辑器插件：
---   1. markdownlint.nvim — Markdown 代码检查（基于 markdownlint-cli2）
---   2. marksman LSP — Markdown 语言服务器（链接补全、标题导航、引用检查）
---
--- ⚠️ 铁律：扩展 LazyVim 内置插件用 opts = function + vim.list_extend，
---   不要用 opts = { ... } 覆盖默认配置。
---
--- 文件返回 spec table，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- 1. markdownlint — Markdown 代码检查
  -- ========================================================================
  -- markdownlint 检查常见写作错误：标题层级、列表缩进、行长度等。
  -- 它通过 nvim-lint（LazyVim 的 linter 管理器）集成。
  --
  -- 懒加载策略：ft = { "markdown" } — 只在打开 Markdown 文件时加载。
  -- 这比 event = "BufReadPost" 更精确（不污染其他文件类型）。
  {
    "mfussenegger/nvim-lint",
    -- extend 模式：追加 markdownlint 到 LazyVim 默认的 linters_by_ft
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = opts.linters_by_ft.markdown or {}
      -- 用 table.insert 追加（避免覆盖 LazyVim 可能已有的 linter）
      table.insert(opts.linters_by_ft.markdown, "markdownlint")
    end,
  },

  -- ========================================================================
  -- 2. marksman LSP — Markdown 语言服务器
  -- ========================================================================
  -- marksman 提供：
  --   - 链接补全（输入 [[]] 触发）
  --   - 标题导航（gd 跳转到定义）
  --   - 引用检查（检测断开的链接）
  --   - 文档符号（<leader>ss 查看标题列表）
  --
  -- 通过 LazyVim 的 LSP 服务器配置集成（Ch12 模式）。
  -- mason-lspconfig 会自动安装 marksman（如果 Mason registry 里有）。
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- marksman：Markdown LSP
        -- 空 table {} 表示使用默认配置（不需要额外设置）
        marksman = {},
      },
    },
  },

  -- ========================================================================
  -- 3. Treesitter Markdown 扩展（extend 模式）
  -- ========================================================================
  -- 确保 markdown 和 markdown_inline 解析器已安装。
  -- markdown_inline 处理行内格式（**粗体**、`代码`、[链接]() 等）。
  --
  -- extend 模式（Ch11）：追加到 LazyVim 默认的 ensure_installed 列表。
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "markdown",
        "markdown_inline",
      })
    end,
  },

  -- ========================================================================
  -- 4. 写作专属快捷键（extend 模式）
  -- ========================================================================
  -- 为 Markdown 文件注册写作快捷键。
  -- 用 vim.keymap.set + buffer-local（只在 markdown buffer 生效）。
  --
  -- 这里展示 Ch18 的模式：在 spec 的 config 函数中注册 buffer-local keymaps。
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      -- 注册写作相关快捷键组（which-key 会显示分组名）
      vim.keymap.set("n", "<leader>w", "", { desc = "+写作" })
      vim.keymap.set("n", "<leader>wm", "", { desc = "+Markdown" })
    end,
  },
}
