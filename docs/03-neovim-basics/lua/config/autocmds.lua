--- lua/config/autocmds.lua — 配置拆分参考：自动命令（autocmd）
---
--- 部署参考文件。autocmd 是「某事件发生时自动执行的命令」，例如：
---   - 进入某 filetype 时设置 tabstop
---   - 保存前自动格式化
---   - 终端启动时自动进入插入模式

-- 创建一个 augroup，所有 autocmd 归入它，clear=true 避免重复加载时重复注册
local group = vim.api.nvim_create_augroup("MyConfig", { clear = true })

-- ============================================================
-- 1. 终端启动即进入插入模式
-- ============================================================

vim.api.nvim_create_autocmd("TermOpen", {
  group = group,
  pattern = "*",
  command = "startinsert",
  desc = "终端启动即进入插入模式",
})

-- ============================================================
-- 2. 保存前去除行尾空格
-- ============================================================

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*",
  callback = function()
    local save = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
  desc = "保存前去除行尾空格",
})

-- ============================================================
-- 3. 特定文件类型的缩进设置（示例）
-- ============================================================

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
  desc = "Python 用 4 空格缩进",
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "lua", "javascript", "typescript", "json", "html", "css" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
  desc = "前端和配置文件用 2 空格缩进",
})

-- ============================================================
-- 4. 进入窗口时自动等宽（可选）
-- ============================================================

vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  pattern = "*",
  command = "tabdo wincmd =",
  desc = "窗口大小变化时重新等分",
})

return nil
