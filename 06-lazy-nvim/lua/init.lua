--- init.lua — lazy.nvim bootstrap + setup 教学示例（第06章）
---
--- 这个文件展示 lazy.nvim 官方推荐的 bootstrap 结构。
--- 真实使用时，这是 ~/.config/nvim/init.lua 的核心部分（和第 04 章的 init.lua 一致）。
---
--- 文件做两件事：
---   1. bootstrap lazy.nvim（本地没有就自动 clone）
---   2. require("lazy").setup({ spec = {...}, ... })
---
--- ⚠️ 注意：这是教学示例。在本机没有网络/lazy.nvim 没装的情况下，
---    pcall 保护会让文件优雅降级，但语法必须正确。
---    验证：nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

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
            { out,                            "WarningMsg" },
            { "\nPress any key to exit...",   "NONE" },
        }, true, { err = true })
        pcall(vim.fn.getchar)
        -- 教学示例：真实环境会 os.exit(1)，这里不真正退出
        print("[demo] lazy.nvim clone failed — 教学环境正常情况")
    end
end

vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- 第 2 部分：require("lazy").setup
-- ============================================================================

local ok, lazy = pcall(require, "lazy")
if not ok then
    print("[demo] lazy.nvim not installed — 教学环境正常情况")
    print("[demo] 真实环境首次启动时，上面的 bootstrap 会自动 clone lazy.nvim")
    return
end

-- 真实环境才会走到这里
-- require("lazy").setup 接收一个配置 table，核心字段是 spec
lazy.setup({
    -- spec: 插件规格列表
    spec = {
        -- LazyVim 本体 + 默认插件集
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },

        -- 你的个人插件配置（lua/plugins/ 下所有 .lua）
        { import = "plugins" },
    },

    -- install: 安装时的行为
    install = {
        -- 安装过程中用的临时配色（主配色可能还没装好）
        colorscheme = { "tokyonight", "habamax" },
    },

    -- checker: 自动检查更新
    checker = {
        enabled = true,    -- 启动时后台检查更新
        notify = false,    -- 不弹通知（避免打扰）
    },

    -- change_detection: 检测配置文件变化
    change_detection = {
        enabled = true,
        notify = false,
    },

    -- performance: 性能优化
    performance = {
        rtp = {
            reset = true,
            -- 禁用 Neovim 自带的这些慢速 runtime 插件
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },

    -- ui: lazy.nvim 的 UI 配置
    ui = {
        border = "rounded",  -- 浮窗边框样式
    },

    -- debug: 调试模式（出问题时打开）
    debug = false,
})

-- ============================================================================
-- 总结：init.lua 的结构是固定的，你通常不需要改它。
--   真正的定制发生在 lua/plugins/*.lua（插件 spec）和 lua/config/*.lua（选项/键位）。
--   spec 格式和懒加载策略是第 06 章的核心内容。
