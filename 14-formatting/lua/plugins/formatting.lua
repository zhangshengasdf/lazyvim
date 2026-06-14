--- lua/plugins/formatting.lua — conform.nvim + nvim-lint 配置（第14章）
---
--- 这个文件演示如何用 extend 模式配置格式化器和 linter。
--- LazyVim 已经配好了默认的格式化器和 linter，
--- 我们只需要追加或调整，不能覆盖。
---
--- ⚠️ 铁律：
---   - 追加格式化器用 vim.list_extend(opts.formatters_by_ft.xxx, {...})
---   - 追加 linter 用 table.insert(opts.linters_by_ft.xxx, ...)
---   - 不要用 opts = { formatters_by_ft = {...} } 直接覆盖默认配置
---   - 不要用 null-ls/none-ls（已废弃），用 conform + nvim-lint
---
--- 文件返回一个 spec table 列表，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- 配置 1：conform.nvim — 追加格式化器
  -- ========================================================================
  -- 适用场景：给某种文件类型添加新的格式化器，或添加新的文件类型。
  -- 关键：用 vim.list_extend 追加，不覆盖默认格式化器。
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- ✅ 正确：追加新的文件类型
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.toml = { "taplo" }
      opts.formatters_by_ft.yaml = { "yq" }

      -- ✅ 正确：给已有文件类型追加格式化器
      -- JavaScript 先用 prettier，再用 eslint（串行执行）
      if opts.formatters_by_ft.javascript then
        vim.list_extend(opts.formatters_by_ft.javascript, { "eslint" })
      end
    end,
  },

  -- ========================================================================
  -- 配置 2：conform.nvim — 修改格式化器选项
  -- ========================================================================
  -- 适用场景：你想调整某个格式化器的行为（比如 prettier 的 tab 宽度）。
  -- 关键：修改 opts.formatters.xxx 的参数。
  -- {
  --   "stevearc/conform.nvim",
  --   opts = function(_, opts)
  --     opts.formatters = opts.formatters or {}
  --     opts.formatters.prettier = {
  --       prepend_args = { "--tab-width", "2", "--single-quote" },
  --     }
  --     opts.formatters.stylua = {
  --       prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
  --     }
  --   end,
  -- },

  -- ========================================================================
  -- 配置 3：nvim-lint — 追加 linter
  -- ========================================================================
  -- 适用场景：给某种文件类型添加新的 linter。
  -- 关键：用 table.insert 追加，不覆盖默认 linter。
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- ✅ 正确：追加新的文件类型
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.dockerfile = { "hadolint" }
      opts.linters_by_ft.sh = { "shellcheck" }

      -- ✅ 正确：给已有文件类型追加 linter
      -- CSS 先用 stylelint（如果有），再用默认的
      opts.linters_by_ft.css = opts.linters_by_ft.css or {}
      table.insert(opts.linters_by_ft.css, "stylelint")
    end,
  },

  -- ========================================================================
  -- 配置 4：nvim-lint — 修改 linter 选项
  -- ========================================================================
  -- 适用场景：你想调整某个 linter 的行为（比如 eslint 的规则文件）。
  -- 关键：修改 opts.linters.xxx 的参数。
  -- {
  --   "mfussenegger/nvim-lint",
  --   opts = function(_, opts)
  --     opts.linters = opts.linters or {}
  --     opts.linters.eslint = {
  --       args = { "--no-warn-ignored", "--format", "json" },
  --     }
  --   end,
  -- },

  -- ========================================================================
  -- 配置 5：禁用特定文件类型的自动格式化
  -- ========================================================================
  -- 适用场景：某些文件类型你不想自动格式化（比如 Markdown 写作时）。
  -- 关键：用 conform 的 format_on_save 回调过滤。
  -- {
  --   "stevearc/conform.nvim",
  --   opts = function(_, opts)
  --     opts.format_on_save = function(bufnr)
  --       -- 在 Markdown 文件里禁用自动格式化
  --       local ft = vim.bo[bufnr].filetype
  --       if ft == "markdown" or ft == "text" then
  --         return
  --       end
  --       return { timeout_ms = 500, lsp_format = "fallback" }
  --     end
  --   end,
  -- },
}
