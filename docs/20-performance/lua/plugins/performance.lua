--- lua/plugins/performance.lua — lazy.nvim 性能优化 spec（第20章）
---
--- 这个文件展示插件级别的性能优化策略：
---   1. 用 ft 代替 event 做语言插件的懒加载
---   2. 用 keys 代替 event 做命令式工具的懒加载
---   3. 用 cmd 做偶尔用的插件的懒加载
---   4. 禁用不需要的 LazyVim 默认插件
---
--- ⚠️ 铁律：extend 不 overwrite（第06章）
---    扩展列表字段用 opts = function(_, opts) vim.list_extend(...) end
---
--- 文件返回 spec table，luafile 加载不会报错。

return {
    -- ========================================================================
    -- 策略 1：用 ft 代替 event 加载语言专属插件
    -- ========================================================================
    -- event = "BufReadPost" 意味着每次打开任何文件都加载。
    -- 如果插件只服务特定语言，用 ft 更精确。
    --
    -- 对比：
    --   event = "BufReadPost"  → 所有文件打开时加载（浪费）
    --   ft = { "go", "gomod" } → 只打开 Go 文件时加载（精确）

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
        },
    },

    -- Rust 专属工具：只在打开 Rust 文件时加载
    {
        "mrcjkb/rustaceanvim",
        ft = { "rust" },
        lazy = false, -- rustaceanvim 自己管理懒加载，需要 lazy = false
    },

    -- ========================================================================
    -- 策略 2：用 keys 代替 event 加载命令式工具
    -- ========================================================================
    -- event = "VeryLazy" 意味着启动后 100ms 加载。
    -- 如果插件只在按键时使用，用 keys 更精确。
    --
    -- 对比：
    --   event = "VeryLazy"      → 启动后自动加载（浪费 0ms，但占内存）
    --   keys = { "<leader>ff" } → 按键时才加载（真正的懒加载）

    {
        "nvim-telescope/telescope.nvim",
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件" },
            { "<leader>fg", "<cmd>Telescope live_grep<CR>",  desc = "实时 grep" },
            { "<leader>fb", "<cmd>Telescope buffers<CR>",    desc = "切换 buffer" },
            { "<leader>fh", "<cmd>Telescope help_tags<CR>",  desc = "查帮助" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",
        },
        opts = {
            defaults = {
                layout_strategy = "horizontal",
                sorting_strategy = "ascending",
            },
        },
        config = function(_, opts)
            local ok, telescope = pcall(require, "telescope")
            if not ok then
                return
            end
            telescope.setup(opts)
            pcall(telescope.load_extension, "fzf")
        end,
    },

    -- ========================================================================
    -- 策略 3：用 cmd 做偶尔用的插件的懒加载
    -- ========================================================================
    -- cmd = { "LazyGit" } 意味着运行 :LazyGit 命令时才加载。
    -- 适合偶尔用的工具（Git GUI、终端、数据库客户端）。

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
    -- 策略 4：禁用不需要的 LazyVim 默认插件
    -- ========================================================================
    -- 如果你不用某个 LazyVim 默认插件，用 enabled = false 禁用它。
    -- 这比在 runtime 里删除插件更干净。

    -- 禁用滚动动画（有人觉得晃眼，纯视觉效果，不影响功能）
    {
        "echasnovski/mini.animate",
        enabled = false,
    },

    -- 禁用缩进线（如果你不用 indent-blankline）
    -- {
    --     "lukas-reineke/indent-blankline.nvim",
    --     enabled = false,
    -- },

    -- ========================================================================
    -- 策略 5：用 event = "VeryLazy" 做非紧急插件的延迟加载
    -- ========================================================================
    -- VeryLazy 事件在 Neovim 启动后约 100ms 触发。
    -- 适合"启动时不需要，但很快就会用到"的插件。
    --
    -- 对比：
    --   不设 event/keys/ft/cmd → 启动时加载（阻塞）
    --   event = "VeryLazy"     → 启动后 100ms 加载（不阻塞启动）

    {
        "folke/todo-comments.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        opts = {},
        keys = {
            { "]t",         function() require("todo-comments").jump_next() end, desc = "下一个 TODO" },
            { "[t",         function() require("todo-comments").jump_prev() end, desc = "上一个 TODO" },
            { "<leader>xt", "<cmd>TodoTrouble<CR>",                              desc = "TODO 列表" },
            { "<leader>st", "<cmd>TodoTelescope<CR>",                            desc = "搜索 TODO" },
        },
    },

    -- ========================================================================
    -- 策略 6：Treesitter 解析器的懒加载
    -- ========================================================================
    -- Treesitter 解析器本身用 event = "BufReadPost" 加载（合理），
    -- 但 ensure_installed 列表不要太长（每个解析器安装都要时间）。
    -- 只安装你真正用的语言。

    {
        "nvim-treesitter/nvim-treesitter",
        -- LazyVim 默认用 event = "BufReadPost"，这是合理的
        -- 但你可以用 opts = function extend 解析器列表
        opts = function(_, opts)
            -- extend 不 overwrite（第06章铁律）
            -- 追加你需要的语言，不要覆盖默认列表
            vim.list_extend(opts.ensure_installed, {
                "lua",
                "vim",
                "vimdoc",
                "query",
                "markdown",
                "markdown_inline",
            })
        end,
    },
}
