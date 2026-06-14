# 练习 2 参考答案 — 写基本 spec

## 1. tokyonight.nvim（配色插件）

```lua
return {
  {
    "folke/tokyonight.nvim",
    lazy = false,           -- 不懒加载（配色必须启动时就绪）
    priority = 1000,        -- 优先加载（其他插件可能依赖配色）
    opts = {
      style = "moon",       -- 配色风格：storm/night/day/moon
      transparent = true,   -- 透明背景
    },
  },
}
```

**关键点**：
- `lazy = false` 显式标记不懒加载
- `priority = 1000` 保证配色在 UI 插件之前加载（数字越大越优先）
- 配色插件用 `opts` 就够了（tokyonight 有 `setup(opts)` 函数）

## 2. vim-fugitive（Git 工具）

```lua
return {
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gvdiffsplit", "Gread", "Gwrite", "Ggrep" },
  },
}
```

**关键点**：
- `cmd` 是字符串列表，运行这些命令中任意一个时才加载
- vim-fugitive 不需要 `opts` 或 `config`（它是 Vimscript 插件，不用 setup）
- 如果你想绑快捷键（比如 `<leader>gs` 调 `:Git<CR>`），加 `keys` 字段：

```lua
{
  "tpope/vim-fugitive",
  cmd = { "Git", "G", "Gvdiffsplit" },
  keys = {
    { "<leader>gs", "<cmd>Git<CR>", desc = "Git 状态" },
    { "<leader>gd", "<cmd>Gvdiffsplit<CR>", desc = "Git diff 分屏" },
  },
},
```

**回到 [练习题](../README.md)**
