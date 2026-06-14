--- lua/init.lua — which-key 探索式学习演示（第08章）
---
--- 这个文件演示：
---   1. which-key 的基本 setup 配置
---   2. 用 wk.add() 注册自定义分组
---   3. pcall guard 保护（没有 which-key 也能正常加载）
---
--- ⚠️ 注意：which-key 是一个插件，需要通过 lazy.nvim 安装。
---    教学环境下可能没装，pcall 让文件优雅降级。
---    验证：nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

-- ============================================================================
-- 第 1 部分：Leader 键设置（which-key 依赖 Leader 键已设好）
-- ============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- 第 2 部分：which-key setup（如果已安装）
-- ============================================================================

local ok, wk = pcall(require, "which-key")

if not ok then
  print("[demo] which-key 未安装 — 教学环境正常情况")
  print("[demo] 真实环境下，which-key 会在按下 <Space> 300ms 后弹出快捷键菜单")
  print("[demo] 安装方式：LazyVim 已内置 which-key，无需手动安装")
  -- 即使 which-key 没装，我们仍然注册快捷键（vim.keymap.set 独立于 which-key）
  vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "保存文件" })
  vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "退出" })
  vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "查找文件" })
  vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "实时 grep" })
  return
end

-- which-key 已安装，进行完整配置
wk.setup({
  -- 延迟弹出时间（毫秒）——按下前缀键后等多久弹出菜单
  delay = 300,

  -- 键位提示样式
  icons = {
    breadcrumb = "»",   -- 显示在子菜单路径中
    separator = "→",    -- 按键和描述之间的分隔符
    group = "+",        -- 分组图标的前缀
  },

  -- 哪些键不触发 which-key
  filter = function(mapping)
    -- 过滤掉没有 desc 的映射（避免显示无意义的条目）
    return mapping.desc and mapping.desc ~= ""
  end,

  -- 触发 which-key 的键（默认就是常见的前缀键）
  triggers = {
    { "<auto>", mode = "nixsotc" },
  },
})

-- ============================================================================
-- 第 3 部分：用 wk.add() 注册自定义分组
-- ============================================================================

-- wk.add() 是 which-key v3 的核心 API。
-- 它接收一个 table 列表，每个条目描述一个快捷键或分组。
--
-- 格式：
--   { lhs, rhs, desc = "...", mode = "n" }
--
-- 分组（没有 rhs，只有 desc）：
--   { "<leader>f", group = "查找" }

wk.add({
  -- ========================================================================
  -- 分组标签（告诉 which-key 这些前缀的含义）
  -- ========================================================================
  { "<leader>f", group = "查找" },     -- 所有 <leader>f* 的分组名
  { "<leader>s", group = "搜索" },     -- 所有 <leader>s* 的分组名
  { "<leader>b", group = "buffer" },   -- 所有 <leader>b* 的分组名
  { "<leader>g", group = "git" },      -- 所有 <leader>g* 的分组名
  { "<leader>c", group = "代码" },     -- 所有 <leader>c* 的分组名
  { "<leader>x", group = "扩展" },     -- 所有 <leader>x* 的分组名
  { "<leader>u", group = "UI" },       -- 所有 <leader>u* 的分组名

  -- ========================================================================
  -- 带分组标签的快捷键（同时注册快捷键和分组）
  -- ========================================================================

  -- f: find（查找类）
  { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件" },
  { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "实时 grep" },
  { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "buffer 列表" },
  { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "最近文件" },
  { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "帮助标签" },

  -- s: search（搜索类）
  { "<leader>sw", "<cmd>Telescope grep_string<CR>", desc = "搜索当前词" },
  { "<leader>sk", "<cmd>Telescope keymaps<CR>", desc = "搜索快捷键" },
  { "<leader>sh", "<cmd>Telescope highlights<CR>", desc = "搜索高亮组" },

  -- b: buffer
  { "<leader>bb", "<cmd>e #<CR>", desc = "切换到上一个" },
  { "<leader>bd", "<cmd>bdelete<CR>", desc = "关闭当前" },
  { "<leader>bo", "<cmd>%bdelete<CR>", desc = "关闭其他" },

  -- g: git
  { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" },
  { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Git 状态" },
  { "<leader>gf", "<cmd>Telescope git_commits<CR>", desc = "Git log" },

  -- c: code
  { "<leader>ca", vim.lsp.buf.code_action, desc = "代码动作" },
  { "<leader>cr", vim.lsp.buf.rename, desc = "重命名" },
  { "<leader>cd", "<cmd>Telescope diagnostics<CR>", desc = "诊断列表" },

  -- x: extra
  { "<leader>xl", function() vim.opt.relativenumber = not vim.opt.relativenumber:get() end, desc = "切换相对行号" },
  { "<leader>xs", function() vim.opt.spell = not vim.opt.spell:get() end, desc = "切换拼写检查" },

  -- u: UI
  { "<leader>ut", "<cmd>Telescope colorscheme<CR>", desc = "切换主题" },

  -- 根目录快捷键（不属于任何前缀组）
  { "<leader>w", "<cmd>w<CR>", desc = "保存文件" },
  { "<leader>q", "<cmd>q<CR>", desc = "退出" },
})

-- ============================================================================
-- 总结：which-key 的核心工作流
--   1. 按下 <Space>（Leader 键）
--   2. 等 300ms，which-key 弹出菜单
--   3. 菜单显示所有以 <Space> 开头的快捷键（带描述）
--   4. 继续按第二个键（如 f），菜单收窄到 <Space>f* 的子菜单
--   5. 按第三个键（如 f），执行 <Space>ff（查找文件）
--
-- wk.add() 的两种用法：
--   1. 注册分组：{ "<leader>f", group = "查找" } — 只加标签，不注册快捷键
--   2. 注册快捷键：{ "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件" }
