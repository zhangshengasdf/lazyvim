--- lua/plugins/lsp.lua — LSP + Mason + 补全（项目 4）
---
--- 从零配置 LSP 和补全，不依赖 LazyVim 的预配置。
--- 对照 Ch12 和 Ch13 的内容，这里是你自己写的完整 spec。
---
--- LazyVim 帮你做的事情（你需要自己写）：
---   1. 安装 nvim-lspconfig + mason.nvim + mason-lspconfig.nvim
---   2. 配置 LSP 服务器（lua_ls、pyright、ts_ls 等）
---   3. 注册 LSP 快捷键（gd、gr、K、<leader>ca 等）
---   4. 安装 nvim-cmp + 补全源（LSP、路径、buffer、snippet）
---   5. 配置补全映射（Tab/Shift-Tab 选择、Enter 确认）
---
--- 本文件是整个项目中最复杂的——LSP + 补全有 100+ 行。
--- LazyVim 的默认配置有 300+ 行。

return {
  -- ========================================================================
  -- mason.nvim — LSP/DAP/Linter/Formatter 安装管理器
  -- ========================================================================
  -- Mason 管理外部工具的安装（LSP 服务器、调试器等）。
  -- 它是"安装器"，不管理配置。
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = {
      { "<leader>cm", "<cmd>Mason<CR>", desc = "Mason 管理器" },
    },
    opts = {
      -- 确保安装这些工具
      -- Mason 会自动安装缺失的工具
      ensure_installed = {
        "lua-language-server",   -- Lua LSP
        "stylua",                -- Lua 格式化器
        "pyright",               -- Python LSP
        "ruff",                  -- Python Linter
        "typescript-language-server", -- TypeScript LSP
        "prettier",              -- 通用格式化器
      },
    },
    -- config 函数：在 setup 后检查并安装缺失的工具
    config = function(_, opts)
      require("mason").setup(opts)

      -- 自动安装 ensure_installed 中的工具
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          -- 触发 FileType 事件，让 LSP 重新连接
          vim.cmd("do User MasonToolsInstallCompleted")
        end, 100)
      end)

      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end

      -- 如果 registry 已就绪，立即安装；否则等待
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },

  -- ========================================================================
  -- mason-lspconfig.nvim — Mason 和 lspconfig 的桥梁
  -- ========================================================================
  -- mason-lspconfig 连接 Mason（安装器）和 lspconfig（配置器）。
  -- 它让 Mason 安装的 LSP 服务器自动被 lspconfig 识别。
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    opts = {
      -- 确保安装这些 LSP 服务器
      ensure_installed = {
        "lua_ls",      -- Lua
        "pyright",     -- Python
        "ts_ls",       -- TypeScript
      },
      -- 自动安装 ensure_installed 中的服务器
      automatic_installation = true,
    },
  },

  -- ========================================================================
  -- nvim-lspconfig — LSP 客户端配置
  -- ========================================================================
  -- lspconfig 提供每个 LSP 服务器的默认配置。
  -- 你需要告诉它用哪些服务器、怎么配置它们。
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local lspconfig = require("lspconfig")

      -- LSP 快捷键绑定函数
      -- 在 LSP 连接到 buffer 时注册（on_attach 模式）
      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
        end

        -- 导航
        map("gd", vim.lsp.buf.definition, "跳转到定义")
        map("gr", vim.lsp.buf.references, "查找引用")
        map("gI", vim.lsp.buf.implementation, "跳转到实现")
        map("gy", vim.lsp.buf.type_definition, "跳转到类型定义")

        -- 信息
        map("K", vim.lsp.buf.hover, "悬停文档")
        map("gK", vim.lsp.buf.signature_help, "函数签名")

        -- 操作
        map("<leader>ca", vim.lsp.buf.code_action, "代码操作")
        map("<leader>cr", vim.lsp.buf.rename, "重命名")
        map("<leader>cf", function()
          vim.lsp.buf.format({ async = true })
        end, "格式化")

        -- 诊断
        map("<leader>cd", vim.diagnostic.open_float, "行内诊断")
        map("[d", vim.diagnostic.goto_prev, "上一个诊断")
        map("]d", vim.diagnostic.goto_next, "下一个诊断")
      end

      -- 获取补全能力（nvim-cmp 需要）
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      -- 配置 LSP 服务器
      -- 这里手动列出每个服务器的配置（LazyVim 有 20+ 个）
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        pyright = {},
        ts_ls = {},
      }

      -- 设置每个服务器
      for server, settings in pairs(servers) do
        lspconfig[server].setup({
          on_attach = on_attach,
          capabilities = capabilities,
          settings = settings,
        })
      end
    end,
  },

  -- ========================================================================
  -- nvim-cmp — 补全引擎
  -- ========================================================================
  -- nvim-cmp 是 Neovim 最流行的补全框架。
  -- 你需要手动配置：源（LSP、路径、buffer、snippet）和映射。
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",   -- LSP 补全源
      "hrsh7th/cmp-buffer",     -- Buffer 补全源
      "hrsh7th/cmp-path",       -- 路径补全源
      "L3MON4D3/LuaSnip",      -- Snippet 引擎
      "saadparwaiz1/cmp_luasnip", -- Snippet 补全源
      "rafamadriz/friendly-snippets", -- 常用 snippet 集合
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- 加载 friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        -- snippet 引擎
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        -- 补全源（按优先级排序）
        sources = cmp.config.sources({
          { name = "nvim_lsp" },  -- LSP 补全（最高优先级）
          { name = "luasnip" },   -- Snippet
          { name = "path" },      -- 路径
        }, {
          { name = "buffer" },    -- Buffer 内容（次优先级）
        }),

        -- 快捷键映射
        mapping = cmp.mapping.preset.insert({
          -- 导航
          ["<C-n>"] = cmp.mapping.select_next_item(),   -- 下一项
          ["<C-p>"] = cmp.mapping.select_prev_item(),   -- 上一项
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),       -- 文档向上滚
          ["<C-f>"] = cmp.mapping.scroll_docs(4),        -- 文档向下滚

          -- 确认
          ["<C-Space>"] = cmp.mapping.complete(),        -- 手动触发补全
          ["<C-e>"] = cmp.mapping.abort(),               -- 取消补全
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- 确认选择

          -- Tab / Shift-Tab 导航
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        -- 补全窗口样式
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })
    end,
  },
}
