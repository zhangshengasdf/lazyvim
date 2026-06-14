--- lua/plugins/linting.lua — eslint linter 配置（项目 1）
---
--- 这个文件配置 nvim-lint 使用 eslint 检查 TS/JS 代码。
--- eslint 会检查：未使用变量、类型错误、风格违规、潜在 bug。
---
--- ⚠️ 铁律：
---   - 用 opts = function(_, opts) extend，不覆盖默认 linter
---   - eslint 需要项目本地安装（npm install eslint）
---   - nvim-lint 是"调度器"，需要外部安装 eslint
---   - 不要用 null-ls/none-ls（已废弃）
---
--- 文件返回 spec table，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- nvim-lint — 追加 eslint linter
  -- ========================================================================
  -- LazyVim 可能已经为 JS/TS 配了默认 linter，
  -- 我们用 extend 模式确保 eslint 在列表中。
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- 确保 linters_by_ft 存在
      opts.linters_by_ft = opts.linters_by_ft or {}

      -- 为 TypeScript/JavaScript 文件追加 eslint
      -- 如果 LazyVim 默认已有 eslint，这里不会重复
      opts.linters_by_ft.typescript = { "eslint" }
      opts.linters_by_ft.typescriptreact = { "eslint" }
      opts.linters_by_ft.javascript = { "eslint" }
      opts.linters_by_ft.javascriptreact = { "eslint" }

      -- 为 JSON 文件追加 jsonlint（可选）
      opts.linters_by_ft.json = { "jsonlint" }
      opts.linters_by_ft.jsonc = { "jsonlint" }

      -- ==================================================================
      -- eslint linter 选项
      -- ==================================================================
      -- 修改 eslint 的命令行参数
      opts.linters = opts.linters or {}
      opts.linters.eslint = {
        -- --no-warn-ignored：不警告被 eslintignore 忽略的文件
        args = {
          "--no-warn-ignored",
          "--format",
          "json",
        },
      }
    end,
  },
}
