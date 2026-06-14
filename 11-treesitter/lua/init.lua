--- init.lua — Treesitter 模块加载保护示例（第11章）
---
--- 这个文件演示如何用 pcall guard 安全地 require Treesitter 相关模块。
--- 在教程环境中，nvim-treesitter 可能没有安装（不在 runtimepath 上），
--- 直接 require("nvim-treesitter.configs") 会报错并中断脚本。
--- pcall 保护让文件在任何环境下都能安全执行。
---
--- ⚠️ 注意：这是教学示例。真实环境不需要手动 require Treesitter，
---    LazyVim 会通过 lazy.nvim spec 自动加载。
---    验证：nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

-- ============================================================================
-- 第 1 部分：pcall guard — 安全 require Treesitter
-- ============================================================================

local ok_ts, ts_configs = pcall(require, "nvim-treesitter.configs")
if not ok_ts then
    print("[demo] nvim-treesitter not installed — 教学环境正常情况")
    print("[demo] 真实环境 LazyVim 会自动加载 Treesitter")
    print("[demo] 运行 :TSInstallInfo 查看已安装的解析器")
    return
end

-- ============================================================================
-- 第 2 部分：演示 Treesitter 配置读取
-- ============================================================================

-- 真实环境才会走到这里
-- 查看当前的 ensure_installed 配置
local installed = ts_configs.get_module("ensure_installed") or {}
local count = 0
for _, _ in pairs(installed) do
    count = count + 1
end
print("[demo] Treesitter 已配置 " .. count .. " 个解析器")

-- 查询某个语言是否已安装
local lang_ok, parsers = pcall(require, "nvim-treesitter.parsers")
if lang_ok and parsers.has_parser then
    local test_langs = { "lua", "python", "javascript" }
    for _, lang in ipairs(test_langs) do
        if parsers.has_parser(lang) then
            print("[demo] " .. lang .. " 解析器: 已安装")
        else
            print("[demo] " .. lang .. " 解析器: 未安装 (运行 :TSInstall " .. lang .. ")")
        end
    end
end

-- ============================================================================
-- 第 3 部分：演示高亮状态检查
-- ============================================================================

local highlight = ts_configs.get_module("highlight")
if highlight and highlight.enable then
    print("[demo] Treesitter 高亮: 已启用")
else
    print("[demo] Treesitter 高亮: 未启用")
end

local incremental = ts_configs.get_module("incremental_selection")
if incremental and incremental.enable then
    print("[demo] 增量选择: 已启用 (按 gn 开始)")
else
    print("[demo] 增量选择: 未启用")
end

-- ============================================================================
-- 总结：pcall guard 模式是所有 Treesitter 相关 Lua 文件的标准写法。
---   1. pcall(require, MODULE) 返回 ok, module
---   2. not ok → 打印 demo message，return 退出
---   3. ok → 安全使用 module
---   这保证文件在任何环境下（有/无 Treesitter）都不会报错。
