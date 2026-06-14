# 第03章 · Neovim 基础与 init.lua —— 写出你的第一份配置

> **一句话钩子**：前两章你一直在「裸用」Vim，命令记住了却没法自定义。这章终于轮到 **init.lua**——
> Neovim 的配置入口。你会学会窗口分屏同时看多个文件、缓冲区管理在多文件间穿梭、
> 并亲手写出一份能用的 `~/.config/nvim/init.lua`，从今以后「你的 Neovim」就有了个性。

这章是 Part 0（Vim 生存）的收官，也是 Part 1（架构）的前奏——LazyVim 就是一份
精心整理的 init.lua 大礼包，你得先懂裸 Neovim 怎么配置，才能看懂 LazyVim 在干嘛。

---

## 本章目标

学完本章，你将能够：

1. **窗口分屏**：`:split` `:vsplit` 用 `Ctrl-w hjkl` 在窗口间穿梭，一键关掉其他窗口。
2. **缓冲区管理**：`:bn` `:bp` `:bd` `:ls` `:b N` 理解「缓冲区 vs 窗口」的区别。
3. **标签页**：`:tabnew` `gt` `gT` `:tabc` 用标签页组织多个工作集。
4. **找到 init.lua**：`~/.config/nvim/init.lua` 在哪，Neovim 启动时怎么加载它。
5. **配置选项**：`vim.opt` vs `vim.o` vs `vim.go` 的区别，怎么设置 number/tabstop/signcolumn。
6. **拆分配置目录**：把 init.lua 拆成 `lua/config/` 多个文件，让配置可维护。

---

## 1. 窗口（Window）：屏幕的一块区域

**窗口**是屏幕上的一块区域，显示某个缓冲区的内容。一个缓冲区可以同时被多个窗口显示。

### 1.1 创建窗口

| 命令 | 作用 |
|------|------|
| `:split` 或 `:sp` | **水平分屏**（上下两个窗口） |
| `:vsplit` 或 `:vs` | **垂直分屏**（左右两个窗口） |
| `Ctrl-w s` | 等价 `:split` |
| `Ctrl-w v` | 等价 `:vsplit` |

```
:vsplit 前:                :vsplit 后:
┌───────────────┐         ┌───────┬───────┐
│               │         │       │       │
│   file.txt    │   →     │ file  │ file  │
│               │         │       │       │
└───────────────┘         └───────┴───────┘
                          (同一文件显示两次)
```

### 1.2 在窗口间移动

| 键 | 作用 |
|----|------|
| `Ctrl-w h` | 移到**左**窗口 |
| `Ctrl-w j` | 移到**下**窗口 |
| `Ctrl-w k` | 移到**上**窗口 |
| `Ctrl-w l` | 移到**右**窗口 |
| `Ctrl-w w` | 循环到**下一个**窗口 |

> 💡 `Ctrl-w` 是窗口命令的「前缀」。按完 `Ctrl-w` 再按方向键 `hjkl`，和移动光标的逻辑一样。

### 1.3 窗口操作

| 键 / 命令 | 作用 |
|-----------|------|
| `Ctrl-w c` | 关闭**当前**窗口（`:q` 也行） |
| `Ctrl-w o` | 关闭**其他所有**窗口（只留当前，o = only） |
| `Ctrl-w =` | 让所有窗口**等宽等高** |
| `Ctrl-w +` | 增加当前窗口高度 |
| `Ctrl-w -` | 减少当前窗口高度 |
| `Ctrl-w >` | 增加宽度（垂直窗口） |
| `Ctrl-w <` | 减少宽度 |
| `Ctrl-w _` | 当前窗口**最大化高度** |
| `Ctrl-w \|` | 当前窗口**最大化宽度** |

---

## 2. 缓冲区（Buffer）：内存里的文件

**缓冲区**是文件在内存中的表示。你打开一个文件，Neovim 创建一个缓冲区装它的内容。

### 2.1 关键区分：缓冲区 ≠ 窗口 ≠ 文件

```
文件 (磁盘)            缓冲区 (内存)           窗口 (屏幕)
─────────────         ─────────────         ─────────────
a.txt ─────read──► [Buffer 1: a.txt] ◄──show── Window A
b.txt ─────read──► [Buffer 2: b.txt] ◄──show── Window B
c.txt ─────read──► [Buffer 3: c.txt] ◄──show── Window C
                                         (一个缓冲区可多窗口显示)
```

- **文件**：磁盘上的字节。
- **缓冲区**：Neovim 读进内存的副本，编辑是对副本操作，`:w` 才写回磁盘。
- **窗口**：屏幕上的一块，显示某个缓冲区。

### 2.2 缓冲区命令

| 命令 | 作用 |
|------|------|
| `:ls` 或 `:buffers` | 列出所有缓冲区（带编号） |
| `:bn` | 下一个缓冲区（**b**uffer **n**ext） |
| `:bp` | 上一个缓冲区（**b**uffer **p**revious） |
| `:bd` | 关闭当前缓冲区（**b**uffer **d**elete，`d!` 强制丢弃改动） |
| `:b N` | 跳到第 N 号缓冲区（`:b 3` 跳到 buffer 3） |
| `:b name<Tab>` | 按名字补全跳转（`:b main<Tab>` 补全成 main.lua） |

### 2.3 `:ls` 输出解读

```
:ls
  1 #a   "a.txt"                       line 12
  2 %a   "b.txt"                       line 1
  3  h   "c.txt"                       line 5
```

- 第一列数字：缓冲区**编号**（`:b N` 用这个）。
- 第二列标记：`%` = 当前窗口的缓冲区，`#` = 上一个缓冲区（`Ctrl-^` 切换），`a` = active（显示在窗口），`h` = hidden（隐藏，没显示但仍在内存），`+` = 有未保存改动。

> 💡 本章 init.lua 设了 `vim.opt.hidden = true`——允许缓冲区隐藏，这样 `:bn` 切换时不会逼你先保存。

---

## 3. 标签页（Tab）：窗口布局的集合

Vim 的标签页和浏览器标签**不一样**。浏览器的标签页 = 一个文档；
**Vim 的标签页 = 一组窗口布局**。

```
Tab 1 (调试布局)          Tab 2 (写作布局)
┌─────────┬───────┐      ┌───────────────────┐
│  code   │ watch │      │                   │
├─────────┴───────┤      │   markdown 文章   │
│   terminal      │      │                   │
└─────────────────┘      └───────────────────┘
  (2 个窗口的分屏)          (1 个窗口)
```

### 标签页命令

| 命令 / 键 | 作用 |
|-----------|------|
| `:tabnew file` | 新建标签页打开 file（不带 file 则开空标签页） |
| `:tabc` | 关闭当前标签页（**tab** **c**lose） |
| `:tabo` | 关闭其他所有标签页（**tab** **o**nly） |
| `gt` | 下一个标签页 |
| `gT` | 上一个标签页 |
| `NgT` / `Ngt` | 跳到第 N 个标签页 |
| `:tabs` | 列出所有标签页 |

---

## 4. init.lua 在哪里？

Neovim 启动时会自动加载配置文件，位置取决于系统：

| 系统 | 配置路径 |
|------|----------|
| Linux / macOS | `~/.config/nvim/init.lua` |
| Windows | `%LOCALAPPDATA%\nvim\init.lua` |

> ⚠️ Neovim 只认 `init.lua`（推荐）。老式的 `init.vim`（Vimscript）也能用，但本教程全程 Lua。
> 如果两者都存在，Neovim 优先加载 `init.lua`。

### 配置目录结构

```
~/.config/nvim/
├── init.lua              ← 入口，Neovim 启动时第一个加载
└── lua/                  ← Lua 模块目录（require 能找到）
    ├── config/           ← 你的自定义配置模块
    │   ├── options.lua   ← 选项设置
    │   ├── keymaps.lua   ← 快捷键
    │   └── autocmds.lua  ← 自动命令
    └── plugins/          ← 插件配置（Part 1 之后用）
```

`init.lua` 里用 `require("config.options")` 加载 `lua/config/options.lua`——
这是把配置拆小、保持可维护的标准做法。

---

## 5. `vim.opt` vs `vim.o` vs `vim.go` vs `vim.wo` vs `vim.bo`

Neovim 的 Lua API 提供 5 种方式设置选项，初学者容易懵：

| API | 作用域 | 什么时候用 |
|-----|--------|-----------|
| `vim.opt.X = v` | 设置**当前**缓冲区/窗口的选项（智能判断作用域） | **推荐**，99% 场景用它 |
| `vim.o.X = v` | 设置**全局**默认值（影响所有窗口/缓冲区） | 需要全局生效时 |
| `vim.go.X = v` | 只设全局（**g**lobal **o**nly），不影响当前值 | 少用 |
| `vim.wo.X = v` | 只设**窗口**选项（**w**indow） | 分屏后单独设某窗口 |
| `vim.bo.X = v` | 只设**缓冲区**选项（**b**uffer） | 给某个缓冲区单独设 |

### 为什么推荐 `vim.opt`？

```lua
-- vim.opt 智能处理作用域
vim.opt.number = true        -- number 是窗口选项，vim.opt 设到当前窗口 + 全局默认
vim.opt.tabstop = 2          -- tabstop 是缓冲区选项，vim.opt 设到当前缓冲区 + 全局默认

-- vim.o 只设全局，可能不立即生效
vim.o.number = true          -- 只设全局，新建窗口才继承

-- vim.opt 还能处理列表型选项（listchars, completeopt）
vim.opt.listchars = { tab = "» ", trail = "·" }  -- 优雅
vim.o.listchars = "tab:» ,trail:·"               -- 字符串拼接，易错
```

> 💡 **本教程统一用 `vim.opt`**，除非有明确全局/局部需求。读取值时用 `vim.opt.X:get()` 或直接 `vim.o.X`（后者调试更方便）。

---

## 6. 基础选项设置演示

以下是初学者必配的选项（本章 `lua/init.lua` 完整实现）：

| 选项 | 推荐值 | 作用 |
|------|--------|------|
| `number` | `true` | 显示绝对行号 |
| `relativenumber` | `true` | 显示相对行号（便于 `10j` 跳转） |
| `tabstop` | `2` | Tab 视觉宽度 |
| `shiftwidth` | `2` | 自动缩进宽度 |
| `expandtab` | `true` | Tab 展开为空格 |
| `signcolumn` | `"yes"` | 标志列常驻（避免 LSP 诊断时屏幕跳动） |
| `termguicolors` | `true` | 真彩色 |
| `splitright` | `true` | 新垂直窗口在右侧 |
| `splitbelow` | `true` | 新水平窗口在下方 |
| `hidden` | `true` | 允许隐藏缓冲区（`:bn` 不强制保存） |

完整的选项和第一个 keymap（`<leader>w` 保存、`<leader>q` 退出、窗口导航等）见 [`lua/init.lua`](./lua/init.lua)。

> ⚠️ **不要用** `LazyVim.safe_keymap_set`——那是 LazyVim 内部函数，裸 Neovim 没有。
> 永远用 `vim.keymap.set(mode, lhs, rhs, opts)`。

---

## 7. 拆分配置到 lua/config/ 目录

随着配置变长，把所有东西塞进 init.lua 会失控。标准做法是拆模块：

```
~/.config/nvim/
├── init.lua              ← 入口，只做 require
└── lua/
    └── config/
        ├── options.lua   ← 所有 vim.opt 设置
        ├── keymaps.lua   ← 所有 vim.keymap.set
        └── autocmds.lua  ← 自动命令（进入某 filetype 时做什么）
```

`init.lua` 变得很简洁：

```lua
-- init.lua
require("config.options")   -- 加载 lua/config/options.lua
require("config.keymaps")   -- 加载 lua/config/keymaps.lua
require("config.autocmds")  -- 加载 lua/config/autocmds.lua
```

本章的 `lua/init.lua` 演示了完整配置；`lua/config/` 目录展示了拆分后的样子（详见代码链接）。
你真正部署时，把 `init.lua` 内容拆到 `lua/config/options.lua` 即可。

---

## 8. 反模式（什么不该做）

### ❌ 把所有配置塞进一个巨大的 init.lua

**问题**：配置超过 200 行后，找东西要 Ctrl-F 半天，改一处怕动错别处。
**正确**：拆成 `lua/config/options.lua` `keymaps.lua` `autocmds.lua`，init.lua 只做 require。

### ❌ 用废弃的 `vim.api.nvim_set_keymap`

**问题**：老教程多用 `vim.api.nvim_set_keymap("n", "<leader>w", ":w<CR>", {noremap=true})`——
冗长、不支持 Lua 函数、要手动写 `noremap`。
**正确**：用 `vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "保存" })`——
默认 noremap、支持传函数、desc 给 which-key 用。

### ❌ 分屏后忘了缓冲区和窗口的区别

**问题**：`:q` 关掉一个窗口，以为「文件没了」，其实缓冲区还在（`:ls` 能看到）。
**正确**：`:q` 只关窗口，`:bd` 才关缓冲区。要彻底清掉文件用 `:bd`。

### ❌ 用 `vim.o` 设置窗口/缓冲区选项

**问题**：`vim.o.number = true` 只设全局默认，已有窗口不立即生效。
**正确**：用 `vim.opt.number = true`，它智能设到全局 + 当前。

### ❌ 标签页当浏览器标签用

**问题**：每个标签页放一个文件，以为这是「多文件编辑」——其实缓冲区才是。
**正确**：标签页用于**不同的窗口布局**（如「写代码布局」「调试布局」）。
多文件切换用缓冲区（`:bn` `:bp` `:b name`）。

---

## 9. 运行验证

### 验证 init.lua 可加载

```bash
nvim --headless -u lazyvim/03-neovim-basics/lua/init.lua -c 'qa!'
echo "Exit code: $?"
# 期望: Exit code: 0
```

### 验证完整选项

```bash
nvim --headless -u lazyvim/03-neovim-basics/lua/init.lua \
  -c "lua print('number=' .. tostring(vim.o.number))" \
  -c "lua print('relativenumber=' .. tostring(vim.o.relativenumber))" \
  -c "lua print('tabstop=' .. vim.o.tabstop)" \
  -c "lua print('signcolumn=' .. vim.o.signcolumn)" \
  -c 'qa!'
```

### 验证选项与键位

```bash
nvim --headless -u lazyvim/03-neovim-basics/lua/init.lua \
  -c "lua verify = dofile('lazyvim/shared/verify.lua')" \
  -c "lua verify.run({ \
    {fn = verify.check_opt, args = {'number', true}}, \
    {fn = verify.check_opt, args = {'relativenumber', true}}, \
    {fn = verify.check_opt, args = {'tabstop', 2}}, \
    {fn = verify.check_opt, args = {'expandtab', true}}, \
    {fn = verify.check_opt, args = {'hidden', true}}, \
  })" \
  -c 'qa!'
```

> 💡 **关于 leader 键的验证**：`<leader>w` 注册后，Neovim 把 `<leader>` 展开成实际的空格字符，
> 所以 `check_keymap('n', '<leader>w')` 会查不到（实际存储的是 `" w"`）。
> 验证 leader 键位用交互模式 `:nmap <leader>` 查看所有 leader 映射，或 `:verbose nmap <leader>w`。

### 部署到真实环境

```bash
# 备份现有配置
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null

# 复制本章配置到 ~/.config/nvim/
mkdir -p ~/.config/nvim/lua/config
cp lazyvim/03-neovim-basics/lua/init.lua ~/.config/nvim/init.lua

# 启动 nvim（不带 -u），应该自动加载你的配置
nvim
```

---

## 10. 本章代码结构

```
03-neovim-basics/
├── README.md          ← 你在这里
├── lua/
│   ├── init.lua       ← 完整初学者配置（窗口/缓冲区/选项/键位）
│   └── config/        ← 演示拆分后的模块结构
│       ├── options.lua    ← 所有 vim.opt 选项
│       ├── keymaps.lua    ← 所有 vim.keymap.set
│       └── autocmds.lua   ← 自动命令示例
└── exercises/
    └── README.md      ← 分屏/缓冲区/选项练习
```

- 完整配置（可独立加载）：[`lua/init.lua`](./lua/init.lua)
- 拆分模块（部署参考）：[`lua/config/`](./lua/config/)
- 练习题：[`exercises/README.md`](./exercises/README.md)

---

## 11. 知识检查清单

学完本章，你应该能回答：

- [ ] 窗口、缓冲区、文件三者的区别？`:q` 和 `:bd` 分别关什么？
- [ ] `Ctrl-w hjkl` 移动窗口，`Ctrl-w o` 和 `Ctrl-w c` 的区别？
- [ ] Neovim 配置文件在哪个路径？为什么推荐拆到 `lua/config/`？
- [ ] `vim.opt` `vim.o` `vim.wo` `vim.bo` 各自的作用域？
- [ ] 为什么本教程用 `vim.keymap.set` 而不是 `vim.api.nvim_set_keymap`？
- [ ] Vim 的「标签页」和浏览器的标签页有什么不同？

---

## Part 0 小结

恭喜！学完第01-03章，你已经掌握了 **Vim 生存技能**：

- **第01章**：模态编辑四种模式、基本移动、保存退出。
- **第02章**：删除复制替换、搜索替换、文本对象——Vim 效率的核心。
- **第03章**：窗口分屏、缓冲区管理、init.lua 配置——你的 Neovim 有了个性。

接下来 Part 1 我们要进入 LazyVim 的世界：
理解它的目录结构、装上 lazy.nvim 插件管理器，看看那个「一键安装的魔法」背后是什么。

## 下一步

Part 0 到这里收官。你已经能在 Neovim 里高效编辑（文本对象、搜索替换）、
同时看多个文件（分屏、缓冲区、标签页），还写出了自己的 `init.lua` 配置。
**裸 Neovim 你已经不怕了。**

但 LazyVim 打开就有补全、LSP、文件树——这些魔法是怎么来的？

- LazyVim 到底装了什么？它和原生 Neovim 有什么区别？
- `lua/config/` 和 `lua/plugins/` 这两个目录各自干什么？
- `:Lazy sync` 背后发生了什么？插件版本怎么锁定？

**第 04 章「LazyVim 入门」** 会带你从备份旧配置开始，正确安装 LazyVim，
看清它的目录结构，理解那个「一键安装的魔法」背后是什么。

> 💡 **Part 1 的三章节奏**：第 04 章（下一章）装好 LazyVim → 第 05 章理解配置目录 →
> 第 06 章学 lazy.nvim 的 spec 格式。三章节完，你就具备了读懂任何 LazyVim 配置的能力。

---

**下一章**：[第04章 · LazyVim 入门](../04-lazyvim-intro/) ——
安装 LazyVim，理解它和裸 Neovim 的关系，看懂它的默认配置在做什么。
