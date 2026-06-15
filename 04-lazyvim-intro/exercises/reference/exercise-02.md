# 练习 2 参考答案 — 目录结构填空

```
~/.config/nvim/
├── init.lua              → 作用：Neovim 唯一入口，bootstrap lazy.nvim + setup
├── lua/
│   ├── config/
│   │   ├── options.lua   → 作用：vim 选项（vim.opt.X = value），LazyVim 自动 source
│   │   ├── keymaps.lua   → 作用：快捷键（vim.keymap.set），LazyVim 自动 source
│   │   ├── autocmds.lua  → 作用：自动命令（vim.api.nvim_create_autocmd），LazyVim 自动 source
│   │   └── lazy.lua      → 作用：lazy.nvim setup 的额外配置（可选，覆盖 init.lua 的 setup）
│   └── plugins/
│       └── example.lua   → 作用：插件 spec（return { "repo/name", opts = {...} }），lazy.nvim 处理
├── lazy-lock.json        → 作用：插件版本锁定文件（记录每个插件的 commit hash）
```

**关键区分点**：

| 目录 | 文件内容 | LazyVim 如何处理 |
|------|----------|------------------|
| `lua/config/` | 裸 Lua 语句（`vim.opt.X = ...`） | 启动时全部 `source`（像 `:source`） |
| `lua/plugins/` | **必须** `return { ... }`（spec table） | 收集成 spec 列表，交给 lazy.nvim |

**易错点**：
- `init.lua` 里**不写** options/keymaps/autocmds（那些放 `lua/config/`）
- `lua/plugins/` 里**不写**裸 `vim.opt`（那些放 `lua/config/`）
- `lazy-lock.json` 是自动生成的，**不要手动编辑**

**回到 [练习题](../README.md)**
