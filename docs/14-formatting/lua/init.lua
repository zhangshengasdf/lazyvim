--- init.lua — conform.nvim + nvim-lint 格式化与代码检查演示（第14章）
---
--- 这个文件演示 conform.nvim 和 nvim-lint 的初始化流程。
--- 真实使用时，这两个插件是通过 lazy.nvim spec 自动加载的，
--- 这里用 pcall 保护来模拟"插件可能没装"的场景。
---
--- ⚠️ 注意：这是教学示例。在本机没有这些插件的情况下，
---    pcall 保护会让文件优雅降级，但语法必须正确。
---    验证：nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

-- ============================================================================
-- 第 1 部分：检查 conform.nvim 是否可用
-- ============================================================================

local ok_conform, conform = pcall(require, "conform")
if not ok_conform then
    print("[demo] conform.nvim not installed — 教学环境正常情况")
    print("[demo] 真实环境中，LazyVim 会通过 lazy.nvim 自动加载 conform.nvim")
    print("[demo] 格式化器：stylua(Lua) / prettier(JS/TS) / black(Python)")
    print("[demo] 按键映射：<leader>cf 格式化 / <leader>uf 切换自动格式化")
    return
end

-- ============================================================================
-- 第 2 部分：演示 conform.nvim 的核心配置结构
-- ============================================================================

-- 真实环境才会走到这里
-- conform.nvim 的 setup 接收一个配置 table，核心字段：
--   - formatters_by_ft: 按文件类型指定格式化器
--   - formatters:       格式化器的选项
--   - format_on_save:   保存时自动格式化的配置

conform.setup({
    -- 按文件类型指定格式化器
    formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        markdown = { "prettier" },
        go = { "gofumpt", "goimports" },
        rust = { "rustfmt" },
    },

    -- 保存时自动格式化
    format_on_save = {
        timeout_ms = 500,      -- 超时时间
        lsp_format = "fallback", -- 如果 conform 没有格式化器，用 LSP
    },
})

-- ============================================================================
-- 第 3 部分：检查 nvim-lint 是否可用
-- ============================================================================

local ok_lint, lint = pcall(require, "lint")
if not ok_lint then
    print("[demo] nvim-lint not installed — 教学环境正常情况")
    print("[demo] 真实环境中，LazyVim 会通过 lazy.nvim 自动加载 nvim-lint")
    print("[demo] linter：eslint(JS/TS) / luacheck(Lua) / pylint(Python)")
    return
end

-- ============================================================================
-- 第 4 部分：演示 nvim-lint 的核心配置结构
-- ============================================================================

-- nvim-lint 的配置通过 lint.linters_by_ft 定义
-- 每种文件类型指定一个或多个 linter

lint.linters_by_ft = lint.linters_by_ft or {}
lint.linters_by_ft.javascript = { "eslint" }
lint.linters_by_ft.typescript = { "eslint" }
lint.linters_by_ft.lua = { "luacheck" }
lint.linters_by_ft.python = { "pylint" }

-- ============================================================================
-- 第 5 部分：注册自动检查的 autocmd
-- ============================================================================

-- nvim-lint 默认在保存时自动运行，这里演示如何手动注册
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
    callback = function()
        -- 延迟 100ms 运行，避免频繁触发
        vim.defer_fn(function()
            pcall(function()
                require("lint").try_lint()
            end)
        end, 100)
    end,
    desc = "nvim-lint: 自动运行 linter",
})

-- ============================================================================
-- 总结：
--   - conform.nvim 管格式化，nvim-lint 管代码检查
--   - 两者都是"调度器"，需要外部工具（stylua/prettier/eslint 等）
--   - 格式化器通过 formatters_by_ft 配置，linter 通过 linters_by_ft 配置
--   - 追加配置用 extend 模式，不要覆盖默认配置
--   - <leader>cf 手动格式化，<leader>uf 切换自动格式化
