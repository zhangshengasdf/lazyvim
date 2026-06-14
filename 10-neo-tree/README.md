# 第10章 文件管理与 Neo-tree — 侧边栏里的项目导航

> **Neo-tree 是你的文件资源管理器**——目录树、Git 状态、缓冲区列表，
> 全在一个可折叠的侧边栏里。
> 本章拆解 Neo-tree 的文件操作、bufferline 标签页、snacks.nvim dashboard，
> 学完后你用键盘就能在项目里自由穿梭，不需要鼠标点来点去。

---

## 本章目标

学完本章，你将能够：

1. **用 Neo-tree 浏览文件**：`<leader>e` 切换侧边栏，导航、预览、打开文件
2. **执行文件操作**：创建、删除、重命名、复制、移动文件
3. **管理 bufferline 标签页**：固定、关闭、切换标签
4. **理解 dashboard 启动页**：snacks.nvim 的快捷入口
5. **自定义 Neo-tree**：修改布局、过滤规则、快捷键

> ⚠️ **前置条件**：完成第 06 章（理解 lazy.nvim spec）和第 09 章（Telescope 搜索）。
> 本章是 Part 2「核心工作流」的最后一章——搜索 + 浏览 = 项目导航的完整能力。

---

## 为什么需要 Neo-tree

你可能觉得 `<leader>ff` 找文件就够了。但有些场景需要"看到目录结构"：

- **新项目入门**：不知道文件在哪，需要先看目录树
- **创建文件**：想在某个目录下新建文件
- **移动文件**：把文件从一个目录拖到另一个目录
- **查看 Git 状态**：哪些文件改了、哪些是新的

Neo-tree 就是解决这些问题的。它在左侧（或右侧）显示一个可折叠的目录树，
带 Git 状态标记、文件图标、搜索过滤。

---

## `<leader>e` — 切换 Neo-tree

```
按 <leader>e → 左侧打开 Neo-tree → 浏览文件 → 按 <CR> 打开文件 → 再按 <leader>e 关闭
```

这是 LazyVim 默认的 Neo-tree 切换键。按一次打开，再按一次关闭（toggle）。

### Neo-tree 窗口内的导航

| 快捷键 | 作用 |
|--------|------|
| `j` / `k` | 上下移动 |
| `<CR>` | 打开文件/展开目录 |
| `l` | 展开目录或打开文件 |
| `h` | 折叠目录 |
| `w` | 切换窗口大小（最大化/还原） |
| `H` | 显示/隐藏隐藏文件 |
| `I` | 显示/隐藏 gitignore 文件 |
| `.` | 切换到当前目录 |
| `R` | 刷新文件树 |
| `/` | 搜索过滤（输入文件名过滤） |
| `q` | 关闭 Neo-tree |

> 💡 **`/` 搜索过滤很实用**。目录树很长时，输入 `/config` 就能快速定位到 config 目录。

---

## 文件操作

Neo-tree 内置了文件操作，不需要外部命令。这些操作在 Neo-tree 窗口内触发：

| 快捷键 | 作用 | 说明 |
|--------|------|------|
| `a` | 新建文件/目录 | 输入名称；以 `/` 结尾表示目录 |
| `d` | 删除 | 确认后删除文件/目录 |
| `r` | 重命名 | 输入新名称 |
| `c` | 复制 | 复制到剪贴板 |
| `m` | 移动 | 移动到目标位置 |
| `p` | 粘贴 | 把剪贴板里的文件粘贴到当前位置 |
| `y` | 复制路径 | 复制文件路径到剪贴板 |
| `x` | 剪切 | 剪切文件 |

### 新建文件示例

```
在 Neo-tree 里按 a
→ 输入 "utils/helper.lua" → 创建文件（自动创建中间目录）
→ 输入 "components/" → 创建目录
```

### 重命名示例

```
在 Neo-tree 里选中文件 → 按 r
→ 输入新名称 → <CR> 确认
→ Neo-tree 自动刷新
```

> ⚠️ **Neo-tree 的文件操作是即时的**。按 `d` 删除文件时，Neovim 的 buffer 不会自动关闭。
> 如果删除的文件正好在某个 buffer 里打开，该 buffer 会变成"孤儿"。
> 用 `:bd` 关闭孤儿 buffer，或用 `<leader>bd`（bufferline 快捷键）。

---

## bufferline 标签页

bufferline.nvim 是 LazyVim 默认的标签页插件。它在顶部显示打开的缓冲区标签，类似 VS Code 的标签页。

### 核心快捷键

| 快捷键 | 作用 |
|--------|------|
| `]b` | 下一个标签 |
| `[b` | 上一个标签 |
| `<leader>bp` | 固定标签（不会被自动关闭） |
| `<leader>bd` | 关闭当前标签 |
| `<leader>bo` | 关闭其他标签 |
| `<leader>bl` | 关闭左侧标签 |
| `<leader>br` | 关闭右侧标签 |
| `<leader>bf` | 关闭第一个标签 |
| `<leader>bP` | 关闭最后一个标签 |
| `<leader>,` | 切换缓冲区（Telescope picker） |

### 固定标签（pin）

有些 buffer 你不想被意外关闭（比如配置文件、README）。
按 `<leader>bp` 固定它，固定后的标签会有特殊标记（通常是锁图标）。

固定标签不会被以下操作关闭：
- `<leader>bo`（关闭其他标签）— 保留固定标签
- `:BDelete hidden`（关闭不可见标签）— 保留固定标签

### 标签排序

bufferline 支持拖拽排序（鼠标），也支持快捷键：

| 快捷键 | 作用 |
|--------|------|
| `<leader>bse` | 按扩展名排序 |
| `<leader>bsr` | 按相对路径排序 |
| `<leader>bsm` | 按修改时间排序 |
| `<leader>bsp` | 按完整路径排序 |

---

## snacks.nvim dashboard

snacks.nvim 是 LazyVim 的工具集插件，其中 `dashboard` 模块提供了启动页。
当你不带参数打开 Neovim 时，会看到一个 ASCII art + 快捷入口的启动页。

### 启动页快捷键

| 按键 | 作用 |
|------|------|
| `f` | 查找文件（Telescope find_files） |
| `g` | 全文搜索（Telescope live_grep） |
| `r` | 最近文件（Telescope oldfiles） |
| `e` | 新建文件 |
| `s` | 恢复上次会话 |
| `l` | 恢复上次 LazyVim 会话 |
| `q` | 退出 |

> 💡 **启动页是 snacks.nvim 的 dashboard 模块**，不是 Neo-tree。
> Neo-tree 是文件树，dashboard 是启动页。两者独立，但都属于"文件导航"的范畴。

---

## Neo-tree 的三个数据源

Neo-tree 不只是文件树。它有三个数据源（sources），可以通过快捷键切换：

| 数据源 | 说明 | 切换方式 |
|--------|------|----------|
| filesystem | 文件系统（默认） | `<leader>e` 或 `:Neotree filesystem` |
| buffers | 缓冲区列表 | `:Neotree buffers` |
| git_status | Git 状态 | `:Neotree git_status` |

### git_status 视图

在 Neo-tree 里按 `:Neotree git_status`，会显示所有有 Git 变更的文件：

```
  M  lua/config/keymaps.lua     ← 修改（modified）
  A  lua/plugins/new-plugin.lua ← 新增（added）
  D  lua/old-file.lua           ← 删除（deleted）
  R  lua/config.lua → lua/config/init.lua  ← 重命名（renamed）
  ?  temp.txt                   ← 未跟踪（untracked）
```

每个文件前的状态标记对应 Git 的状态：
- `` — 已暂存（staged）
- `` — 未暂存（unstaged）
- `✖` — 已删除（deleted）
- `` — 未跟踪（untracked）
- `` — 冲突（conflict）

---

## cmd + keys 双懒加载

LazyVim 的 Neo-tree spec 同时用了 `cmd` 和 `keys` 两种懒加载：

```lua
cmd = { "Neotree" },  -- 运行 :Neotree 命令时加载
keys = {
  { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "文件管理器" },
},                     -- 按 <leader>e 时加载
```

满足任一条件就加载：
- 你按了 `<leader>e` → 加载
- 你手动输入 `:Neotree` → 加载

这比只用 `keys` 更灵活——有些用户习惯用命令而不是快捷键。

---

## 自定义 Neo-tree

### 修改窗口位置和宽度

```lua
-- 在 lua/plugins/neo-tree.lua 里
opts = function(_, opts)
  opts.window = vim.tbl_deep_extend("force", opts.window or {}, {
    position = "right",   -- 改为右侧显示
    width = 40,           -- 宽度 40 列
  })
end,
```

### 修改文件过滤规则

```lua
opts = function(_, opts)
  opts.filesystem = vim.tbl_deep_extend("force", opts.filesystem or {}, {
    filtered_items = {
      visible = false,
      hide_dotfiles = false,    -- 显示 .开头的文件
      hide_gitignored = false,  -- 显示 gitignore 的文件
      hide_by_name = {
        "node_modules",
        ".git",
      },
    },
  })
end,
```

### 跟随当前文件

```lua
opts = function(_, opts)
  opts.filesystem = vim.tbl_deep_extend("force", opts.filesystem or {}, {
    follow_current_file = {
      enabled = true,  -- 打开文件时自动定位到树中的位置
    },
  })
end,
```

---

## 反模式（什么不该做）

### ❌ 用 `opts = {...}` 覆盖 Neo-tree 的 filesystem 配置

```lua
-- ❌ 坏：覆盖了 LazyVim 的所有默认 filesystem 配置
opts = {
  filesystem = {
    follow_current_file = { enabled = true },
  },
}

-- ✅ 正确：用 function extend
opts = function(_, opts)
  opts.filesystem = vim.tbl_deep_extend("force", opts.filesystem or {}, {
    follow_current_file = { enabled = true },
  })
end,
```

### ❌ 用 `event = "VimEnter"` 加载 Neo-tree

```lua
-- ❌ 坏：Neovim 启动就加载（浪费）
event = "VimEnter",

-- ✅ 正确：用 cmd + keys 懒加载
cmd = { "Neotree" },
keys = { { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "文件管理器" } },
```

### ❌ 不带 desc 的 keys

```lua
-- ❌ 坏
keys = { "<leader>e" }

-- ✅ 正确
keys = { { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "文件管理器" } }
```

### ❌ 同时启用 Neo-tree 和 snacks.explorer

```
# LazyVim 有两个文件浏览器：
#   - neo-tree.nvim（本章）
#   - snacks.explorer（snacks.nvim 的 explorer 模块）
#
# 两个不能同时用。LazyVim 默认用 Neo-tree。
# 如果你想用 snacks.explorer，在 LazyVim extras 里启用它，会自动禁用 Neo-tree。
```

### ❌ 用 Neo-tree 的搜索替代 Telescope

```
# Neo-tree 有 / 搜索，但只过滤当前显示的文件。
# 它不会递归搜索子目录的内容。
#
# 搜索文件名 → <leader>ff（Telescope find_files）
# 搜索文件内容 → <leader>sg（Telescope live_grep）
# 浏览目录结构 → <leader>e（Neo-tree）
#
# 各司其职，不要混用。
```

---

## 运行验证

本章的 Lua 文件验证语法：

```bash
cd lazyvim/10-neo-tree

# 验证 init.lua（pcall 保护，没有 Neo-tree 也能通过）
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

# 验证 neo-tree.lua（return { ... } 形式，直接 luafile 不会报错）
nvim --headless -u NONE -c "luafile lua/plugins/neo-tree.lua" -c 'qa!'
```

预期：退出码 0，无错误。

> 💡 **真实环境验证**：如果你装了 LazyVim，把 `lua/plugins/neo-tree.lua` 复制到
> `~/.config/nvim/lua/plugins/` 下，运行 `:Lazy sync`，然后按 `<leader>e` 测试。

---

## 下一步

恭喜你完成了 Part 2「核心工作流」！回顾一下你学到了什么：

- **第 07 章**：Leader 键体系——`<leader>` 是所有快捷键的前缀
- **第 08 章**：which-key——按 `<leader>` 等 0.5 秒，弹出快捷键提示
- **第 09 章**：Telescope——模糊搜索文件和内容
- **第 10 章**（本章）：Neo-tree——文件树浏览和操作

现在你能在项目里自由导航了。**Part 3「代码智能」** 会进入"写代码"的阶段：

- **第 11 章「Treesitter」**：语法高亮和代码理解
- **第 12 章「LSP + Mason」**：语言服务器协议（自动补全、跳转定义、诊断）
- **第 13 章「补全」**：nvim-cmp 自动补全
- **第 14 章「格式化」**：代码格式化

> 💡 **本章核心**：记住三个概念——`<leader>e` 打开文件树、bufferline 管理标签页、snacks.nvim dashboard 是启动页。
> 搜索 + 浏览 = 项目导航的完整能力。

---

## 代码

- [`lua/init.lua`](./lua/init.lua) — Neo-tree 配置演示（pcall 保护）
- [`lua/plugins/neo-tree.lua`](./lua/plugins/neo-tree.lua) — Neo-tree spec（cmd + keys 懒加载 + opts extend）
- [`exercises/`](./exercises/README.md) — 4 道练习题（文件操作、bufferline、自定义配置、dashboard）

**上一章**：[09-telescope](../09-telescope/)（模糊搜索）
**下一章**：[11-treesitter](../11-treesitter/)（语法高亮）
