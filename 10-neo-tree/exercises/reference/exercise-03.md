# 练习 3 参考答案 — Neo-tree 自定义配置

```lua
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neo-tree/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "Neotree" },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "文件管理器" },
    },
    opts = function(_, opts)
      opts.window = vim.tbl_deep_extend("force", opts.window or {}, {
        position = "right",
        width = 40,
      })
      opts.filesystem = vim.tbl_deep_extend("force", opts.filesystem or {}, {
        filtered_items = {
          hide_dotfiles = false,
        },
        follow_current_file = {
          enabled = true,
        },
      })
    end,
  },
}
```

**关键点**：
- `cmd` + `keys` 双懒加载
- `opts = function` + `vim.tbl_deep_extend` 扩展（不是覆盖）
- `position = "right"` 改为右侧显示
- `hide_dotfiles = false` 显示隐藏文件

**回到 [练习题](../README.md)**
