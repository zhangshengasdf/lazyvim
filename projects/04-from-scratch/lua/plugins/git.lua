--- lua/plugins/git.lua — Git 集成（项目 4）
---
--- 从零配置 Git 集成，不依赖 LazyVim 的预配置。
--- 对照 Ch15 的内容，这里是你自己写的完整 spec。
---
--- LazyVim 帮你做的事情（你需要自己写）：
---   1. 安装 gitsigns.nvim
---   2. 配置 sign 符号（添加/修改/删除的行标记）
---   3. 注册 hunk 操作快捷键（<leader>ghs、<leader>ghr 等）
---   4. 安装 lazygit.nvim（可选）
---
--- 本文件只写 20 行，LazyVim 的默认配置有 60+ 行。

return {
  -- ========================================================================
  -- gitsigns.nvim — Git 行内标记
  -- ========================================================================
  -- gitsigns 在 sign column 显示 Git 变更标记：
  --   |  = 新增的行（绿色）
  --   |  = 修改的行（黄色）
  --   |  = 删除的行（红色）
  --
  -- 懒加载策略：event = "BufReadPost" — 打开文件时加载。
  -- gitsigns 需要在文件打开时就显示标记（不能用 keys 懒加载）。
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- sign 符号配置
      signs = {
        add = { text = "▎" },          -- 新增
        change = { text = "▎" },       -- 修改
        delete = { text = "" },        -- 删除（行被删，标记在上一行）
        topdelete = { text = "" },     -- 顶部删除
        changedelete = { text = "▎" }, -- 修改后删除
        untracked = { text = "▎" },   -- 未跟踪的文件
      },

      -- on_attach：gitsigns 加载后的回调
      -- 在这里注册 Git 相关快捷键
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Hunk 导航
        map("n", "]h", gs.next_hunk, "下一个 hunk")
        map("n", "[h", gs.prev_hunk, "上一个 hunk")

        -- Hunk 操作
        map("n", "<leader>ghs", gs.stage_hunk, "暂存 hunk")
        map("n", "<leader>ghr", gs.reset_hunk, "重置 hunk")
        map("v", "<leader>ghs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "暂存选中 hunk")
        map("v", "<leader>ghr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "重置选中 hunk")

        -- Buffer 操作
        map("n", "<leader>ghS", gs.stage_buffer, "暂存整个 buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "撤销暂存")
        map("n", "<leader>ghR", gs.reset_buffer, "重置整个 buffer")

        -- 预览和 blame
        map("n", "<leader>ghp", gs.preview_hunk, "预览 hunk")
        map("n", "<leader>ghb", function()
          gs.blame_line({ full = true })
        end, "行级 blame")
        map("n", "<leader>ghd", gs.diffthis, "Diff 当前文件")

        -- 文本对象：ih = 当前 hunk
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "选择 hunk")
      end,
    },
  },
}
