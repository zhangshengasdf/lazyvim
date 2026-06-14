--- lua/init.lua — Leader 键体系与核心快捷键演示（第07章）
---
--- 这个文件演示：
---   1. 设置 Leader 键（vim.g.mapleader）
---   2. 用 vim.keymap.set 注册核心 Leader 快捷键（带 desc）
---   3. buffer 切换和窗口导航快捷键
---   4. pcall guard 保护（没有 lazy.nvim 也能正常加载）
---
--- ⚠️ 注意：mapleader 必须在任何 <leader> 快捷键注册之前设置。
---    Neovim 在 vim.keymap.set 时把 <leader> 替换为当时的 mapleader 值。
---    验证：nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

-- ============================================================================
-- 第 1 部分：Leader 键设置（必须最先设置）
-- ============================================================================

vim.g.mapleader = " "   -- 空格键作为 Leader（LazyVim 默认）
vim.g.maplocalleader = " "  -- 本地 Leader（用于 buffer-local 映射）

-- ============================================================================
-- 第 2 部分：核心 Leader 快捷键
-- ============================================================================

-- 每个 vim.keymap.set 调用都带 desc 字段——which-key 靠它显示功能描述。
-- 不带 desc 的快捷键在 which-key 里是"盲"的。

-- --- 保存和退出（根目录快捷键，不属于任何前缀组）---
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "保存文件" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "退出" })
vim.keymap.set("n", "<leader>Q", "<cmd>qa<CR>", { desc = "退出全部" })

-- --- f: find（查找类）---
-- Telescope 的核心操作，LazyVim 已内置，这里演示注册方式
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "查找文件" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "实时 grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "buffer 列表" })
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "最近文件" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "帮助标签" })

-- 用 Lua function 作为 rhs（更灵活，可以传参数）
vim.keymap.set("n", "<leader>fc", function()
  local ok, builtin = pcall(require, "telescope.builtin")
  if ok then
    builtin.find_files({ cwd = vim.fn.stdpath("config") })
  else
    vim.notify("Telescope 未加载", vim.log.levels.WARN)
  end
end, { desc = "查找配置文件" })

-- --- s: search（搜索类）---
vim.keymap.set("n", "<leader>sw", "<cmd>Telescope grep_string<CR>", { desc = "搜索当前词" })
vim.keymap.set("n", "<leader>sk", "<cmd>Telescope keymaps<CR>", { desc = "搜索快捷键" })
vim.keymap.set("n", "<leader>sh", "<cmd>Telescope highlights<CR>", { desc = "搜索高亮组" })

-- --- b: buffer（缓冲区类）---
vim.keymap.set("n", "<leader>bb", "<cmd>e #<CR>", { desc = "切换到上一个 buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "关闭当前 buffer" })
vim.keymap.set("n", "<leader>bo", "<cmd>%bdelete<CR>", { desc = "关闭其他 buffer" })

-- --- g: git ---
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "打开 LazyGit" })
vim.keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "Git 状态" })
vim.keymap.set("n", "<leader>gf", "<cmd>Telescope git_commits<CR>", { desc = "Git log" })

-- --- c: code（代码操作）---
-- 这些快捷键在有 LSP 连接时才有意义，这里先占位
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "代码动作" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "重命名" })
vim.keymap.set("n", "<leader>cd", "<cmd>Telescope diagnostics<CR>", { desc = "诊断列表" })

-- --- x: extra（扩展功能）---
vim.keymap.set("n", "<leader>xl", function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "切换相对行号" })
vim.keymap.set("n", "<leader>xs", function()
  vim.opt.spell = not vim.opt.spell:get()
end, { desc = "切换拼写检查" })

-- --- u: UI ---
vim.keymap.set("n", "<leader>ut", "<cmd>Telescope colorscheme<CR>", { desc = "切换主题" })

-- ============================================================================
-- 第 3 部分：Buffer 切换（<S-h> / <S-l>）
-- ============================================================================

-- LazyVim 用 Shift+H / Shift+L 在 buffer 间快速切换。
-- 这两个键覆盖了 Vim 原生的"移动到屏幕顶/底部"——如果你需要原生行为，用 H / L（大写）。
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "上一个 buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "下一个 buffer" })

-- ============================================================================
-- 第 4 部分：窗口导航（<C-h/j/k/l>）
-- ============================================================================

-- 用 Ctrl + hjkl 在分屏间移动，和方向一一对应。
-- <C-l> 覆盖了 Vim 原生的"重绘屏幕"——需要重绘时用 :redraw。
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "移到左边窗口" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "移到下方窗口" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "移到上方窗口" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "移到右边窗口" })

-- 窗口大小调整
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "增加窗口高度" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "减少窗口高度" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "减少窗口宽度" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "增加窗口宽度" })

-- ============================================================================
-- 第 5 部分：pcall guard（演示用）
-- ============================================================================

-- 如果 lazy.nvim 已安装，可以加载插件 spec 来演示 keys 懒加载。
-- 教学环境下 lazy.nvim 可能没装，pcall 让文件优雅降级。
local ok, lazy = pcall(require, "lazy")
if ok then
  -- lazy.nvim 已安装——你可以在真实环境里用 keys 懒加载插件
  print("[demo] lazy.nvim loaded — 可以用 keys 懒加载策略")
else
  -- lazy.nvim 未安装——教学环境正常情况
  print("[demo] lazy.nvim not installed — Leader 快捷键已通过 vim.keymap.set 注册")
  print("[demo] 真实环境下，这些快捷键会触发 Telescope/LazyGit 等插件的懒加载")
end

-- ============================================================================
-- 总结：Leader 键体系的核心规则
--   1. vim.g.mapleader = " " 必须在所有 <leader> keymap 之前设置
--   2. 每个 vim.keymap.set 必须带 desc 字段（which-key 依赖它）
--   3. 用 vim.keymap.set（不用 vim.api.nvim_set_keymap，已弃用）
--   4. 前缀分类：f(find), s(search), b(buffer), g(git), c(code), x(extra), u(UI)
--   5. buffer 切换：<S-h>/<S-l>；窗口导航：<C-h/j/k/l>
