--- lua/plugins/example.lua — lazy.nvim spec 三种模式示例（第06章）
---
--- 这个文件演示 lazy.nvim spec 的三种核心模式：
---   1. 基本 spec：{ "repo/url", opts = { ... } }
---   2. 懒加载 spec：{ "repo/url", event = "...", keys = { ... } }
---   3. extend 模式：{ "repo/url", opts = function(_, opts) vim.list_extend(...) end }
---
--- ⚠️ 铁律：
---   - 扩展列表型字段用 opts = function(_, opts) vim.list_extend(opts.X, {...}) end
---   - 不要直接用 opts = { ensure_installed = {...} } 覆盖默认列表
---
--- 文件返回一个 spec table（或 spec 列表），直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- 模式 1：基本 spec（opts = table）
  -- ========================================================================
  -- 适用场景：插件有 setup() 函数，你只想传几个选项，不需要懒加载。
  -- 这个 spec 没有 event/ft/keys/cmd，所以会在启动时加载（非懒加载）。
  {
    "folke/tokyonight.nvim",
    -- opts 是 table：直接传给 require("tokyonight").setup(opts)
    opts = {
      style = "storm",        -- 配色风格：storm/night/day/moon
      transparent = false,    -- 是否透明背景
      terminal_colors = true, -- 终端配色用主题色
    },
    -- priority = 1000 保证配色插件优先加载（其他插件可能依赖它）
    priority = 1000,
    -- lazy = false 表示不懒加载（启动时加载）
    lazy = false,
  },

  -- ========================================================================
  -- 模式 2：懒加载 spec（event + keys）
  -- ========================================================================
  -- 适用场景：命令式工具（搜索、文件树），按键或事件触发时才加载。
  -- 这个 spec 同时用了 keys（按键触发）和 event（事件触发），满足任一即加载。
  {
    "nvim-telescope/telescope.nvim",
    -- 依赖：plenary.nvim 必须在 telescope 之前加载
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    -- 懒加载策略 1：keys（按键触发加载）
    -- 完整形式：每个 key 是 { lhs, rhs, desc, mode? } table
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>",  desc = "查找文件" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>",   desc = "实时 grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>",     desc = "切换 buffer" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>",   desc = "查帮助" },
    },
    -- 懒加载策略 2：event（事件触发加载）
    -- 这里用 keys 就够了，event 作为补充（打开文件时也加载，让某些自动调用就绪）
    event = "VimEnter",
    -- opts = true 等价于 config = function() require("telescope").setup({}) end
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        sorting_strategy = "ascending",
      },
    },
    -- config 在 setup 后加载 fzf 扩展（需要 dependencies 已就绪）
    config = function(_, opts)
      require("telescope").setup(opts)
      pcall(require("telescope").load_extension, "fzf")
    end,
  },

  -- ========================================================================
  -- 模式 3：extend 模式（opts = function + vim.list_extend）
  -- ========================================================================
  -- 适用场景：扩展 LazyVim 内置插件的列表型字段。
  -- LazyVim 已为 nvim-treesitter 定义了默认 ensure_installed，
  -- 我们要追加语言，不能用 table 覆盖，必须用 function extend。
  {
    "nvim-treesitter/nvim-treesitter",
    -- opts = function(_, opts) ... end
    --   第一个参数 _：插件 spec（这里不用，用 _ 占位）
    --   第二个参数 opts：LazyVim 默认的 opts（引用传递，已包含默认的 ensure_installed）
    opts = function(_, opts)
      -- ✅ 正确：vim.list_extend 把你的语言追加到默认列表后面
      -- 默认列表（bash/c/css/html/...）全部保留，不会丢失
      vim.list_extend(opts.ensure_installed, {
        "lua",
        "vim",
        "vimdoc",
        "query",
        "regex",
        "markdown",
        "markdown_inline",
      })

      -- 也可以扩展非列表字段（用 vim.tbl_deep_extend）
      opts.highlight = vim.tbl_deep_extend("force", opts.highlight or {}, {
        enable = true,
        additional_vim_regex_highlighting = false,
      })
    end,
  },

  -- ========================================================================
  -- 补充模式：ft 懒加载（语言专属插件）
  -- ========================================================================
  -- 这个插件只在打开 Go 文件时才加载（ft = "go"）。
  -- 语言专属工具（LSP、调试器、格式化）推荐用 ft 懒加载。
  {
    "ray-x/go.nvim",
    ft = { "go", "gomod", "gowork", "gotmpl" },
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      goimports = "gopls",
      gofmt = "gofumpt",
      build_tags = "",
    },
    build = ':lua require("go.install").update_all_sync()',
  },

  -- ========================================================================
  -- 补充模式：cmd 懒加载（偶尔用的命令式插件）
  -- ========================================================================
  -- 这个插件只在运行 :LazyGit 命令时才加载。
  -- 偶尔用的工具（Git GUI、终端、数据库客户端）推荐用 cmd 懒加载。
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile", "LazyGitFilter" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "打开 LazyGit" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  -- ========================================================================
  -- 补充模式：禁用 LazyVim 默认插件（enabled = false）
  -- ========================================================================
  -- 如果你不想用 LazyVim 默认的某个插件，在 spec 里加 enabled = false。
  {
    "echasnovski/mini.animate",
    enabled = false,  -- 禁用滚动动画（有人觉得晃眼）
  },
}
