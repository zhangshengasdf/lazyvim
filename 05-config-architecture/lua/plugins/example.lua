--- lua/plugins/example.lua — plugin spec 示例（第05章）
---
--- 这个文件演示 lua/plugins/ 下 spec 文件的结构。
--- 真实使用时放在 ~/.config/nvim/lua/plugins/example.lua，lazy.nvim 自动收集。
---
--- 铁律：
---   1. 文件必须 return 一个 table（可以是单个 spec，也可以是 spec 列表）
---   2. 扩展列表型字段用 opts = function(_, opts) vim.list_extend(...) end
---   3. 不要直接覆盖 LazyVim 默认的列表

-- 返回一个 spec 列表（每个元素是一个插件 spec）
return {
  -- ========================================================================
  -- 示例 1：定制 Telescope（extend 模式）
  -- ========================================================================
  -- Telescope 是 LazyVim 内置插件，我们想追加一个布局选项，不覆盖默认配置。
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      -- opts 是 LazyVim 默认的 opts（引用传递）
      -- 追加默认布局策略（不覆盖默认的其他选项）
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        layout_strategy = "horizontal",
        sorting_strategy = "ascending",
      })
    end,
  },

  -- ========================================================================
  -- 示例 2：扩展 Treesitter 解析器列表（extend 模式，最常见用法）
  -- ========================================================================
  -- LazyVim 默认装了一堆解析器（bash/c/css/...），我们想追加 lua 和 rust。
  -- ❌ 错误做法：opts = { ensure_installed = { "lua", "rust" } }（会覆盖默认列表）
  -- ✅ 正确做法：用 function 接收默认 opts，再 list_extend
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "lua",
        "vim",
        "vimdoc",
        "query",
      })
    end,
  },

  -- ========================================================================
  -- 示例 3：禁用 LazyVim 默认插件（enabled = false）
  -- ========================================================================
  -- 如果你不想用 LazyVim 默认的某个插件（比如 mini.animate 动画），可以禁用它。
  {
    "echasnovski/mini.animate",
    enabled = false,
  },

  -- ========================================================================
  -- 示例 4：新增 LazyVim 没有的插件
  -- ========================================================================
  -- 这个插件 LazyVim 没有内置，你直接添加 spec 即可。
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoQuickFix", "TodoLocList", "TodoTrouble", "TodoTelescope" },
    opts = {},
  },
}
