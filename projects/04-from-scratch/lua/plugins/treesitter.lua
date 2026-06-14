--- lua/plugins/treesitter.lua — Treesitter 语法高亮（项目 4）
---
--- 从零配置 Treesitter，不依赖 LazyVim 的预配置。
--- 对照 Ch11 的内容，这里是你自己写的完整 spec。
---
--- LazyVim 帮你做的事情（你需要自己写）：
---   1. 安装 nvim-treesitter
---   2. 配置 ensure_installed（20+ 语言的解析器）
---   3. 启用 highlight、indent、textobjects
---   4. 配置增量选择
---
--- 本文件只写 25 行，LazyVim 的默认配置有 80+ 行。

return {
  -- ========================================================================
  -- nvim-treesitter — 语法高亮 + 文本对象
  -- ========================================================================
  -- Treesitter 是 Neovim 的语法分析引擎。
  -- 它比正则表达式高亮更准确，支持代码折叠、文本对象等。
  {
    "nvim-treesitter/nvim-treesitter",
    -- build 命令：安装/更新后编译解析器
    build = ":TSUpdate",
    -- event 懒加载：打开文件时加载（Treesitter 需要在编辑时就工作）
    event = { "BufReadPost", "BufNewFile" },
    -- opts = function 接收默认配置，然后修改
    -- 从零配置没有 LazyVim 的默认 opts，所以直接写 config
    config = function()
      require("nvim-treesitter.configs").setup({
        -- 确保安装这些语言的解析器
        -- 这是你手动列出的列表（LazyVim 有 20+ 个）
        ensure_installed = {
          "bash",
          "c",
          "html",
          "javascript",
          "json",
          "lua",
          "luadoc",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "regex",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },

        -- 自动安装 ensure_installed 中缺失的解析器
        auto_install = true,

        -- 语法高亮
        highlight = {
          enable = true,
          -- 禁用 Neovim 的正则表达式高亮（Treesitter 更准确）
          additional_vim_regex_highlighting = false,
        },

        -- 缩进（基于 Treesitter 的智能缩进）
        indent = {
          enable = true,
        },

        -- 增量选择（逐步扩大选区，从单词到表达式到函数）
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",   -- 开始选择
            node_incremental = "<C-space>", -- 扩大选区
            scope_incremental = false,      -- 不用
            node_decremental = "<BS>",      -- 缩小选区
          },
        },
      })
    end,
  },
}
