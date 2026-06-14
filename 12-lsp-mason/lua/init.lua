--- init.lua — LSP 模块加载保护示例（第12章）
---
--- 这个文件演示如何用 pcall guard 安全地 require LSP 相关模块。
--- 在教程环境中，nvim-lspconfig 可能没有安装，
--- 直接 require("lspconfig") 会报错并中断脚本。
--- pcall 保护让文件在任何环境下都能安全执行。
---
--- ⚠️ 注意：这是教学示例。真实环境不需要手动 require lspconfig，
---    LazyVim 会通过 lazy.nvim spec 自动加载和配置。
---    验证：nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

-- ============================================================================
-- 第 1 部分：pcall guard — 安全 require lspconfig
-- ============================================================================

local ok_lsp, lspconfig = pcall(require, "lspconfig")
if not ok_lsp then
    print("[demo] nvim-lspconfig not installed — 教学环境正常情况")
    print("[demo] 真实环境 LazyVim 会自动加载 lspconfig")
    print("[demo] 运行 :LspInfo 查看当前 LSP 状态")
    return
end

-- ============================================================================
-- 第 2 部分：演示 LSP 客户端信息查询
-- ============================================================================

-- 真实环境才会走到这里
-- 查询当前 buffer 已连接的 LSP 客户端
local clients = vim.lsp.get_clients({ bufnr = 0 })
if #clients == 0 then
    print("[demo] 当前 buffer 没有 LSP 客户端连接")
    print("[demo] 打开一个代码文件后，语言服务器会自动启动")
else
    for _, client in ipairs(clients) do
        print("[demo] LSP 客户端: " .. client.name .. " (id: " .. client.id .. ")")
        if client.config.root_dir then
            print("[demo]   根目录: " .. client.config.root_dir)
        end
    end
end

-- ============================================================================
-- 第 3 部分：演示 Mason 状态检查
-- ============================================================================

local ok_mason, mason_registry = pcall(require, "mason-registry")
if not ok_mason then
    print("[demo] mason.nvim not installed — 教学环境正常情况")
    print("[demo] 真实环境运行 :Mason 打开安装管理界面")
    return
end

-- 查询已安装的包
local installed = mason_registry.get_installed_packages()
print("[demo] Mason 已安装 " .. #installed .. " 个工具")
for _, pkg in ipairs(installed) do
    print("[demo]   " .. pkg.name .. " (" .. pkg.type .. ")")
end

-- ============================================================================
-- 第 4 部分：演示诊断信息查询
-- ============================================================================

local diagnostics = vim.diagnostic.get(0)  -- 获取当前 buffer 的诊断
if #diagnostics == 0 then
    print("[demo] 当前 buffer 无诊断信息（没有错误/警告）")
else
    local counts = { 0, 0, 0, 0 }  -- ERROR, WARN, INFO, HINT
    for _, diag in ipairs(diagnostics) do
        counts[diag.severity] = counts[diag.severity] + 1
    end
    print("[demo] 诊断: " .. counts[1] .. " 错误, " .. counts[2] .. " 警告, "
        .. counts[3] .. " 信息, " .. counts[4] .. " 提示")
end

-- ============================================================================
-- 总结：pcall guard 模式是所有 LSP 相关 Lua 文件的标准写法。
---   1. pcall(require, MODULE) 返回 ok, module
---   2. not ok → 打印 demo message，return 退出
---   3. ok → 安全使用 module
---   这保证文件在任何环境下（有/无 LSP）都不会报错。
