--- lua/plugins/formatting.lua — prettier 格式化配置（项目 1）
---
--- 这个文件配置 conform.nvim 使用 prettier 格式化 TS/JS/CSS/HTML 等文件。
--- LazyVim 已经为 JS/TS 配好了 prettier，我们在这里微调选项。
---
--- ⚠️ 铁律：
---   - 用 opts = function(_, opts) extend，不覆盖默认格式化器
---   - prettier 选项通过 prepend_args 传给 CLI
---   - conform.nvim 是"调度器"，需要外部安装 prettier
---   - 不要用 null-ls/none-ls（已废弃）
---
--- 文件返回 spec table，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- conform.nvim — 追加 prettier 格式化器配置
  -- ========================================================================
  -- LazyVim 已经为 JS/TS 配好了 prettier，
  -- 我们用 extend 模式微调 prettier 的选项。
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- 确保 formatters_by_ft 存在
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      -- 追加 TSX/JSX 文件类型的格式化器
      -- LazyVim 默认已有 javascript/typescript，这里补充 react 文件类型
      opts.formatters_by_ft.typescriptreact = { "prettier" }
      opts.formatters_by_ft.javascriptreact = { "prettier" }

      -- 追加 CSS 相关文件类型的格式化器
      opts.formatters_by_ft.css = { "prettier" }
      opts.formatters_by_ft.scss = { "prettier" }
      opts.formatters_by_ft.less = { "prettier" }

      -- 追加 HTML 和 JSON 的格式化器
      opts.formatters_by_ft.html = { "prettier" }
      opts.formatters_by_ft.json = { "prettier" }
      opts.formatters_by_ft.jsonc = { "prettier" }

      -- 追加 Markdown 格式化器
      opts.formatters_by_ft.markdown = { "prettier" }

      -- ==================================================================
      -- prettier 格式化器选项
      -- ==================================================================
      -- prepend_args 会传给 prettier CLI
      -- 这些选项会覆盖项目本地的 .prettierrc（如果有冲突）
      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = {
        prepend_args = {
          "--tab-width", "2",        -- Tab 宽度 2 空格
          "--single-quote",          -- 使用单引号（默认双引号）
          "--jsx-single-quote",      -- JSX 也用单引号
          "--trailing-comma", "all", -- 尾逗号（ES5 兼容）
          "--semi",                  -- 使用分号（默认 true）
        },
      }
    end,
  },
}
