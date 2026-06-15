--- init.lua — Neo-tree 文件管理器配置教学示例（第10章）
---
--- 这个文件展示如何在没有 Neo-tree 的环境下安全地演示配置。
--- pcall 保护让文件在教学环境（没装插件）下也能通过语法验证。
---
--- 核心知识点：
---   1. Neo-tree 的基本配置（filesystem、buffers、git_status）
---   2. 窗口布局（left/right/current/float）
---   3. 文件操作（创建、删除、重命名、复制、移动）
---   4. bufferline 标签页管理
---   5. snacks.nvim dashboard 简介
---
--- 验证：nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

-- ============================================================================
-- 第 1 部分：pcall 保护 — 没有 Neo-tree 时优雅降级
-- ============================================================================

local ok_neotree, neotree = pcall(require, "neo-tree")
if not ok_neotree then
    print("[demo] neo-tree.nvim not installed — 教学环境正常情况")
    print("[demo] 真实环境：Neo-tree 由 LazyVim 默认安装，按 <leader>e 即可打开")
    print("[demo] 本文件展示 Neo-tree 的配置结构，不依赖插件本身")
    return
end

-- ============================================================================
-- 第 2 部分：Neo-tree 基本配置
-- ============================================================================

-- Neo-tree 的 setup 接收一个 table，核心字段：
--   sources       — 侧边栏的数据源（filesystem/buffers/git_status）
--   filesystem    — 文件系统相关配置
--   buffers       — 缓冲区相关配置
--   git_status    — Git 状态相关配置
--   window        — 窗口配置（位置、大小、映射）
--   default_all   — 默认的文件操作命令

neotree.setup({
    -- 数据源：侧边栏显示哪些内容
    sources = {
        "filesystem",   -- 文件系统（默认）
        "buffers",      -- 缓冲区列表
        "git_status",   -- Git 状态
    },

    -- 文件系统配置
    filesystem = {
        -- 跟随当前文件：打开文件时自动定位到它在树中的位置
        follow_current_file = {
            enabled = true,
        },
        -- 过滤器：隐藏这些文件/目录
        filtered_items = {
            visible = false,         -- 默认隐藏过滤项
            hide_dotfiles = true,    -- 隐藏 .开头的文件
            hide_gitignored = true,  -- 隐藏 .gitignore 里的文件
            hide_by_name = {
                "node_modules",
                ".git",
                "__pycache__",
            },
        },
        -- 使用 libuv 文件监视器（比默认的快）
        use_libuv_file_watcher = true,
    },

    -- 缓冲区配置
    buffers = {
        -- 跟随当前文件
        follow_current_file = {
            enabled = true,
        },
        -- 不显示已删除的缓冲区
        show_unloaded = true,
    },

    -- Git 状态配置
    git_status = {
        symbols = {
            -- 状态标记（Nerd Font 图标）
            added     = "",   -- 新增
            modified  = "",   -- 修改
            deleted   = "✖",  -- 删除
            renamed   = "",   -- 重命名
            untracked = "",   -- 未跟踪
            ignored   = "",   -- 已忽略
            unstaged  = "󰄱",  -- 未暂存
            staged    = "",   -- 已暂存
            conflict  = "",   -- 冲突
        },
    },

    -- 窗口配置
    window = {
        position = "left",   -- 左侧显示（可选：right/current/float）
        width = 35,          -- 窗口宽度
        mappings = {
            -- 窗口内的快捷键映射
            ["<space>"] = "none",   -- 禁用空格键（默认是 toggle_node）
        },
    },

    -- 默认文件操作命令
    -- Neo-tree 内置了文件操作，不需要外部命令
    default_component_configs = {
        indent = {
            with_expanders = true,
            expander_collapsed = "",
            expander_expanded = "",
        },
    },
})

-- ============================================================================
-- 第 3 部分：bufferline 标签页管理简介
-- ============================================================================

-- bufferline.nvim 是 LazyVim 默认的标签页插件
-- 它在顶部显示打开的缓冲区标签，类似 IDE 的标签页
-- 核心快捷键：
--   ]b / [b       — 下一个/上一个标签
--   <leader>bp    — 固定标签（不会被自动关闭）
--   <leader>bd    — 关闭当前标签
--   <leader>bo    — 关闭其他标签
--   <leader>bl    — 关闭左侧标签
--   <leader>br    — 关闭右侧标签
--   <leader>bf    — 关闭第一个标签
--   <leader>bP    — 关闭最后一个标签

-- ============================================================================
-- 第 4 部分：snacks.nvim dashboard 简介
-- ============================================================================

-- snacks.nvim 是 LazyVim 的工具集插件，包含多个模块：
--   - dashboard  — 启动页（ASCII art + 快捷入口）
--   - explorer   — 文件浏览器（Neo-tree 的替代方案）
--   - indent     — 缩进线
--   - input      — 输入框增强
--   - notifier   — 通知
--   - picker     — 选择器（Telescope 的替代方案）
--   - terminal   — 终端
--   - words      — 单词高亮
--
-- Dashboard 快捷入口（启动页按键）：
--   f — 查找文件（Telescope find_files）
--   g — 全文搜索（Telescope live_grep）
--   r — 最近文件（Telescope oldfiles）
--   e — 新建文件
--   s — 恢复上次会话
--   l — 恢复上次 LazyVim 会话
--   q — 退出

-- ============================================================================
-- 总结：Neo-tree 的配置结构
--   — sources：数据源（filesystem/buffers/git_status）
--   — filesystem：文件过滤、跟随当前文件
--   — window：位置、宽度、快捷键
--   — bufferline：标签页管理（]b/[b 切换，bp 固定，bd 关闭）
--   — snacks.nvim dashboard：启动页快捷入口
--   — keys 懒加载：按 <leader>e 时才加载 Neo-tree（见 lua/plugins/neo-tree.lua）
