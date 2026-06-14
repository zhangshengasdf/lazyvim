--- lua/plugins/lsp.lua — pyright LSP 配置（项目 2）
---
--- 这个文件配置 Python 语言服务器 pyright。
--- pyright 是 TypeScript 团队开发的 Python 类型检查器，
--- 提供跳转、补全、类型检查、诊断等 LSP 能力。
---
--- ⚠️ 铁律：
---   - 用 opts = function(_, opts) extend，不覆盖默认服务器
---   - pyright 和 pylsp 不能同时启用（选一个）
---   - 空 table {} 表示用默认配置
---   - servers 里不要写 require（会在插件加载前求值）
---
--- 文件返回 spec table，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- nvim-lspconfig — 追加 pyright 服务器配置
  -- ========================================================================
  -- LazyVim 已经配好了 pyright 的默认设置，
  -- 我们用 extend 模式微调 typeCheckingMode 和其他选项。
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- pyright：Python 类型检查器和语言服务器
        -- 比 pylsp 更快、类型检查更强（VS Code 的 Python 插件也用它）
        pyright = {
          settings = {
            python = {
              analysis = {
                -- 类型检查模式：
                --   "off"    — 不做类型检查（只提供补全和跳转）
                --   "basic"  — 基础类型检查（推荐，不吵）
                --   "strict" — 严格类型检查（很吵，适合类型要求高的项目）
                typeCheckingMode = "basic",

                -- 自动搜索导入路径
                -- pyright 会自动查找项目中的 src/、app/ 等目录
                autoSearchPaths = true,

                -- 使用库代码做类型推断
                -- 如果你的依赖有 .pyi 类型存根文件，补全会更准确
                useLibraryCodeForTypes = true,

                -- 诊断模式：
                --   "openFilesOnly" — 只分析打开的文件（快，推荐大项目）
                --   "workspace"     — 分析整个工作区（慢，但诊断更全面）
                diagnosticMode = "openFilesOnly",

                -- 忽略某些诊断（减少噪音）
                -- 你可以根据项目需求添加更多
                ignore = {},
              },
            },
          },
        },
      },
    },
  },

  -- ========================================================================
  -- mason.nvim — 确保 pyright 已安装
  -- ========================================================================
  -- LazyVim 通过 mason-lspconfig 自动安装声明的服务器，
  -- 但你也可以用 mason spec 显式声明要安装的包。
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        "pyright",    -- Python LSP
        "black",      -- Python 格式化器
        "ruff",       -- Python linter（替代 pylint）
        "debugpy",    -- Python 调试器
      })
    end,
  },
}
