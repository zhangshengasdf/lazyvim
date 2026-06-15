--- init.lua — DAP 调试器教学示例（第16章）
---
--- 这个文件演示如何用 pcall guard 加载 nvim-dap 和 nvim-dap-ui。
--- 真实环境中，这些插件由 lazy.nvim 按 keys 懒加载，不需要手动 require。
--- 但理解加载流程有助于排查"找不到适配器"等问题。
---
--- ⚠️ 注意：这是教学示例。pcall guard 保证没有插件时优雅降级。
---    验证：nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

-- ============================================================================
-- 第 1 部分：nvim-dap 加载演示
-- ============================================================================

local ok_dap, dap = pcall(require, "dap")
if not ok_dap then
    print("[demo] nvim-dap not installed — 教学环境正常情况")
    print("[demo] 真实环境中，按 <leader>db 或 <leader>dc 时才加载")
    print("[demo] nvim-dap 是 DAP 协议客户端，需要配合调试适配器使用")
else
    print("[demo] nvim-dap loaded successfully")

    -- 显示已注册的适配器
    local adapters = {}
    for lang, _ in pairs(dap.adapters or {}) do
        table.insert(adapters, lang)
    end
    if #adapters > 0 then
        print("[demo] registered adapters: " .. table.concat(adapters, ", "))
    else
        print("[demo] no adapters registered (install debugpy/js-debug-adapter)")
    end
end

-- ============================================================================
-- 第 2 部分：nvim-dap-ui 加载演示
-- ============================================================================

local ok_dapui, dapui = pcall(require, "dapui")
if not ok_dapui then
    print("[demo] nvim-dap-ui not installed — 教学环境正常情况")
    print("[demo] 真实环境中，启动调试时自动打开 UI 面板")
    print("[demo] UI 包含：Scopes(变量) / Stack(调用栈) / REPL(表达式求值)")
else
    print("[demo] nvim-dap-ui loaded successfully")
end

-- ============================================================================
-- 第 3 部分：DAP 快捷键演示（真实环境才会执行）
-- ============================================================================

local keymap_demo = {
    { "<leader>db", "toggle breakpoint",   "设断点/删断点" },
    { "<leader>dc", "continue",            "继续运行" },
    { "<leader>dn", "step over",           "步过（不进函数）" },
    { "<leader>di", "step into",           "步入（进函数）" },
    { "<leader>do", "step out",            "步出（从函数返回）" },
    { "<leader>dt", "terminate",           "终止调试" },
    { "<leader>dr", "toggle REPL",         "打开/关闭 REPL" },
    { "<leader>du", "toggle DAP UI",       "打开/关闭调试面板" },
    { "<leader>dB", "conditional breakpoint", "条件断点" },
}

print("[demo] DAP keymaps summary:")
for _, km in ipairs(keymap_demo) do
    print(string.format("  %s → %s (%s)", km[1], km[2], km[3]))
end

-- ============================================================================
-- 第 4 部分：调试适配器检查
-- ============================================================================

print("[demo] debug adapter status:")

-- 检查 Python debugpy
local ok_py, _ = pcall(require, "dap-python")
if ok_py then
    print("  Python (debugpy): available")
else
    print("  Python (debugpy): not installed (pip install debugpy)")
end

-- 检查 Mason 是否安装了 js-debug
local mason_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"
local uv = vim.uv or vim.loop
if uv.fs_stat(mason_path) then
    print("  TypeScript (js-debug): available")
else
    print("  TypeScript (js-debug): not installed (:Mason → js-debug-adapter)")
end

-- ============================================================================
-- 总结：DAP 的加载时机
--
-- nvim-dap:    keys = { "<leader>db" }  → 按调试键时加载（不常用，按需加载）
-- nvim-dap-ui: 作为 nvim-dap 的 dependency 自动加载
-- 调试适配器:  需要单独安装（pip/Mason），不是 nvim-dap 自带的
--
-- 调试器和 gitsigns 不同：
--   gitsigns 用 event = "BufReadPost"（打开文件就显示标记）
--   nvim-dap 用 keys（调试时才用，不拖慢启动）
-- ============================================================================
