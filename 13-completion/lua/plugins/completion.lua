--- lua/plugins/completion.lua — nvim-cmp 补全来源配置（第13章）
---
--- 这个文件演示如何用 extend 模式配置 nvim-cmp 的补全来源。
--- LazyVim 已经配好了默认来源（lsp/snippet/path/buffer），
--- 我们只需要追加或调整，不能覆盖。
---
--- ⚠️ 铁律：
---   - 追加来源用 table.insert(opts.sources, ...) 或 vim.list_extend
---   - 不要用 opts = { sources = {...} } 直接覆盖默认来源
---   - 新来源需要对应的 dependencies（比如 cmp-emoji 需要装插件）
---
--- 文件返回一个 spec table，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- 配置 1：追加新的补全来源（emoji）
  -- ========================================================================
  -- 适用场景：你想在补全菜单里看到 emoji 候选（写 Markdown 时很有用）。
  -- 关键：用 table.insert 追加，不覆盖默认来源。
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      -- 新来源需要对应的插件（cmp-emoji 提供 emoji 补全数据）
      "hrsh7th/cmp-emoji",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      -- ✅ 正确：table.insert 追加新来源到默认列表后面
      -- 默认来源（lsp/snippet/path/buffer）全部保留
      table.insert(opts.sources, { name = "emoji", priority = 100 })
    end,
  },

  -- ========================================================================
  -- 配置 2：调整补全项格式（显示来源名称）
  -- ========================================================================
  -- 适用场景：你想在补全菜单里看到 [LSP]、[Buffer] 等来源标签。
  -- 关键：用 opts = function 接收默认 opts，修改 formatting 字段。
  -- {
  --   "hrsh7th/nvim-cmp",
  --   ---@param opts cmp.ConfigSchema
  --   opts = function(_, opts)
  --     opts.formatting = {
  --       format = function(entry, vim_item)
  --         vim_item.menu = ({
  --           nvim_lsp = "[LSP]",
  --           luasnip  = "[Snippet]",
  --           buffer   = "[Buffer]",
  --           path     = "[Path]",
  --         })[entry.source.name]
  --         return vim_item
  --       end,
  --     }
  --   end,
  -- },

  -- ========================================================================
  -- 配置 3：自定义窗口样式
  -- ========================================================================
  -- 适用场景：你想调整补全菜单的边框和高亮。
  -- 关键：修改 window 字段。
  -- {
  --   "hrsh7th/nvim-cmp",
  --   ---@param opts cmp.ConfigSchema
  --   opts = function(_, opts)
  --     opts.window = {
  --       completion = {
  --         border = "rounded",
  --         winhighlight = "Normal:Pmenu,FloatBorder:Pmenu",
  --       },
  --       documentation = {
  --         border = "rounded",
  --       },
  --     }
  --   end,
  -- },

  -- ========================================================================
  -- 配置 4：追加 LSP 能力（告诉 LSP 我们支持补全）
  -- ========================================================================
  -- 适用场景：某些 LSP 服务器需要额外的 capabilities 才能提供完整补全。
  -- 关键：用 LazyVim 的 extend_lspconfig 模式追加 capabilities。
  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = function(_, opts)
  --     -- LazyVim 已经配好了 capabilities，这里演示如何追加
  --     local capabilities = vim.lsp.protocol.make_client_capabilities()
  --     capabilities.textDocument.completion.completionItem.snippetSupport = true
  --     opts.capabilities = vim.tbl_deep_extend("force", opts.capabilities or {}, capabilities)
  --   end,
  -- },

  -- ========================================================================
  -- 配置 5：禁用特定文件类型的补全
  -- ========================================================================
  -- 适用场景：在某些文件类型里补全很烦人（比如 Markdown 写作时）。
  -- 关键：用 autocmd 在特定 filetype 禁用补全。
  -- {
  --   "hrsh7th/nvim-cmp",
  --   ---@param opts cmp.ConfigSchema
  --   opts = function(_, opts)
  --     vim.api.nvim_create_autocmd("FileType", {
  --       pattern = { "markdown", "text" },
  --       callback = function()
  --         require("cmp").setup.buffer({ enabled = false })
  --       end,
  --       desc = "Markdown/Text 禁用补全",
  --     })
  --   end,
  -- },
}
