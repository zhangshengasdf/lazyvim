--- lua/plugins/formatting.lua — Markdown 表格格式化（项目 3）
---
--- 本文件扩展 LazyVim 的 conform.nvim 配置，
--- 添加 Markdown 表格自动对齐功能。
---
--- 表格对齐是写作中最常见的格式化需求：
---   | 列1 | 列2 | 列3 |
---   | --- | --- | --- |
---   | a   | bb  | ccc |
---
--- 手动对齐很痛苦，自动对齐只需保存一次。
---
--- ⚠️ 铁律：用 opts = function + vim.list_extend 扩展，
---   不要用 opts = { ... } 覆盖 LazyVim 默认配置。
---
--- 文件返回 spec table，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- 1. conform.nvim — Markdown 格式化扩展
  -- ========================================================================
  -- LazyVim 已经用 conform.nvim 作为格式化引擎（Ch14）。
  -- 我们只需要追加 Markdown 的格式化器配置。
  --
  -- 格式化器选择：
  --   - prettier：通用格式化器，支持 Markdown 表格对齐
  --   - mdformat：纯 Markdown 格式化器（更轻量）
  --   - markdown-toc：自动生成目录（可选）
  --
  -- 这里用 prettier（最成熟、社区最广）。
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- 确保 formatters_by_ft 存在
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      -- 追加 markdown 格式化器（不覆盖 LazyVim 可能已有的配置）
      opts.formatters_by_ft.markdown = opts.formatters_by_ft.markdown or {}
      vim.list_extend(opts.formatters_by_ft.markdown, { "prettier" })

      -- 配置 prettier 的 Markdown 选项
      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = {
        -- 使用 prettier 的 Markdown 专用选项
        prepend_args = {
          "--prose-wrap", "always",     -- 长行自动换行
          "--tab-width", "2",           -- 表格缩进 2 空格
          "--print-width", "80",        -- 每行最多 80 字符
        },
      }
    end,
  },

  -- ========================================================================
  -- 2. 自动格式化开关（写作场景）
  -- ========================================================================
  -- 写作时，自动格式化很有用（保存时自动对齐表格、换行长段落）。
  -- 但有时你不想要自动格式化（比如在写 YAML frontmatter 时）。
  --
  -- 这里用 autocmd 为 Markdown 文件启用保存时自动格式化。
  -- Ch18 模式：用 augroup 注册 autocmd。
  {
    "folke/lazy.nvim",
    -- 这个 spec 不加载任何插件，只注册 autocmd
    -- 用 init（启动时执行）而非 config（插件加载后执行）
    init = function()
      local augroup = vim.api.nvim_create_augroup("MarkdownFormat", { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        pattern = { "*.md", "*.markdown" },
        callback = function()
          -- 只在文件类型确实是 markdown 时格式化
          -- （pattern 匹配文件名，ft 匹配文件类型，双重检查更安全）
          if vim.bo.filetype == "markdown" then
            -- conform.nvim 的格式化命令
            -- silent! 防止没有格式化器时报错
            vim.cmd("silent! FormatWrite")
          end
        end,
        desc = "保存时自动格式化 Markdown",
      })
    end,
  },
}
