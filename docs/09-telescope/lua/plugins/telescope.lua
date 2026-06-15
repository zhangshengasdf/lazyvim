--- lua/plugins/telescope.lua — Telescope spec 示例（第09章）
---
--- 这个文件演示 Telescope 的 lazy.nvim spec 写法：
---   1. keys 懒加载（按 <leader>ff 等键时才加载）
---   2. opts = function + vim.tbl_deep_extend 扩展 defaults
---   3. config 函数：setup + load_extension
---   4. fzf-native 依赖声明
---
--- ⚠️ 铁律：
---   - 扩展 table 字段用 opts = function + vim.tbl_deep_extend（不是 opts = {...} 覆盖）
---   - keys 必须带 desc（which-key 需要）
---   - pcall 保护 load_extension（扩展可能没装）
---
--- 文件返回一个 spec table，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- Telescope 主 spec
  -- ========================================================================
  {
    "nvim-telescope/telescope.nvim",

    -- 依赖：plenary（必备工具库）+ fzf-native（C 实现的排序算法）
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        -- build 命令：安装后编译 C 代码
        -- LazyVim 会自动检测系统并选择合适的编译器
        build = "make",
        -- cond：编译工具可用时才启用
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },

    -- ======================================================================
    -- keys 懒加载：按下这些键时才加载 Telescope
    -- ======================================================================
    -- 这是 Telescope 最推荐的懒加载方式：
    --   - Neovim 启动时不加载 Telescope（启动快）
    --   - 按 <leader>ff 时 lazy.nvim 先加载 Telescope，再执行命令
    --   - which-key 会显示 desc 描述（按 <leader>f 等 0.5 秒就能看到）
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>",  desc = "查找文件" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>",   desc = "全文搜索" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>",     desc = "切换缓冲区" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>",    desc = "最近文件" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>",   desc = "查帮助" },
      { "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "搜光标下单词" },
      { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "诊断列表" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", desc = "文档符号" },
    },

    -- ======================================================================
    -- opts = function 扩展默认配置
    -- ======================================================================
    -- LazyVim 已为 Telescope 定义了默认 opts（包括 layout、mappings 等）。
    -- 我们用 opts = function 拿到默认 opts 的引用，再用 tbl_deep_extend 追加。
    -- 如果用 opts = {...} 会覆盖 LazyVim 的默认配置。
    opts = function(_, opts)
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        -- 布局：水平排列（左边结果，右边预览）
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
          },
          width = 0.87,
          height = 0.80,
        },
        -- 排序：从上往下
        sorting_strategy = "ascending",
        -- 搜索时忽略这些目录
        file_ignore_patterns = { "node_modules", ".git/", "dist/" },
      })

      -- 扩展 pickers（每个搜索命令的独立选项）
      opts.pickers = vim.tbl_deep_extend("force", opts.pickers or {}, {
        find_files = {
          -- 用 fd 命令（比 find 快，支持 .gitignore）
          find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
        },
      })
    end,

    -- ======================================================================
    -- config：setup 后加载扩展
    -- ======================================================================
    -- 为什么用 config 而不是 opts？
    -- 因为 load_extension 必须在 setup 之后调用，opts 做不到。
    -- LazyVim 的 Telescope spec 也是用 config 来加载 fzf 扩展。
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      -- pcall 保护：fzf-native 可能没编译成功
      pcall(telescope.load_extension, "fzf")
    end,
  },
}
