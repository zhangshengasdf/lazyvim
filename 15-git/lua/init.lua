--- init.lua — Git 集成教学示例（第15章）
---
--- 这个文件演示如何用 pcall guard 加载 gitsigns 和 lazygit。
--- 真实环境中，这些插件由 lazy.nvim 自动管理，不需要手动 require。
--- 但理解加载流程有助于排查配置问题。
---
--- ⚠️ 注意：这是教学示例。pcall guard 保证没有插件时优雅降级。
---    验证：nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

-- ============================================================================
-- 第 1 部分：gitsigns 加载演示
-- ============================================================================

local ok_gitsigns, gitsigns = pcall(require, "gitsigns")
if not ok_gitsigns then
    print("[demo] gitsigns.nvim not installed — 教学环境正常情况")
    print("[demo] 真实环境中，lazy.nvim 会在 BufReadPost 事件时自动加载 gitsigns")
    print("[demo] 行号栏会显示绿色(+)、蓝色(~)、红色(_) 标记")
else
    -- 真实环境：gitsigns 已加载，调用 setup
    gitsigns.setup({
        signs = {
            add = { text = "▎" },
            change = { text = "▎" },
            delete = { text = "" },
        },
    })
    print("[demo] gitsigns loaded successfully")
end

-- ============================================================================
-- 第 2 部分：lazygit 加载演示
-- ============================================================================

local ok_lazygit, _ = pcall(require, "lazygit")
if not ok_lazygit then
    print("[demo] lazygit.nvim not installed — 教学环境正常情况")
    print("[demo] 真实环境中，按 <leader>gg 或运行 :LazyGit 时才加载")
    print("[demo] lazygit 是终端 Git GUI，支持分支、rebase、冲突解决")
else
    print("[demo] lazygit loaded successfully")
end

-- ============================================================================
-- 第 3 部分：gitsigns keymaps 演示（真实环境才会执行）
-- ============================================================================

-- 真实环境中的快捷键映射（这里只演示结构，不实际执行）
-- LazyVim 已经预设了这些快捷键，你通常不需要手动设置
local keymap_demo = {
    { "<leader>ghs", "stage hunk",      "n", "v" },
    { "<leader>ghr", "reset hunk",      "n", "v" },
    { "<leader>ghp", "preview hunk",    "n" },
    { "<leader>ghu", "undo stage hunk", "n" },
    { "<leader>ghS", "stage buffer",    "n" },
    { "<leader>ghR", "reset buffer",    "n" },
    { "<leader>gb",  "git blame",       "n" },
    { "<leader>gg",  "lazygit",         "n" },
}

print("[demo] gitsigns keymaps summary:")
for _, km in ipairs(keymap_demo) do
    print(string.format("  %s → %s (modes: %s)", km[1], km[2], table.concat({ select(3, unpack(km)) }, ", ")))
end

-- ============================================================================
-- 总结：Git 集成的加载时机
--
-- gitsigns:  event = "BufReadPost"  → 打开文件时加载（需要立即显示标记）
-- lazygit:   cmd + keys 双懒加载    → 按需加载（不常用，不拖慢启动）
--
-- 扩展配置时用 opts = function(_, opts) ... end（extend 模式），
-- 不要用 opts = { ... } 覆盖默认值。
-- ============================================================================
