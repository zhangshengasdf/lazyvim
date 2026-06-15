--- lua/config/autocmds.lua — 自动命令示例（第18章）
---
--- LazyVim 会自动加载这个文件。
--- 用 nvim_create_autocmd + augroup 管理自动命令。
---
--- ⚠️ 铁律：
---   - 用 augroup 管理（避免重复注册）
---   - 每个 autocmd 带 desc（:autocmd 列表会显示）
---   - callback 比 command 更灵活（支持 Lua 函数）
---
--- 验证：nvim --headless -u NONE -c "luafile lua/config/autocmds.lua" -c 'qa!'

-- ============================================================================
-- 创建自动命令组（clear = true 避免重复注册）
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- ============================================================================
-- 1. 打开文件时恢复光标到上次位置
-- ============================================================================

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  pattern = "*",
  desc = "恢复光标到上次位置",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ============================================================================
-- 2. 高亮复制区域（短暂闪烁）
-- ============================================================================

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  pattern = "*",
  desc = "高亮复制区域",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- ============================================================================
-- 3. 特定文件类型设置
-- ============================================================================

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "lua", "javascript", "typescript", "json", "yaml", "html", "css" },
  desc = "设置缩进为 2 空格",
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "python",
  desc = "设置缩进为 4 空格",
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
  end,
})

-- ============================================================================
-- 4. 保存时自动删除尾部空格
-- ============================================================================

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  pattern = "*",
  desc = "保存时删除尾部空格",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- ============================================================================
-- 5. 窗口大小变化时重新排列
-- ============================================================================

vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  pattern = "*",
  desc = "窗口大小变化时重新排列",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- ============================================================================
-- 6. 自动创建目录（保存到不存在的目录时）
-- ============================================================================

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  pattern = "*",
  desc = "自动创建不存在的目录",
  callback = function(event)
    local file = event.match
    local dir = vim.fn.fnamemodify(file, ":h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})
