--- lua/plugins/extra.lua — Tailwind LSP + JS/TS 调试器 + Treesitter（项目 1）
---
--- 这个文件配置额外的开发工具：
---   1. tailwindcss LSP：CSS 类名补全、颜色预览
---   2. nvim-dap + js-debug：Node.js / 浏览器断点调试
---   3. Treesitter：追加 TS/TSX/CSS/JSON 等语言解析器
---
--- ⚠️ 铁律：
---   - nvim-dap 用 keys 懒加载（调试时才用）
---   - Tailwind LSP 和 vtsls 共存（lazy.nvim 会合并 servers）
---   - Treesitter 用 vim.list_extend extend（不覆盖默认语言）
---   - 所有快捷键必须带 desc
---
--- 文件返回 spec table 列表，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- Tailwind CSS LSP — 类名补全 + 颜色预览
  -- ========================================================================
  -- tailwindcss-language-server 提供：
  --   - 类名补全（输入 "cl" 弹出 class:list 补全）
  --   - 颜色预览（bg-red-500 前面显示红色方块）
  --   - CSS 诊断（无效的 Tailwind 类名会标红）
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {},
      },
    },
  },

  -- ========================================================================
  -- nvim-dap + js-debug — JavaScript/TypeScript 调试器
  -- ========================================================================
  -- nvim-dap 是 DAP 协议客户端（第 16 章）
  -- js-debug 是 VS Code 的 JavaScript 调试器，通过 Mason 安装
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- nvim-dap-vscode-js：JS/TS 调试适配器
      {
        "mxsdev/nvim-dap-vscode-js",
        config = function()
          local ok, dap_js = pcall(require, "dap-vscode-js")
          if ok then
            dap_js.setup({
              -- 调试器路径（Mason 安装位置）
              debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter",
              -- 支持的调试类型
              adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal" },
            })
          end
        end,
      },
    },
    keys = {
      -- 调试 Node.js 文件
      {
        "<leader>dN",
        function()
          local ok, dap = pcall(require, "dap")
          if ok then
            dap.run({
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = "${workspaceFolder}",
            })
          end
        end,
        desc = "DAP: 调试当前 Node.js 文件",
      },
      -- 调试 Jest 测试
      {
        "<leader>dT",
        function()
          local ok, dap = pcall(require, "dap")
          if ok then
            dap.run({
              type = "pwa-node",
              request = "launch",
              name = "Debug Jest Tests",
              -- jest 测试运行器
              runtimeExecutable = "node",
              runtimeArgs = {
                "./node_modules/.bin/jest",
                "--runInBand",
              },
              rootPath = "${workspaceFolder}",
              cwd = "${workspaceFolder}",
              console = "integratedTerminal",
              internalConsoleOptions = "neverOpen",
            })
          end
        end,
        desc = "DAP: 调试 Jest 测试",
      },
    },
  },

  -- ========================================================================
  -- Treesitter — 追加语言解析器
  -- ========================================================================
  -- 用 vim.list_extend extend 默认的 ensure_installed 列表（第 11 章模式）
  -- 追加 TS/TSX/CSS/JSON 等全栈开发常用的解析器
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "typescript",
        "tsx",
        "css",
        "scss",
        "html",
        "json",
        "jsonc",
        "graphql",
        "markdown",
        "markdown_inline",
        "regex",
      })
    end,
  },

  -- ========================================================================
  -- nvim-treesitter-textobjects — TS 代码的文本对象
  -- ========================================================================
  -- LazyVim 已内置此插件，这里用 extend 追加 TS 相关的文本对象
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    opts = function(_, opts)
      -- 扩展选择范围（select）
      opts.select = vim.tbl_deep_extend("force", opts.select or {}, {
        enable = true,
        keymaps = {
          -- 函数定义：vaf / vif
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          -- 类定义：vac / vic
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          -- 参数：via
          ["ia"] = "@parameter.inner",
        },
      })
    end,
  },
}
