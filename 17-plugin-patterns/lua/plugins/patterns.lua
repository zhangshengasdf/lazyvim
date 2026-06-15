--- lua/plugins/patterns.lua — 插件配置模式示例（第17章）
---
--- 这个文件演示 LazyVim 插件配置的三种核心模式：
---   1. extend 模式：opts = function + vim.list_extend（追加列表）
---   2. extend 模式：opts = function + vim.tbl_deep_extend（追加 table）
---   3. 禁用插件：enabled = false
---   4. 禁用/替换快捷键：keys = { {"lhs", false} }
---
--- ⚠️ 铁律：
---   - 扩展列表型字段用 opts = function(_, opts) vim.list_extend(opts.X, {...}) end
---   - 禁用插件用 enabled = false（不要改 LazyVim 源码）
---   - 禁用快捷键用 keys = { {"lhs", false} }
---
--- 验证：nvim --headless -u NONE -c "luafile lua/plugins/patterns.lua" -c 'qa!'

return {
  -- ========================================================================
  -- 模式 1：extend 列表字段（vim.list_extend）
  -- ========================================================================
  -- LazyVim 默认为 treesitter 定义了 ensure_installed 列表（bash/c/css/html/...）。
  -- 我们要追加语言，不能用 table 覆盖，必须用 function extend。
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "python",
        "rust",
        "toml",
        "yaml",
        "regex",
      })
    end,
  },

  -- ========================================================================
  -- 模式 2：extend table 字段（vim.tbl_deep_extend）
  -- ========================================================================
  -- Telescope 的 defaults 是一个嵌套 table。
  -- 用 vim.tbl_deep_extend 追加字段，不丢失默认值。
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        file_ignore_patterns = { "%.git/", "node_modules/", "__pycache__/" },
        layout_config = {
          horizontal = { preview_width = 0.55 },
        },
      })
    end,
  },

  -- ========================================================================
  -- 模式 3：禁用插件（enabled = false）
  -- ========================================================================
  -- LazyVim 默认启用了 mini.animate（滚动动画），有些人觉得晃眼。
  -- 加 enabled = false 就能禁用，不需要改 LazyVim 源码。
  {
    "echasnovski/mini.animate",
    enabled = false,
  },

  -- ========================================================================
  -- 模式 4：禁用快捷键
  -- ========================================================================
  -- LazyVim 默认给 Telescope 绑了 <leader>/ 做全局搜索。
  -- 如果你想把这个键留给其他用途，用 false 禁用默认绑定。
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>/", false },  -- 禁用默认的全局搜索绑定
    },
  },

  -- ========================================================================
  -- 补充：条件禁用
  -- ========================================================================
  -- enabled 可以是函数，根据条件动态决定是否启用。
  {
    "toppair/peek.nvim",
    enabled = function()
      return vim.fn.executable("deno") == 1
    end,
    build = "deno task --quiet build:fast",
    ft = { "markdown" },
  },
}
