--- init.lua — nvim-cmp 补全引擎初始化演示（第13章）
---
--- 这个文件演示 nvim-cmp 补全引擎的初始化流程。
--- 真实使用时，nvim-cmp 是通过 lazy.nvim spec 自动加载的，
--- 这里用 pcall 保护来模拟"插件可能没装"的场景。
---
--- ⚠️ 注意：这是教学示例。在本机没有 nvim-cmp 的情况下，
---    pcall 保护会让文件优雅降级，但语法必须正确。
---    验证：nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

-- ============================================================================
-- 第 1 部分：检查 nvim-cmp 是否可用
-- ============================================================================

local ok_cmp, cmp = pcall(require, "cmp")
if not ok_cmp then
    print("[demo] nvim-cmp not installed — 教学环境正常情况")
    print("[demo] 真实环境中，LazyVim 会通过 lazy.nvim 自动加载 nvim-cmp")
    print("[demo] 补全来源：buffer / path / lsp / snippet")
    print("[demo] 按键映射：<Tab> 导航 / <CR> 确认 / <C-Space> 手动触发")
    return
end

-- ============================================================================
-- 第 2 部分：演示 nvim-cmp 的核心配置结构
-- ============================================================================

-- 真实环境才会走到这里
-- nvim-cmp 的 setup 接收一个配置 table，核心字段：
--   - snippet:   snippet 引擎配置
--   - mapping:   按键映射
--   - sources:   补全来源列表
--   - formatting: 补全项格式
--   - window:    窗口样式

local ok_luasnip, luasnip = pcall(require, "luasnip")
local snippet_engine = {}
if ok_luasnip then
    snippet_engine = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    }
end

cmp.setup({
    -- snippet 引擎配置
    snippet = snippet_engine,

    -- 按键映射（LazyVim 默认映射，这里演示核心部分）
    mapping = {
        -- Tab: 选中下一个补全项，或跳到下一个 snippet 占位符
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif ok_luasnip and luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),

        -- Shift-Tab: 选中上一个补全项，或跳到上一个 snippet 占位符
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif ok_luasnip and luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),

        -- CR: 确认选中项
        ["<CR>"] = cmp.mapping.confirm({ select = true }),

        -- C-Space: 手动触发补全
        ["<C-Space>"] = cmp.mapping.complete(),

        -- C-e: 关闭补全菜单
        ["<C-e>"] = cmp.mapping.abort(),
    },

    -- 补全来源（按优先级排序）
    sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },  -- LSP 补全（最有价值）
        { name = "luasnip",  priority = 750 },   -- snippet 补全
        { name = "path",     priority = 500 },   -- 文件路径补全
        { name = "buffer",   priority = 250 },   -- 当前 buffer 内容补全
    }),
})

-- ============================================================================
-- 总结：
--   - nvim-cmp 的配置通常在 lua/plugins/completion.lua 里通过 spec 完成
--   - LazyVim 已经配好了默认映射和来源，你只需要 extend
--   - 追加来源用 table.insert(opts.sources, ...)，不要覆盖
--   - snippet 引擎默认是 LuaSnip，可以通过 Extras 切换到 mini.snippets
