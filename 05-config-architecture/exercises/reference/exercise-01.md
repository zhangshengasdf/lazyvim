# 练习 1 参考答案 — 配置该放哪个文件

| 配置内容 | 放哪个文件 | 理由 |
|----------|------------|------|
| (a) `vim.opt.number = true` | **`lua/config/options.lua`** | vim 选项放 options.lua |
| (b) `vim.keymap.set("n", "<leader>w", ":w<CR>")` | **`lua/config/keymaps.lua`** | 不涉及插件的快捷键放 keymaps.lua |
| (c) 打开 `.md` 文件时自动设 `wrap` | **`lua/config/autocmds.lua`** | 这是 autocmd（FileType 事件触发） |
| (d) 给 Telescope 插件追加一个布局选项 | **`lua/plugins/telescope.lua`** | 涉及插件 spec，必须放 plugins/ |
| (e) `vim.g.mapleader = " "` | **`lua/config/options.lua`** | 全局变量也放 options.lua（用 vim.g） |
| (f) 把 `<C-h>` 映射为"跳到左窗口" | **`lua/config/keymaps.lua`** | 不涉及插件的窗口导航快捷键 |
| (g) 给 nvim-treesitter 追加 `ensure_installed` 语言 | **`lua/plugins/`**（如 `treesitter.lua`） | 扩展插件 spec 必须放 plugins/ |

**核心口诀**：
- **改 Neovim 本身的设置**（options/keymaps/autocmds）→ `lua/config/`
- **改/加/禁用插件** → `lua/plugins/`

**回到 [练习题](../README.md)**
