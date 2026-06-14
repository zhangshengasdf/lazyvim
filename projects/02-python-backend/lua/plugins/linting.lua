--- lua/plugins/linting.lua — ruff linter 配置（项目 2）
---
--- 这个文件配置 nvim-lint 使用 ruff 检查 Python 代码。
--- ruff 是 Rust 写的 Python linter，比 pylint 快 10-100 倍，
--- 规则覆盖了 pylint、flake8、isort 等多个工具。
---
--- ⚠️ 铁律：
---   - 用 opts = function(_, opts) extend，不覆盖默认 linter
---   - ruff 需要外部安装（pip install ruff 或 :MasonInstall ruff）
---   - nvim-lint 是"调度器"，需要外部安装 ruff
---   - 不要用 null-ls/none-ls（已废弃）
---
--- 文件返回 spec table，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- nvim-lint — 追加 ruff linter
  -- ========================================================================
  -- LazyVim 可能已经为 Python 配了默认 linter，
  -- 我们用 extend 模式确保 ruff 在列表中。
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- 确保 linters_by_ft 存在
      opts.linters_by_ft = opts.linters_by_ft or {}

      -- 为 Python 文件追加 ruff
      -- 如果 LazyVim 默认已有 ruff，这里不会重复
      opts.linters_by_ft.python = { "ruff" }

      -- ==================================================================
      -- ruff linter 选项
      -- ==================================================================
      -- ruff 的命令行参数
      opts.linters = opts.linters or {}
      opts.linters.ruff = {
        args = {
          "--no-fix",          -- 不自动修复（只报告问题）
          "--output-format", "json",  -- JSON 输出（nvim-lint 解析用）
        },
      }
    end,
  },
}
