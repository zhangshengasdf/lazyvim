--- lua/plugins/treesitter.lua — nvim-treesitter extend 模式 spec（第11章）
---
--- 这个文件演示如何用 extend 模式安全地扩展 Treesitter 解析器列表。
---
--- ⚠️ 铁律：
---   - 扩展 ensure_installed 列表用 opts = function(_, opts) vim.list_extend(...) end
---   - 不要直接用 opts = { ensure_installed = {...} } —— 那会覆盖默认值
---
--- 文件返回一个 spec table，直接 luafile 加载不会报错（require 在 opts function 里，
--- 只有插件加载后才会执行）。

return {
  -- ========================================================================
  -- 核心 spec：extend ensure_installed
  -- ========================================================================
  {
    "nvim-treesitter/nvim-treesitter",
    -- opts = function 接收默认 opts（引用传递），安全扩展列表
    opts = function(_, opts)
      -- ✅ 正确：vim.list_extend 追加到默认列表后面
      -- LazyVim 默认的 bash/c/css/html/js/json/lua/python/vim/vimdoc 全部保留
      vim.list_extend(opts.ensure_installed, {
        -- 常用 Web 开发
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "json",
        "jsonc",
        "yaml",
        "toml",

        -- 脚本语言
        "lua",
        "python",
        "bash",
        "fish",

        -- 系统语言
        "rust",
        "go",
        "c",
        "cpp",

        -- 文档和配置
        "markdown",
        "markdown_inline",
        "vim",
        "vimdoc",
        "regex",
        "query",

        -- 其他常用
        "dockerfile",
        "sql",
        "gitignore",
        "comment",  -- 智能注释高亮 (TODO, FIXME 等)
      })

      -- 配置高亮模块（用 tbl_deep_extend 安全合并）
      opts.highlight = vim.tbl_deep_extend("force", opts.highlight or {}, {
        enable = true,
        -- 关闭传统正则高亮（Treesitter 接管后不需要）
        additional_vim_regex_highlighting = false,
      })
    end,
  },

  -- ========================================================================
  -- 辅助 spec：文本对象插件（LazyVim 已内置，这里演示如何配置）
  -- ========================================================================
  -- nvim-treesitter-textobjects 提供基于语法树的文本对象
  -- vaf = 选中整个函数, vir = 选中函数体, vaa = 选中参数, ...
  -- 如果需要自定义按键，在这里扩展：
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    -- LazyVim 已配置默认文本对象，这里演示如何追加/修改
    opts = function(_, opts)
      -- 自定义选择模式的文本对象按键
      opts.select = vim.tbl_deep_extend("force", opts.select or {}, {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
        },
      })

      -- 自定义移动模式的按键（在函数/类之间跳转）
      opts.move = vim.tbl_deep_extend("force", opts.move or {}, {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]f"] = "@function.outer",
          ["]c"] = "@class.outer",
        },
        goto_next_end = {
          ["]F"] = "@function.outer",
          ["]C"] = "@class.outer",
        },
        goto_previous_start = {
          ["[f"] = "@function.outer",
          ["[c"] = "@class.outer",
        },
        goto_previous_end = {
          ["[F"] = "@function.outer",
          ["[C"] = "@class.outer",
        },
      })
    end,
  },

  -- ========================================================================
  -- 辅助 spec：语法树调试（可选）
  -- ========================================================================
  -- 安装后运行 :TSPlaygroundToggle 打开语法树查看器
  -- 用于调试高亮规则和理解 Treesitter 查询
  {
    "nvim-treesitter/playground",
    cmd = "TSPlaygroundToggle",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
