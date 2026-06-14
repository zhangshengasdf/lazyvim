# 练习 1 参考答案 — 选择正确的 picker

| 场景 | 推荐 picker | 快捷键 | 理由 |
|------|-------------|--------|------|
| (a) 想打开 `lua/plugins/telescope.lua` | **find_files** | `<leader>ff` | 模糊匹配文件名，输入 `tlc` 就能找到 |
| (b) 想找到所有调用了 `vim.keymap.set` 的地方 | **live_grep** | `<leader>sg` | 全文搜索，用 ripgrep 在项目里搜内容 |
| (c) 想快速切换到刚才编辑过的 `config.lua` | **oldfiles** | `<leader>fr` | 最近文件列表，不需要输入完整路径 |
| (d) 想查看 `vim.lsp` 模块的帮助文档 | **help_tags** | `<leader>fh` | 搜索 Neovim 帮助文档 |
| (e) 光标在 `require("telescope")` 上 | **grep_string** | `<leader>fw` | 搜光标下的单词，不需要手动输入 |

**回到 [练习题](../README.md)**
