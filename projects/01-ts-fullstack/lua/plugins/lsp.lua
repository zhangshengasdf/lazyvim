--- lua/plugins/lsp.lua — vtsls LSP 配置（项目 1）
---
--- 这个文件配置 TypeScript/JavaScript 语言服务器。
--- LazyVim 默认用 vtsls（TypeScript Language Server 增强版），
--- 我们在这里微调它的 settings。
---
--- ⚠️ 铁律：
---   - 用 opts = function(_, opts) extend，不覆盖默认服务器
---   - vtsls 和 tsserver 不能同时启用（选一个）
---   - 空 table {} 表示用默认配置
---   - servers 里不要写 require（会在插件加载前求值）
---
--- 文件返回 spec table，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- nvim-lspconfig — 追加 vtsls 服务器配置
  -- ========================================================================
  -- LazyVim 已经配好了 vtsls 的默认设置，
  -- 我们用 extend 模式微调 inlay hints 和其他选项。
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- vtsls：TypeScript/JavaScript 语言服务器
        -- LazyVim 推荐用 vtsls 而非 tsserver（功能更强）
        vtsls = {
          settings = {
            typescript = {
              inlayHints = {
                -- 函数参数名：在调用处显示参数名
                -- 例：fn(x, y) → fn(name: x, value: y)
                includeInlayParameterNameHints = "all",
                -- 函数参数类型：在参数名后显示类型
                -- 例：fn(x) → fn(x: string)
                includeInlayFunctionParameterTypeHints = true,
                -- 变量类型：在变量声明处显示类型
                -- 例：const x = 5 → const x: number = 5
                includeInlayVariableTypeHints = true,
                -- 属性类型：在属性声明处显示类型
                includeInlayPropertyDeclarationTypeHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
              },
            },
            vtsls = {
              -- 自动使用工作区的 TypeScript 版本
              autoUseWorkspaceTsdk = true,
            },
          },
        },
      },
    },
  },

  -- ========================================================================
  -- mason.nvim — 确保 vtsls 已安装
  -- ========================================================================
  -- LazyVim 通过 mason-lspconfig 自动安装声明的服务器，
  -- 但你也可以用 mason spec 显式声明要安装的包。
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      -- 用 vim.list_extend 追加，不覆盖默认列表
      vim.list_extend(opts.ensure_installed or {}, {
        "vtsls",               -- TypeScript/JavaScript LSP
        "eslint-lsp",          -- ESLint LSP（代码检查）
        "prettier",            -- Prettier 格式化器
      })
    end,
  },
}
