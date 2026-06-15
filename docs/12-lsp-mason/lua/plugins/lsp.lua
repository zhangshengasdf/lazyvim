--- lua/plugins/lsp.lua — LSP 语言服务器配置示例（第12章）
---
--- 这个文件演示如何配置 3 个典型语言服务器：lua_ls、pyright、ts_ls。
--- LazyVim 通过 nvim-lspconfig + mason-lspconfig 自动管理安装和配置。
--- 你只需要在 servers 里声明"我要用哪些服务器"，Mason 会自动安装。
---
--- ⚠️ 注意：
---   - servers 里的值是 table（配置），不是 require() 调用
---   - 空 table {} 表示用默认配置（Mason 自动安装 + lspconfig 默认 settings）
---   - 不要同时启用多个同语言的 LSP（pyright 和 pylsp 会冲突）
---
--- 文件返回一个 spec table，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- 核心 spec：nvim-lspconfig 语言服务器配置
  -- ========================================================================
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- ==================================================================
        -- Lua 语言服务器（lua_ls）
        -- ==================================================================
        -- LazyVim 已内置合理的默认配置（识别 vim 全局变量、加载运行时库）。
        -- 这里展示如何在默认基础上微调。
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                -- 添加 Neovim 运行时文件到工作区
                -- 让 lua_ls 理解 vim.api.* 等函数的类型信息
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,  -- 不弹窗询问是否添加第三方库
              },
              diagnostics = {
                -- 识别 `vim` 全局变量（避免 "undefined global 'vim'" 警告）
                globals = { "vim" },
              },
              completion = {
                callSnippet = "Replace",  -- 补全函数时展开参数片段
              },
              telemetry = {
                enable = false,  -- 关闭遥测（隐私考虑）
              },
            },
          },
        },

        -- ==================================================================
        -- Python 语言服务器（pyright）
        -- ==================================================================
        -- pyright 是微软开发的 Python 类型检查器和语言服务器。
        -- 它比 pylsp 更快、类型推断更准确。
        pyright = {
          settings = {
            python = {
              analysis = {
                -- 类型检查模式：basic（推荐）/ strict / off
                -- basic 只报告明显错误，strict 非常严格
                typeCheckingMode = "basic",
                -- 自动搜索 Python 路径（虚拟环境、conda 等）
                autoSearchPaths = true,
                -- 用已安装库的类型信息（需要 pyright 内置的 type stubs）
                useLibraryCodeForTypes = true,
                -- 诊断范围：workspace（分析整个项目）/ openFilesOnly（只分析打开的文件）
                diagnosticMode = "workspace",
              },
            },
          },
        },

        -- ==================================================================
        -- TypeScript/JavaScript 语言服务器（ts_ls）
        -- ==================================================================
        -- ts_ls 是 TypeScript 官方的语言服务器。
        -- 它同时支持 JavaScript 和 TypeScript。
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                -- 参数名提示：在调用处显示参数名
                -- fn(name: string, age: number) → fn(name: "Alice", age: 30)
                includeInlayParameterNameHints = "all",
                -- 函数参数类型提示
                includeInlayFunctionParameterTypeHints = true,
                -- 变量类型提示
                includeInlayVariableTypeHints = true,
                -- 属性声明类型提示
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
          },
        },

        -- ==================================================================
        -- 更多服务器（只需取消注释即可启用）
        -- ==================================================================
        -- Go 语言服务器
        -- gopls = {},
        --
        -- Rust 语言服务器
        -- rust_analyzer = {},
        --
        -- C/C++ 语言服务器
        -- clangd = {},
        --
        -- CSS 语言服务器
        -- cssls = {},
        --
        -- HTML 语言服务器
        -- html = {},
        --
        -- JSON 语言服务器
        -- jsonls = {},
      },
    },
  },

  -- ========================================================================
  -- 辅助 spec：Mason 确保语言服务器已安装
  -- ========================================================================
  -- mason-lspconfig 会自动把你声明的 servers 对应的 LSP 安装好。
  -- 如果你想额外安装一些不在 servers 里的工具（比如 linter、formatter），
  -- 可以在这里扩展。
  {
    "williamboman/mason.nvim",
    opts = {
      -- ensure_installed 用 extend 模式（和 Treesitter 一样的铁律）
      -- 这里追加的是 Mason 管理的工具（不限于 LSP）
    },
  },
}
