--- init.lua — 性能优化配置示例（第20章）
---
--- 这个文件展示如何在 init.lua 层面做性能优化：
---   1. 禁用不需要的 provider（Python/Node/Ruby/Perl）
---   2. 在 lazy.setup 里配置 performance.rtp.disabled_plugins
---   3. 设置性能相关的 vim.opt 选项
---
--- ⚠️ 注意：这是教学示例。pcall 保护让文件在没有 lazy.nvim 时也能正常加载。
---    验证：nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

-- ============================================================================
-- 第 1 部分：禁用不需要的 provider
-- ============================================================================
-- Neovim 自带 Python/Node/Ruby/Perl provider，启动时会检测对应的外部程序。
-- 如果你不需要这些语言的 Neovim 插件，禁用它们可以节省 5-15ms。
--
-- 这些 vim.g 设置必须在 lazy.nvim 加载之前完成（init.lua 顶部）。

-- 禁用 Perl provider（大多数人不用 Perl 插件）
vim.g.loaded_perl_provider = 0

-- 禁用 Ruby provider（除非你用 neovim-ruby-host）
vim.g.loaded_ruby_provider = 0

-- 禁用 Python3 provider（如果你只用 LSP 补全，不需要 pynvim）
-- ⚠️ 注意：这会禁用 rope、jedi 等依赖 Python 的插件
-- vim.g.loaded_python3_provider = 0

-- 禁用 Node provider（如果你不用 coc.nvim）
-- ⚠️ 注意：这会禁用 coc.nvim 等依赖 Node 的插件
-- vim.g.loaded_node_provider = 0

-- ============================================================================
-- 第 2 部分：bootstrap lazy.nvim
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
            { out,                            "WarningMsg" },
            { "\nPress any key to exit...",   "NONE" },
        }, true, { err = true })
        pcall(vim.fn.getchar)
        print("[demo] lazy.nvim clone failed -- 教学环境正常情况")
    end
end

vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- 第 3 部分：性能相关的 vim.opt 选项
-- ============================================================================

-- 禁用宏录制时的重绘（大文件卡顿时有用）
vim.opt.lazyredraw = true

-- 语法高亮的最大列数（超过此列不解析语法，防止大文件卡顿）
vim.opt.synmaxcol = 300

-- 按键序列等待时间（ms）：200-300ms 是个好平衡
vim.opt.timeoutlen = 300

-- updatetime：CursorHold 事件的触发间隔（影响 gitsigns、诊断浮窗等）
vim.opt.updatetime = 200

-- 禁用 swapfile（有 git 版本控制时可以关）
vim.opt.swapfile = false

-- 持久化撤销历史（推荐开）
vim.opt.undofile = true

-- ============================================================================
-- 第 4 部分：require("lazy").setup（含性能优化）
-- ============================================================================

local ok, lazy = pcall(require, "lazy")
if not ok then
    print("[demo] lazy.nvim not installed -- 教学环境正常情况")
    print("[demo] 真实环境首次启动时，上面的 bootstrap 会自动 clone lazy.nvim")
    return
end

lazy.setup({
    -- spec: 插件规格列表
    spec = {
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        { import = "plugins" },
    },

    -- install: 安装时的行为
    install = {
        colorscheme = { "tokyonight", "habamax" },
    },

    -- checker: 自动检查更新
    checker = {
        enabled = true,
        notify = false,
    },

    -- change_detection: 检测配置文件变化
    change_detection = {
        enabled = true,
        notify = false,
    },

    -- ================================================================
    -- performance: 性能优化（本章核心）
    -- ================================================================
    performance = {
        rtp = {
            -- reset = true 会重置 rtp 到 Neovim 默认值，
            -- 然后只添加 lazy.nvim 和你的插件目录。
            -- 这避免了 rtp 里积累的垃圾路径拖慢启动。
            reset = true,

            -- 禁用 Neovim 自带的慢速 runtime 插件
            -- 这些插件在启动时会被加载，禁用它们可以节省 5-10ms
            disabled_plugins = {
                "gzip",          -- 读写 .gz 文件
                "matchit",       -- % 跳转增强（treesitter 已替代）
                "matchparen",    -- 括号高亮匹配（mini.pairs 已替代）
                "netrwPlugin",   -- 内置文件浏览器（Neo-tree 已替代）
                "tarPlugin",     -- 读写 .tar 文件
                "tohtml",        -- 把 buffer 转成 HTML
                "tutor",         -- Vim 教程
                "zipPlugin",     -- 读写 .zip 文件
            },
        },
    },

    -- ui: lazy.nvim 的 UI 配置
    ui = {
        border = "rounded",
    },

    -- debug: 调试模式（出问题时打开）
    debug = false,
})

-- ============================================================================
-- 总结：init.lua 性能优化三板斧
--   1. vim.g.loaded_*_provider = 0   → 禁用不需要的 provider（5-15ms）
--   2. performance.rtp.disabled_plugins → 禁用内置 runtime 插件（5-10ms）
--   3. vim.opt.lazyredraw/synmaxcol/timeoutlen → 编辑流畅度优化
--
-- 配合 lua/plugins/*.lua 里的懒加载优化（event→ft/keys/cmd），
-- 可以把启动时间从 200ms+ 压到 50ms 以内。
