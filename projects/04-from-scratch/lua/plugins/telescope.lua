--- lua/plugins/telescope.lua — Telescope 模糊搜索（项目 4）
---
--- 从零配置 Telescope，不依赖 LazyVim 的预配置。
--- 对照 Ch09 的内容，这里是你自己写的完整 spec。
---
--- LazyVim 帮你做的事情（你需要自己写）：
---   1. 安装 telescope.nvim + plenary.nvim + fzf-native.nvim
---   2. 配置默认选项（layout_strategy、sorting_strategy 等）
---   3. 注册快捷键（<leader>ff、<leader>fg 等）
---   4. 加载 fzf 扩展
---
--- 本文件只写 30 行，LazyVim 的默认配置有 100+ 行。

return {
  -- ========================================================================
  -- plenary.nvim — Telescope 的依赖
  -- ========================================================================
  -- 很多 Neovim 插件都依赖 plenary.nvim（提供异步、路径、字符串等工具函数）。
  -- LazyVim 自动管理依赖，从零配置你需要手动声明。
  {
    "nvim-lua/plenary.nvim",
  },

  -- ========================================================================
  -- telescope.nvim — 模糊搜索
  -- ========================================================================
  -- Telescope 是 Neovim 最核心的搜索框架。
  -- 从零配置的关键：你需要自己写 opts 和 keys。
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",  -- 锁定稳定版
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- 懒加载：按快捷键时才加载（Ch06 keys 模式）
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "实时 grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "切换 buffer" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "查帮助" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "最近文件" },
      { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "诊断信息" },
    },
    -- config 函数：插件加载后执行
    -- 这里用 config 而不是 opts，因为需要在 setup 后加载 fzf 扩展
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          -- 布局：水平排列（左边预览，右边结果）
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              preview_width = 0.55,  -- 预览窗口占 55%
            },
          },
          -- 排序：从上到下（不是从下到上）
          sorting_strategy = "ascending",
          -- 搜索时忽略这些目录
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "dist/",
            "build/",
          },
        },
        pickers = {
          find_files = {
            -- 隐藏文件也搜索（默认不搜索以 . 开头的文件）
            hidden = true,
          },
        },
      })

      -- 加载 fzf 扩展（如果已安装）
      -- pcall 防止 fzf-native 没装时报错
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- ========================================================================
  -- telescope-fzf-native.nvim — FZF 排序加速
  -- ========================================================================
  -- 用 C 实现的 FZF 排序算法，比 Lua 原生排序快 10 倍。
  -- 需要编译（build = "make"），cond 确保有 C 编译器才装。
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = function()
      return vim.fn.executable("make") == 1
    end,
  },
}
