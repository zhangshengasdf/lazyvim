--- lua/plugins/git.lua — gitsigns + lazygit spec（第15章）
---
--- 这个文件演示 Git 集成的两个核心插件的 spec 格式：
---   1. gitsigns.nvim：行内 Git 标记 + hunk 操作
---   2. lazygit.nvim：终端 Git GUI
---
--- ⚠️ 铁律：
---   - gitsigns 用 event = "BufReadPost" 懒加载（不是 keys/cmd）
---   - lazygit 用 cmd + keys 双懒加载（不常用，按需加载）
---   - 扩展 LazyVim 默认配置用 opts = function(_, opts) ... end
---
--- 文件返回 spec table，直接 luafile 加载不会报错。

return {
  -- ========================================================================
  -- gitsigns.nvim — 行内 Git 标记 + hunk 操作
  -- ========================================================================
  -- LazyVim 已默认配置 gitsigns，这里是 extend 示例。
  -- 如果你想自定义 signs 或 on_attach，用 opts = function。
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    opts = function(_, opts)
      -- 自定义 signs（覆盖默认的符号）
      opts.signs = vim.tbl_deep_extend("force", opts.signs or {}, {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      })

      -- 自定义 on_attach（在 buffer 挂载 gitsigns 时执行）
      -- 这里演示如何添加自定义快捷键
      opts.on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        -- 用 vim.keymap.set 注册快捷键（带 desc）
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = "Git: " .. desc })
        end

        -- hunk 导航（用 ]c / [c 跳转到下一个/上一个 hunk）
        map("n", "]c", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, "下一个 hunk")

        map("n", "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, "上一个 hunk")
      end
    end,
  },

  -- ========================================================================
  -- lazygit.nvim — 终端 Git GUI
  -- ========================================================================
  -- 用 cmd + keys 双懒加载：运行 :LazyGit 或按 <leader>gg 时才加载。
  -- lazygit 不常用，没必要启动时就加载。
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile", "LazyGitFilter" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "打开 LazyGit" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
}
