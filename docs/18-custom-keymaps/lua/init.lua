--- lua/init.lua — 第18章 bootstrap 教学
---
--- 展示 lazy.nvim 的 bootstrap 结构，配合 pcall 保护，
--- 在没有安装 lazy.nvim 的环境（教学环境）下也能正常加载不报错。
---
--- 验证：nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

-- ============================================================================
-- 第 1 部分：bootstrap lazy.nvim
-- ============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "--branch=stable",
    lazyrepo, lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit...", "NONE" },
    }, true, { err = true })
    pcall(vim.fn.getchar)
    print("[demo] lazy.nvim clone failed — 教学环境正常情况")
  end
end

vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- 第 2 部分：加载 config/ 下的配置文件
-- ============================================================================

-- LazyVim 会自动加载 lua/config/ 下的 options.lua、keymaps.lua、autocmds.lua。
-- 这里用 pcall 模拟，确保在教学环境下不报错。
pcall(dofile, "lua/config/keymaps.lua")
pcall(dofile, "lua/config/autocmds.lua")

-- ============================================================================
-- 第 3 部分：require("lazy").setup
-- ============================================================================

local ok, lazy = pcall(require, "lazy")
if not ok then
  print("[demo] lazy.nvim not installed — 教学环境正常情况")
  return
end

lazy.setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins" },
  },
  install = {
    colorscheme = { "tokyonight", "habamax" },
  },
  checker = { enabled = true, notify = false },
  change_detection = { enabled = true, notify = false },
  performance = {
    rtp = {
      reset = true,
      disabled_plugins = {
        "gzip", "matchit", "matchparen",
        "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
  ui = { border = "rounded" },
  debug = false,
})

-- ============================================================================
-- 总结：init.lua 先加载 config/，再加载 lazy.nvim。
-- keymaps.lua 和 autocmds.lua 在插件加载之前执行。
