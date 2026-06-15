--- init.lua — LazyVim starter 入口文件（教学示例）
---
--- 这个文件展示 LazyVim 官方 starter 仓库的 init.lua 结构。
--- 真实使用时，这个文件会被放在 ~/.config/nvim/init.lua，Neovim 启动时自动读取。
---
--- 文件做两件事：
---   1. bootstrap lazy.nvim（没装就自动 clone）
---   2. 调用 require("lazy").setup，加载 LazyVim 默认插件 + 你的插件
---
--- ⚠️ 注意：这是教学示例。在本机没有网络/lazy.nvim 没装的情况下，
---    bootstrap 会优雅失败（pcall 保护），但文件本身语法必须正确。
---    验证命令：
---      nvim --headless -u NONE -c "luafile lazyvim/04-lazyvim-intro/lua/init.lua" -c 'qa!'

-- ============================================================================
-- 第 1 部分：bootstrap lazy.nvim
-- ============================================================================
-- lazy.nvim 是插件管理器。它本身也是个插件，但需要"自举"（bootstrap）：
-- 如果本地没有，就从 GitHub clone 一份。

-- lazy.nvim 的安装路径：~/.local/share/nvim/lazy/lazy.nvim
-- vim.fn.stdpath("data") 返回数据目录（Linux/macOS 是 ~/.local/share/nvim）
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- 检查路径是否存在（vim.uv 是 Neovim 0.10+ 的 API，vim.loop 是旧名，两者等价）
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
    -- 路径不存在 → clone lazy.nvim
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    -- 用 git clone，--filter=blob:none 只拉元数据（省流量），--branch=stable 拉稳定版
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath,
    })

    -- 如果 clone 失败（比如没网），打印错误并退出
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit...",   "NONE" },
        }, true, { err = true })
        -- 在 headless 模式下 getchar() 会阻塞，用 pcall 保护
        pcall(vim.fn.getchar)
        -- 教学示例：真实 starter 会 os.exit(1)，这里为了演示安全不真正退出
        -- os.exit(1)
        print("[demo] lazy.nvim clone failed — 在真实环境这里会退出")
    end
end

-- 把 lazy.nvim 的路径加到 runtimepath 前面，这样 require("lazy") 才能找到它
-- 注意：vim.opt.rtp:prepend 是方法调用（冒号语法），把 lazypath 加到 rtp 最前面
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- 第 2 部分：require("lazy").setup
-- ============================================================================
-- setup() 接收一个配置 table，spec 是核心字段——它定义"要装哪些插件"。

-- 用 pcall 保护，确保 lazy.nvim 没装时文件依然能被 luafile 解析
local ok, lazy = pcall(require, "lazy")
if not ok then
    -- lazy.nvim 没装（教学环境正常情况），打印提示后优雅返回
    print("[demo] lazy.nvim not installed — this is expected in tutorial environment")
    print("[demo] 真实环境首次启动时，上面的 bootstrap 会自动 clone lazy.nvim")
    return
end

-- 真正调用 setup（真实环境才会走到这里）
lazy.setup({
    -- spec: 插件规格列表
    spec = {
        -- 第一行：加载 LazyVim 本体 + LazyVim 的默认插件集
        -- import = "lazyvim.plugins" 表示"导入 lazyvim/plugins/ 目录下的所有 spec"
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },

        -- 第二行：导入你的个人插件配置
        -- import = "plugins" 表示"导入 ~/.config/nvim/lua/plugins/ 下的所有 .lua 文件"
        -- 每个文件返回一个 spec table（或 spec table 列表）
        { import = "plugins" },
    },

    -- install: 安装时的行为
    -- colorscheme 指定安装过程中用的临时配色（主配色可能还没装好）
    install = {
        colorscheme = { "tokyonight", "habamax" },
    },

    -- checker: 自动检查更新
    -- enabled = true 表示启动时后台检查插件更新，notify = false 表示不弹通知
    checker = { enabled = true, notify = false },

    -- performance: 性能优化（可选）
    -- rtp.reset 禁用 Neovim 自带的某些慢速 runtime 插件
    performance = {
        rtp = {
            reset = true,
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
})

-- ============================================================================
-- 总结：init.lua 的结构是固定的，你通常不需要改它。
--   真正的定制发生在：
--     - lua/config/options.lua   （vim 选项）
--     - lua/config/keymaps.lua   （快捷键）
--     - lua/plugins/*.lua         （插件 spec）
--   下一章详解。
