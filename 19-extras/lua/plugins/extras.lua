--- lua/plugins/extras.lua — Extras import 示例（第19章）
---
--- 这个文件演示如何 import LazyVim 的 Extras。
--- 每个 import 语句加载一个 Extra 模块，包含一整套插件 spec。
---
--- ⚠️ 注意：
---   - 这是教学示例，import 的 Extra 在教学环境下不会真正加载（LazyVim 未安装）
---   - 真实环境下，取消注释你需要的 import 即可
---   - 不要同时启用功能冲突的 Extras（如 Copilot + Codeium）
---
--- 验证：nvim --headless -u NONE -c "luafile lua/plugins/extras.lua" -c 'qa!'

return {
  -- ========================================================================
  -- 语言 Extras
  -- ========================================================================
  -- 每个语言 Extra 包含：Treesitter 解析器 + LSP + 格式化 + 调试器
  -- 取消注释你需要的语言

  -- Python: pyright (LSP) + ruff (格式化/lint) + debugpy (调试)
  -- { import = "lazyvim.plugins.extras.lang.python" },

  -- Rust: rust-analyzer (LSP) + rustfmt (格式化) + codelldb (调试)
  -- { import = "lazyvim.plugins.extras.lang.rust" },

  -- Go: gopls (LSP) + gofumpt (格式化) + delve (调试)
  -- { import = "lazyvim.plugins.extras.lang.go" },

  -- TypeScript: ts_ls (LSP) + prettier (格式化) + chrome-debug-adapter
  -- { import = "lazyvim.plugins.extras.lang.typescript" },

  -- Lua: lua_ls (LSP) + stylua (格式化)
  -- { import = "lazyvim.plugins.extras.lang.lua" },

  -- JSON: jsonls (LSP) + schemastore (JSON Schema 支持)
  -- { import = "lazyvim.plugins.extras.lang.json" },

  -- YAML: yamlls (LSP) + schemastore
  -- { import = "lazyvim.plugins.extras.lang.yaml" },

  -- Markdown: marksman (LSP) + markdown-preview
  -- { import = "lazyvim.plugins.extras.lang.markdown" },

  -- ========================================================================
  -- AI Extras（只启用一个，不要同时启用多个）
  -- ========================================================================

  -- GitHub Copilot: GPT 驱动的代码补全
  -- { import = "lazyvim.plugins.extras.ai.copilot" },

  -- Copilot Chat: 对话式 AI，支持代码解释、重构
  -- { import = "lazyvim.plugins.extras.ai.copilot-chat" },

  -- Codeium: 免费 AI 补全
  -- { import = "lazyvim.plugins.extras.ai.codeium" },

  -- ========================================================================
  -- 编辑器 Extras
  -- ========================================================================

  -- mini-files: 轻量文件浏览器
  -- { import = "lazyvim.plugins.extras.editor.mini-files" },

  -- overseer: 任务运行器
  -- { import = "lazyvim.plugins.extras.editor.overseer" },

  -- navic: 面包屑导航
  -- { import = "lazyvim.plugins.extras.editor.navic" },

  -- ========================================================================
  -- 自定义 Extra 示例
  -- ========================================================================
  -- 如果你在 lua/plugins/extras/lang/ 下创建了自己的 Extra，
  -- 在这里 import 它：
  -- { import = "plugins.extras.lang.zig" },
}
