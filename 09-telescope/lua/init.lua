--- init.lua — Telescope 模糊搜索配置教学示例（第09章）
---
--- 这个文件展示如何在没有 Telescope 的环境下安全地演示配置。
--- pcall 保护让文件在教学环境（没装插件）下也能通过语法验证。
---
--- 核心知识点：
---   1. Telescope 的基本配置（defaults、pickers、extensions）
---   2. keys 懒加载模式（按键触发加载）
---   3. fzf-native 扩展（C 实现的 fzf 排序算法）
---
--- 验证：nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

-- ============================================================================
-- 第 1 部分：pcall 保护 — 没有 Telescope 时优雅降级
-- ============================================================================

local ok_telescope, telescope = pcall(require, "telescope")
if not ok_telescope then
    print("[demo] telescope.nvim not installed — 教学环境正常情况")
    print("[demo] 真实环境：Telescope 由 LazyVim 默认安装，按 <leader>ff 即可使用")
    print("[demo] 本文件展示 Telescope 的配置结构，不依赖插件本身")
    return
end

-- ============================================================================
-- 第 2 部分：Telescope 基本配置
-- ============================================================================

-- Telescope 的 setup 接收三个顶层 table：
--   defaults  — 全局默认选项（布局、排序、预览等）
--   pickers   — 每个 picker 的独立选项（find_files、live_grep 等）
--   extensions — 扩展配置（fzf、file_browser 等）

telescope.setup({
    defaults = {
        -- 布局策略：水平排列（左边结果，右边预览）
        layout_strategy = "horizontal",
        -- 排序策略：从上往下（ascending），默认是从下往上（descending）
        sorting_strategy = "ascending",
        -- 预览窗口宽度占比
        preview_width = 0.55,
        -- 结果窗口宽度占比
        results_width = 0.8,
        -- 输入框位置：top（顶部）或 bottom（底部）
        prompt_prefix = " ",
        selection_caret = " ",
        -- 缩进
        set_env = { ["COLORTERM"] = "truecolor" },
    },
    pickers = {
        find_files = {
            -- 用 fd 命令查找文件（比默认的 find 快）
            find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
        },
        live_grep = {
            -- 全文搜索时的额外参数
            additional_args = function()
                return { "--hidden" }
            end,
        },
    },
    extensions = {
        fzf = {
            -- fzf-native 扩展选项
            fuzzy = true,                    -- 模糊匹配
            override_generic_sorter = true,  -- 替换通用排序器
            override_file_sorter = true,     -- 替换文件排序器
            case_mode = "smart_case",        -- 智能大小写：全小写时忽略大小写
        },
    },
})

-- ============================================================================
-- 第 3 部分：加载 fzf-native 扩展
-- ============================================================================

-- pcall 保护：如果 fzf-native 没装（没编译成功），不会报错
-- LazyVim 默认会装 telescope-fzf-native.nvim 并自动编译
pcall(telescope.load_extension, "fzf")

-- ============================================================================
-- 总结：Telescope 的配置结构
--   - defaults：全局选项（布局、排序、外观）
--   - pickers：每个搜索命令的独立选项
--   - extensions：第三方扩展（fzf-native 最常用）
--   - keys 懒加载：按 <leader>ff 等键时才加载 Telescope（见 lua/plugins/telescope.lua）
