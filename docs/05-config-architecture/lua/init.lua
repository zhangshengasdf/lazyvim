--- init.lua — 演示 config/ 目录的组织方式（第05章教学示例）
---
--- 这个文件展示 LazyVim 如何组织配置目录。
--- 真实使用时，~/.config/nvim/init.lua 的内容和第 04 章一样（bootstrap lazy.nvim + setup），
--- 本章重点是 lua/config/ 和 lua/plugins/ 的组织方式。
---
--- 本文件模拟 LazyVim 的"自动 source config/ 目录"逻辑，让你理解约定是怎么工作的。

-- ============================================================================
-- 第 1 部分：LazyVim 的约定（convention）
-- ============================================================================
-- LazyVim 在内部做了类似下面的事（简化版，你不需要写这个）：
--
--   local config_files = { "options", "keymaps", "autocmds", "lazy" }
--   for _, name in ipairs(config_files) do
--     local path = vim.fn.stdpath("config") .. "/lua/config/" .. name .. ".lua"
--     if vim.uv.fs_stat(path) then
--       dofile(path)  -- source 文件
--     end
--   end
--
-- 这就是为什么你把 options.lua 放到 lua/config/ 就会自动生效——LazyVim 自动 source 它。

print("[demo] LazyVim 会自动 source lua/config/ 下的四个文件（按顺序）：")
print("[demo]   1. options.lua  — vim 选项")
print("[demo]   2. keymaps.lua  — 快捷键")
print("[demo]   3. autocmds.lua — 自动命令")
print("[demo]   4. lazy.lua     — lazy.nvim 额外配置（可选）")

print("")
print("[demo] 同时，lazy.nvim 会扫描 lua/plugins/ 下所有 .lua 文件，")
print("[demo] 收集每个文件 return 的 spec table，按插件 URL 深度合并。")

-- ============================================================================
-- 第 2 部分：模拟加载本章的 config 文件（教学演示）
-- ============================================================================
-- 真实 LazyVim 会用 stdpath("config") 找到你的 config 目录。
-- 这里为了演示，手动 source 本章 lua/config/ 下的文件。

local config_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h") .. "/config"

-- source options.lua（如果存在）
local options_path = config_dir .. "/options.lua"
if vim.uv.fs_stat(options_path) then
  print("")
  print("[demo] === sourcing lua/config/options.lua ===")
  dofile(options_path)
  print("[demo] === options.lua sourced ===")
end

-- source keymaps.lua（如果存在）
local keymaps_path = config_dir .. "/keymaps.lua"
if vim.uv.fs_stat(keymaps_path) then
  print("")
  print("[demo] === sourcing lua/config/keymaps.lua ===")
  dofile(keymaps_path)
  print("[demo] === keymaps.lua sourced ===")
end

-- ============================================================================
-- 第 3 部分：总结
-- ============================================================================
print("")
print("[demo] 这就是 LazyVim 配置目录的全部魔法：")
print("[demo]   - lua/config/*.lua → 自动 source（裸语句）")
print("[demo]   - lua/plugins/*.lua → 收集成 spec（必须 return table）")
print("[demo]   - 合并语义：按插件 URL 匹配，列表 extend，非列表覆盖")
