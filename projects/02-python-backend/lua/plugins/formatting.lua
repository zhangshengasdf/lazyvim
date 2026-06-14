--- lua/plugins/formatting.lua — black 格式化配置（项目 2）
---
--- 这个文件配置 conform.nvim 使用 black 格式化 Python 代码。
--- black 是 Python 社区最流行的格式化器（"不妥协的格式化器"）。
---
--- ⚠️ 铁律：
---   - 用 opts = function(_, opts) extend，不覆盖默认格式化器
---   - black 选项通过 prepend_args 传给 CLI
---   - conform.nvim 是"调度器"，需要外部安装 black
---   - 不要用 null-ls/none-ls（已废弃）
---
--- 文件返回 spec table，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- conform.nvim — 追加 black 格式化器配置
  -- ========================================================================
  -- LazyVim 已经为 Python 配好了 black，
  -- 我们用 extend 模式微调 black 的选项。
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- 确保 formatters_by_ft 存在
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      -- LazyVim 默认已为 python 配了 { "black" }，
      -- 这里用 extend 模式追加 isort（import 排序）
      -- black 和 isort 串行执行：先 isort 排序 import，再 black 格式化
      if opts.formatters_by_ft.python then
        vim.list_extend(opts.formatters_by_ft.python, { "isort" })
      else
        opts.formatters_by_ft.python = { "black", "isort" }
      end

      -- ==================================================================
      -- black 格式化器选项
      -- ==================================================================
      -- prepend_args 会传给 black CLI
      opts.formatters = opts.formatters or {}
      opts.formatters.black = {
        prepend_args = {
          "--line-length", "88",  -- 行宽 88（black 默认值，PEP 8 推荐 79）
          "--target-version", "py312",  -- 目标 Python 版本
        },
      }

      -- ==================================================================
      -- isort 格式化器选项
      -- ==================================================================
      -- isort 排序 Python import 语句
      -- profile = "black" 让 isort 的风格与 black 兼容
      opts.formatters.isort = {
        prepend_args = {
          "--profile", "black",  -- 与 black 风格兼容
          "--line-length", "88", -- 与 black 行宽一致
        },
      }
    end,
  },
}
