# 第07章 Leader 键体系与核心快捷键 — `<Space>` 带头的高效操作

> **Leader 键是 LazyVim 的调度中心**——按下 `<Space>`，整个键盘变成一张功能菜单。
> 本章拆解 LazyVim 的 6 大 Leader 前缀体系，用一张 ASCII 树展示完整结构，
> 再教你 buffer 切换和窗口导航这两组"肌肉记忆级"快捷键。
> 学完本章，你不需要记 100 个快捷键，只需要理解**分类逻辑**——需要用时 `which-key`（第 08 章）会告诉你按什么。

---

## 本章目标

学完本章，你将能够：

1. **理解 Leader 键的本质**：`vim.g.mapleader` 如何影响所有 `<leader>` 快捷键
2. **掌握 6 大前缀体系**：`f`(find)、`s`(search)、`b`(buffer)、`g`(git)、`c`(code)、`x`(extra) 各管什么
3. **熟练 buffer 切换**：`<S-h>` / `<S-l>` 在打开的文件间快速跳转
4. **熟练窗口导航**：`<C-h/j/k/l>` 在分屏间无缝移动
5. **用 `vim.keymap.set` 注册自定义 Leader 快捷键**：带 `desc`，和 LazyVim 风格一致

> ⚠️ **前置条件**：完成第 06 章（理解 lazy.nvim spec 格式和懒加载）。
> 本章是 Part 2「核心工作流」的第一章——从"理解架构"转向"高效使用"。

---

## Leader 键是什么

### 概念

Leader 键是一个**前缀键**，按下后 Neovim 进入"等待下一个键"的状态。
它的作用是给快捷键分组——就像文件系统的目录，`<leader>f` 是"查找类"目录，
`<leader>ff`、`<leader>fg`、`<leader>fb` 是里面的文件。

### LazyVim 的选择：空格

```lua
-- LazyVim 默认在 options.lua 里设置
vim.g.mapleader = " "   -- 空格键作为 Leader
```

为什么选空格？因为空格是键盘上最大的键，拇指一按就到。
对比其他选择：

| Leader 键 | 优点 | 缺点 |
|-----------|------|------|
| `<Space>`（空格） | 拇指易达，不干扰任何 Vim 原生操作 | 在插入模式下会输入空格（但 Leader 只在 Normal 模式生效） |
| `,`（逗号） | 传统 Vim 用户常用 | 和 `f{char}` 的 `,`（重复查找）冲突 |
| `\`（反斜杠） | Vim 默认 Leader | 太远，按着累 |

> ⚠️ **`mapleader` 必须在任何 `<leader>` 快捷键注册之前设置**。
> Neovim 在 `vim.keymap.set` 时把 `<leader>` 替换为当时的 `mapleader` 值。
> 如果你先注册快捷键再改 `mapleader`，快捷键会用旧的 leader 值。
>
> LazyVim 的加载顺序保证了这一点：`options.lua`（设 leader）先于 `keymaps.lua`（注册快捷键）。

---

## Leader 前缀体系总览

LazyVim 的 `<leader>` 快捷键按**功能分类**，用一个字母做前缀。
这不是随意分配的，而是一套可推导的命名系统。

### 6 大前缀速查表

| 前缀 | 含义 | 典型操作 | 插件来源 |
|------|------|----------|----------|
| `<leader>f` | **f**ind（查找） | 查找文件、grep 文本、最近文件 | Telescope |
| `<leader>s` | **s**earch（搜索） | 搜索高亮、搜索替换、搜索帮助 | Telescope + Flash |
| `<leader>b` | **b**uffer（缓冲区） | 切换 buffer、关闭 buffer、buffer 列表 | bufferline + Telescope |
| `<leader>g` | **g**it | Git 状态、diff、提交、blame | gitsigns + lazygit + Telescope |
| `<leader>c` | **c**ode（代码） | 代码操作、重命名、诊断、格式化 | LSP + conform + lint |
| `<leader>x` | e**x**tra（扩展） | 行号切换、拼写检查、颜色拾取 | LazyVim extras |
| `<leader>u` | **u**I（界面） | 主题切换、透明度、补全开关 | LazyVim UI toggle |

### ASCII Leader 树

```
<Space> (Leader)
│
├─ f  find (查找)
│   ├─ ff  查找文件          (Telescope find_files)
│   ├─ fg  实时 grep         (Telescope live_grep)
│   ├─ fb  buffer 列表       (Telescope buffers)
│   ├─ fr  最近文件          (Telescope oldfiles)
│   ├─ fh  帮助标签          (Telescope help_tags)
│   └─ fc  Neovim 配置文件   (Telescope find_files ~/.config/nvim)
│
├─ s  search (搜索)
│   ├─ sw  搜索当前词        (Telescope grep_string)
│   ├─ sg  全局 grep         (Telescope live_grep)
│   ├─ sh  搜索高亮          (Telescope highlights)
│   └─ sk  搜索快捷键        (Telescope keymaps)
│
├─ b  buffer (缓冲区)
│   ├─ bb  切换到上一个       (bufferline: pick)
│   ├─ bd  关闭当前          (Snacks bufdelete)
│   ├─ bl  关闭左侧          (bufferline: close_left)
│   ├─ bo  关闭其他          (bufferline: close_others)
│   └─ br  关闭右侧          (bufferline: close_right)
│
├─ g  git
│   ├─ gg  打开 LazyGit      (lazygit.nvim)
│   ├─ gf  当前文件 git log  (Telescope git_commits)
│   ├─ gs  git 状态          (Telescope git_status)
│   └─ gb  git blame 行      (gitsigns: blame_line)
│
├─ c  code (代码)
│   ├─ ca  代码动作          (LSP code_action)
│   ├─ cr  重命名            (LSP rename)
│   ├─ cf  格式化            (conform.nvim format)
│   └─ cd  诊断              (Telescope diagnostics)
│
├─ x  extra (扩展)
│   ├─ xn  切换行号          (relative number toggle)
│   ├─ xs  切换拼写检查      (spell toggle)
│   └─ xc  颜色拾取          (nvim-colorizer)
│
└─ u  UI (界面)
    ├─ ut  切换主题          (Telescope colorscheme)
    ├─ uc  切换补全          (nvim-cmp toggle)
    └─ ul  切换行号          (line number toggle)
```

> 💡 **不需要背这张表**。按下 `<Space>` 等 300ms，which-key（第 08 章）会弹出完整菜单。
> 本章的目标是让你**理解分类逻辑**，而不是死记硬背。

---

## 为什么要这样分类

### 推导逻辑

LazyVim 的前缀不是随意分配的，有一条清晰的推导链：

1. **最常用的操作用最短的路径**：`<leader>ff`（查找文件）只有 3 次按键
2. **按功能域分组**：所有和"找东西"相关的放 `f`，所有和"Git"相关的放 `g`
3. **第二字母是语义缩写**：`ff` = find files, `fg` = find grep, `fb` = find buffers
4. **避免和 Vim 原生键冲突**：`<leader>w`（保存）、`<leader>q`（退出）这些"动词"不在前缀体系里

### 为什么 `<leader>w` 不在前缀表里

`<leader>w`（保存文件）和 `<leader>q`（退出）是**独立的动词快捷键**，不属于任何前缀组。
它们是 LazyVim 在 `keymaps.lua` 里直接注册的，不通过插件 spec：

```lua
-- LazyVim 内部（你不需要写）
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "保存文件" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "退出" })
```

这些"单字母 Leader 键"可以理解为"根目录下的快捷方式"，和 6 大前缀体系是平级的。

---

## Buffer 切换 — `<S-h>` 和 `<S-l>`

### 什么是 Buffer

Buffer 是 Neovim 的内存缓冲区——每个打开的文件对应一个 buffer。
你打开 5 个文件，就有 5 个 buffer，但屏幕上只显示 1 个（当前 buffer）。

### LazyVim 的 Buffer 切换

```vim
<S-h>    " 切换到左边的 buffer（上一个文件）
<S-l>    " 切换到右边的 buffer（下一个文件）
```

`<S-h>` 就是大写 H（Shift+H），`<S-l>` 就是大写 L（Shift+L）。
这两个键在 Normal 模式下原本是"移动到屏幕顶部/底部"，LazyVim 重新映射了它们。

### 为什么用 `<S-h>` / `<S-l>` 而不是 `:bnext` / `:bprev`

| 方式 | 按键次数 | 需要思考 |
|------|----------|----------|
| `:bnext<CR>` | 7 次 | 要记命令名 |
| `:bn<CR>` | 4 次 | 要记缩写 |
| `<S-h>` / `<S-l>` | 1 次 | 方向直觉：H=左=上一个，L=右=下一个 |

> 💡 **配合 bufferline（顶部标签栏）**：bufferline 会在顶部显示所有打开的文件名，
> `<S-h>` / `<S-l>` 切换时标签栏会高亮当前文件，视觉反馈很清晰。

### 相关的 `<leader>b` 操作

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `<leader>bd` | 关闭当前 buffer | 不关闭窗口，只关文件 |
| `<leader>bo` | 关闭其他 buffer | 只保留当前文件 |
| `<leader>bl` | 关闭左侧 buffer | 关掉当前左边的所有文件 |
| `<leader>br` | 关闭右侧 buffer | 关掉当前右边的所有文件 |
| `<leader>bb` | 切换到上一个 buffer | 在最近两个文件间快速切换 |
| `<leader>fb` | 模糊搜索 buffer | Telescope 弹出 buffer 列表 |

---

## 窗口导航 — `<C-h/j/k/l>`

### 什么是 Window

Window 是 buffer 的"视口"——一个屏幕可以分成多个窗口，每个窗口显示一个 buffer。
用 `:split`（水平分）或 `:vsplit`（垂直分）创建新窗口。

### LazyVim 的窗口导航

```vim
<C-h>    " 移动到左边的窗口
<C-j>    " 移动到下方的窗口
<C-k>    " 移动到上方的窗口
<C-l>    " 移动到右边的窗口
```

这和 Vim 的 `hjkl` 方向键一一对应：

```
         ┌─────────┐
         │  <C-k>  │   上
         │  (up)   │
┌────────┼─────────┼────────┐
│ <C-h>  │         │ <C-l>  │
│ (left) │ 当前窗口 │ (right)│
└────────┼─────────┼────────┘
         │  <C-j>  │   下
         │ (down)  │
         └─────────┘
```

### 为什么 `<C-l>` 不冲突

Vim 原生的 `<C-l>` 是"重绘屏幕"（`:redraw`）。LazyVim 重新映射它为窗口导航，
但保留了重绘功能——当你在最后一个窗口按 `<C-l>` 时会触发重绘。

### 窗口管理快捷键

| 快捷键 | 功能 |
|--------|------|
| `<C-h/j/k/l>` | 在窗口间移动 |
| `<leader>wd` | 关闭当前窗口 |
| `<leader>wm` | 最大化当前窗口（再次按恢复） |
| `<leader>-` | 水平分屏（下方新窗口） |
| `<leader>\|` | 垂直分屏（右方新窗口） |
| `<C-Up>` | 增加窗口高度 |
| `<C-Down>` | 减少窗口高度 |
| `<C-Left>` | 增加窗口宽度 |
| `<C-Right>` | 减少窗口宽度 |

> 💡 **小屏终端推荐**：用 `<leader>wd` 关掉不用的窗口，`<C-h/j/k/l>` 快速切换。
> 不需要记所有窗口命令，会导航 + 关闭就够了。

---

## 用 `vim.keymap.set` 注册自定义 Leader 快捷键

### 基本语法

```lua
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "查找文件" })
--               │    │            │                                │
--               │    │            │                                └─ 选项（desc 必须有）
--               │    │            └─ 右侧（执行的命令）
--               │    └─ 左侧（按键序列）
--               └─ 模式（n = Normal）
```

### 四个参数详解

| 参数 | 含义 | 常见值 |
|------|------|--------|
| `mode` | 模式 | `"n"` Normal, `"i"` Insert, `"v"` Visual, `"x"` Visual-only |
| `lhs` | 按键序列 | `"<leader>ff"`, `"<C-h>"`, `"<S-l>"` |
| `rhs` | 执行内容 | `"<cmd>Telescope find_files<CR>"`（命令）或 `function() ... end`（函数） |
| `opts` | 选项 table | `{ desc = "...", silent = true, noremap = true }` |

### `desc` 字段是必须的

```lua
-- ❌ 坏：没有 desc，which-key 只显示按键不显示功能
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>")

-- ✅ 正确：带 desc
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "查找文件" })
```

`desc` 不只是文档——which-key（第 08 章）靠它显示快捷键提示。
没有 desc 的快捷键在 which-key 里是"盲"的。

### 示例：自定义 Leader 快捷键

```lua
-- 保存和退出（LazyVim 已内置，这里演示写法）
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "保存文件" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "退出" })

-- 快速打开配置目录
vim.keymap.set("n", "<leader>fc", function()
  require("telescope.builtin").find_files({
    cwd = vim.fn.stdpath("config"),
  })
end, { desc = "查找配置文件" })

-- 切换行号模式
vim.keymap.set("n", "<leader>xl", function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "切换相对行号" })

-- 多模式映射：Visual 模式下也能用
vim.keymap.set({ "n", "x" }, "<leader>p", '"+p', { desc = "从系统剪贴板粘贴" })
```

> ⚠️ **反模式：用 `vim.api.nvim_set_keymap`**。这个 API 已被弃用（Neovim 0.7+），
> 不支持 Lua function 作为 rhs，也不支持 `desc` 字段。永远用 `vim.keymap.set`。

---

## 如何查看当前所有 Leader 快捷键

### 方法 1：which-key（推荐，第 08 章详解）

按下 `<Space>` 等 300ms，which-key 弹出所有以 `<Space>` 开头的快捷键列表。

### 方法 2：`:nmap <leader>`

```vim
:nmap <leader>
```

会列出所有 Normal 模式下以 Leader 键开头的映射。但输出是"展开形式"——
因为 `<leader>` 被替换成了实际的键（空格），所以显示的是 `<Space>ff` 而不是 `<leader>ff`。

### 方法 3：Telescope keymaps

```vim
:Telescope keymaps
```

或按 `<leader>sk`（搜索快捷键），Telescope 会列出所有已注册的快捷键，支持模糊搜索。

---

## 反模式（什么不该做）

### ❌ 不设 `desc` 就注册 Leader 快捷键

```lua
-- ❌ 坏：which-key 里只看到按键，不知道干什么
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>")

-- ✅ 正确：带 desc
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "查找文件" })
```

### ❌ 在 `options.lua` 之前注册 `<leader>` 快捷键

```lua
-- ❌ 坏：如果 mapleader 还没设，<leader> 会被解析为默认的 `\`
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "保存" })
-- ... 后面才设 vim.g.mapleader = " "

-- ✅ 正确：先设 leader，再注册快捷键（LazyVim 的加载顺序已保证）
```

### ❌ 用 `vim.api.nvim_set_keymap` 替代 `vim.keymap.set`

```lua
-- ❌ 坏：已弃用，不支持 Lua function，不支持 desc
vim.api.nvim_set_keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { noremap = true })

-- ✅ 正确
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "查找文件" })
```

### ❌ 记 100 个快捷键而不理解分类逻辑

Leader 键体系的设计是**可推导的**——你不需要死记，只需要知道：
- `f` = find（找文件/文本）
- `g` = git
- `c` = code
- `b` = buffer

需要什么功能时，先想它属于哪个分类，再试第一字母。which-key 会告诉你剩下按什么。

---

## 运行验证

本章的 `lua/init.lua` 演示了 Leader 键设置和核心快捷键注册。验证语法：

```bash
cd lazyvim/07-leader-keys

# 验证 init.lua 语法（pcall guard 保护，不会报错）
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
```

预期：退出码 0，无错误。

> ⚠️ **关于 verify.lua 和 Leader 快捷键**：`shared/verify.lua` 的 `check_keymap` 函数
> 查询 `<leader>ff` 时会失败——因为 Neovim 注册时把 `<leader>` **展开**成了实际的键
> （空格），存储的 lhs 是 `" ff"`（空格+ff），不是 `"<leader>ff"`。
>
> 这是 Neovim 的设计行为，不是 bug。验证 Leader 快捷键的方法：
> - 交互式：运行 `:nmap <leader>` 查看所有 Leader 映射
> - 编程式：查询展开后的键 `check_keymap("n", " ff")`（空格+ff）
> - 或者只验证选项（`check_opt`），跳过 Leader 快捷键的检查

---

## 下一步

你已经理解了 LazyVim 的 Leader 键体系和核心快捷键。但这些快捷键怎么**发现**？
当你忘了 `<leader>ff` 是干什么的，怎么办？

**第 08 章「which-key 探索式学习」** 会教你用 which-key 弹出菜单——
按下 `<Space>` 等 300ms，所有快捷键一览无余。

> 💡 **本章核心**：Leader 键是按功能分类的——`f`(find)、`g`(git)、`c`(code)、`b`(buffer)。
> 不需要死记，理解逻辑就够。which-key 是你的"快捷键备忘单"。

---

## 代码

- [`lua/init.lua`](./lua/init.lua) — Leader 键设置 + 核心快捷键演示
- [`exercises/`](./exercises/README.md) — 4 道练习题（Leader 分类、自定义快捷键、buffer/窗口操作）

**上一章**：[06-lazy-nvim](../06-lazy-nvim/)（lazy.nvim 插件管理器）
**下一章**：[08-which-key](../08-which-key/)（which-key 探索式学习）
