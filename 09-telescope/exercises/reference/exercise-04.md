# 练习 4 参考答案 — 自定义 Telescope 配置

```lua
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件" },
      { "<leader>sg", "<cmd>Telescope live_grep<CR>",  desc = "全文搜索" },
    },
    opts = function(_, opts)
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        layout_strategy = "vertical",
        layout_config = {
          vertical = {
            prompt_position = "top",
            preview_height = 0.5,
          },
        },
        file_ignore_patterns = { "node_modules", ".git/" },
      })
      opts.pickers = vim.tbl_deep_extend("force", opts.pickers or {}, {
        find_files = {
          find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
        },
      })
    end,
    config = function(_, opts)
      require("telescope").setup(opts)
      pcall(require("telescope").load_extension, "fzf")
    end,
  },
}
```

**关键点**：
- `keys` 懒加载（不是 event）
- `opts = function` + `vim.tbl_deep_extend` 扩展（不是 `opts = {...}` 覆盖）
- `config` 里用 `pcall` 保护 `load_extension`
- `dependencies` 声明 fzf-native，带 `build` 和 `cond`

**回到 [练习题](../README.md)**
