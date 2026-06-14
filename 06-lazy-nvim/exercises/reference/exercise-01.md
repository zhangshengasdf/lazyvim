# 练习 1 参考答案 — 选择懒加载策略

| 插件 | 功能 | 推荐策略 | 触发条件 | 理由 |
|------|------|----------|----------|------|
| (a) `nvim-treesitter` | 语法高亮 | **`event`** | `event = "BufReadPost"` | 每次打开文件都需要高亮，用 BufReadPost 触发 |
| (b) `telescope.nvim` | 模糊搜索 | **`keys`** | `keys = { "<leader>ff", ... }` | 命令式工具，按键才用 |
| (c) `gitsigns.nvim` | Git 状态标记 | **`event`** | `event = "BufReadPost"` | 每次打开文件都要显示 Git 改动 |
| (d) `rust-tools.nvim` | Rust 专属 LSP | **`ft`** | `ft = { "rust" }` | 只在 Rust 文件用，语言专属 |
| (e) `lazygit.nvim` | Git GUI | **`cmd`** + `keys` | `cmd = "LazyGit"` 或 `keys = "<leader>gg"` | 偶尔用的命令式工具 |
| (f) `tokyonight.nvim` | 配色主题 | **不懒加载** | `lazy = false, priority = 1000` | 配色必须启动时就绪，且要优先加载 |
| (g) `nvim-lspconfig` | LSP 配置 | **`ft`**（LazyVim 的做法） | `ft = { "lua", "python", ... }` | 语言专属，LazyVim 按语言拆分配置 |

## 决策树总结

```
插件什么时候需要？
│
├─ 只在特定语言文件 → ft
├─ 绑快捷键，按键才用 → keys
├─ 用 :命令 调用 → cmd
├─ 每次打开文件都要 → event = "BufReadPost"
├─ 进入 insert 模式才用 → event = "InsertEnter"
└─ 启动时必须就绪（配色、UI）→ 不懒加载 + priority
```

**回到 [练习题](../README.md)**
