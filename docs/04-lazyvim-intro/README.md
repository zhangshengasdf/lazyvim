# 第04章 LazyVim 简介与安装 — 从"一键黑盒"到"我知道它在干什么"

> **装上 Neovim 就有补全、LSP、文件树**——这是 LazyVim 给你的礼物，也是它给你的陷阱。
> 本章不教你"一键起飞"，而是带你从备份旧配置开始，看清 LazyVim 到底装了什么、
> 为什么能用、出错时去哪里查。**先看清骨架，再享受便利**——这是 Part 1 的开端。

---

## TL;DR

> **30 秒速读**：LazyVim 是 Neovim 配置发行版，装完就有 LSP 补全、Telescope 搜索、文件树；配置写在 `lua/config/`（选项）和 `lua/plugins/`（插件 spec）。
> 
> **如果只记一件事**：装之前先 `mv ~/.config/nvim{,.bak}` 备份旧配置，不备份就装会出大问题。

## 本章目标

学完本章，你将能够：

1. **说清 LazyVim 是什么**：它和原生 Neovim、AstroNvim、NvChad、Kickstart.nvim 各有什么区别
2. **正确安装 LazyVim**：备份旧配置 → clone starter → 首次启动 → `:LazyHealth` 检查
3. **读懂目录结构**：`init.lua`、`lua/config/`、`lua/plugins/` 各自的角色
4. **理解第一次 `:Lazy sync` 发生了什么**：插件安装、锁定文件、健康检查
5. **避开新手三大坑**：直接覆盖默认配置、把 lazy.nvim 当普通插件装、不备份就装

> ⚠️ **前置条件**：完成 Part 0（01-03 章），会用 `hjkl`、`i`、`:wq`、`:help` 这些基本操作。
> 如果你还没装 Neovim，先回 [总导读](../README.md) 的「环境准备」装好。

---

## 什么是 LazyVim

### 一句话定义

**LazyVim 是一个 Neovim 配置发行版（distribution）**——它把 lazy.nvim（插件管理器）
和一套精选的 Neovim 插件组合在一起，用合理的默认值打包成一个开箱即用的整体。

你可以把它理解成：
- **lazy.nvim** = 引擎（管理插件的下载、加载、更新）
- **LazyVim** = 一辆装好引擎的整车（引擎 + 精选配件 + 调好的参数）

### LazyVim vs 原生 Neovim vs 其他发行版

新手最常问的问题：**我该用哪个？** 下表给你一个清晰的对照：

| 发行版 | 本质 | 上手难度 | 定制度 | 默认插件数 | 维护者 | 适合谁 |
|--------|------|----------|--------|------------|--------|--------|
| **原生 Neovim** | 只有 `init.lua` 入口 | 高（从零配置） | 极高 | 0 | Neovim 官方 | 想完全掌控、不介意从零开始的人 |
| **LazyVim** | lazy.nvim + 精选插件集 | 中（开箱即用 + 可定制） | 高 | ~50（按需懒加载） | folke（社区核心贡献者） | 想开箱即用但保留深度定制能力的人 |
| **AstroNvim** | 类似 LazyVim，抽象层更厚 | 中 | 中 | ~40 | AstroNvim 社区 | 喜欢统一 UI、不想碰底层的人 |
| **NvChad** | 追求轻量 + 美观 | 中低 | 中 | ~30 | NvChad 社区 | 追求颜值、配置文件简洁的人 |
| **Kickstart.nvim** | 单文件 `init.lua` 教学 | 低（就是一个起点） | 极高（自己加） | ~10 | TJ DeVries（Neovim 核心贡献者） | 想理解每一行配置、自己从零搭的人 |

**关键区别**：

- **LazyVim vs 原生 Neovim**：原生 Neovim 打开后什么都没有（黑底白字、无补全、无文件树）；
  LazyVim 打开后就有 LSP 补全、文件树、模糊搜索、Git 集成。
- **LazyVim vs Kickstart.nvim**：Kickstart 是"起跑线"——一个单文件，教你每一行干什么，
  但你之后得自己加所有插件。LazyVim 是"成品"——精选插件已经装好，你只要定制。
- **LazyVim vs AstroNvim/NvChad**：功能类似，差别在抽象层厚薄和社区生态。
  LazyVim 由 folke（也是 lazy.nvim、which-key、tokyonight 等核心插件的作者）维护，
  生态最完整、文档最全、社区最活跃。

> 💡 **本教程为什么选 LazyVim**？因为它的"开箱即用 + 可深度定制"最契合本教程的目标：
  先享受便利（Part 2-4 用它自带的插件），再理解原理（Part 5 拆解它的每一层）。

---

## 为什么选 LazyVim

如果你还在犹豫，这四个理由是 LazyVim 的核心优势：

### 1. 开箱即用

装完 LazyVim，你立刻拥有：
- **LSP 代码智能**：补全、跳转定义、悬停文档、重命名（第 12-13 章详解）
- **Treesitter 语法高亮**：比正则高亮精准得多（第 11 章详解）
- **Telescope 模糊搜索**：找文件、搜内容、跳 buffer（第 9 章详解）
- **Neo-tree 文件浏览器**：侧边栏目录树（第 10 章详解）
- **which-key 快捷键提示**：按 Leader 键弹出菜单（第 8 章详解）
- **Git 集成**：gitsigns 显示改动、lazygit 一键打开（第 15 章详解）

不用你一个个配置——LazyVim 的默认值已经是社区公认的最佳实践。

### 2. 社区活跃

LazyVim 的 GitHub star 数长期位于 Neovim 发行版前列。这意味着：
- 遇到问题搜得到答案（GitHub Issues、Reddit、Discord）
- 插件 API 变动时，folke 会及时更新 LazyVim 适配
- 新插件出现时，社区会写 LazyVim spec 适配

### 3. 模块化（Extras 机制）

LazyVim 把可选功能拆成 **Extras**（第 19 章详解）：
- `lazyvim.plugins.extras.lang.typescript` — TypeScript 语言支持
- `lazyvim.plugins.extras.lang.python` — Python 语言支持
- `lazyvim.plugins.extras.coding.copilot` — GitHub Copilot 集成
- `lazyvim.plugins.extras.dap.core` — DAP 调试器

不用就别装——一行 `:LazyExtras` 勾选即可，不会拖慢启动。

### 4. folke 维护

LazyVim 的作者 **folke** 同时维护着 lazy.nvim、which-key.nvim、tokyonight.nvim、
todo-comments.nvim 等 Neovim 生态的核心插件。这意味着：
- LazyVim 内置的插件都是"原厂调校"，兼容性最好
- lazy.nvim 的特性 LazyVim 第一时间支持
- folke 对 Neovim API 的理解极深，配置代码质量高

> ⚠️ **诚实提醒**：LazyVim 不是银弹。如果你完全不想学 Vim 基本功、只想用鼠标点菜单，
> VS Code 可能更适合你。LazyVim 的价值在于"让你高效地用 Vim 方式编辑代码"——
> 前提是你愿意学 Vim。

---

## 安装步骤（手把手）

### 步骤 1：备份旧配置（不要跳过！）

如果你之前装过 Neovim 配置，**先备份**，否则 LazyVim 会和你旧配置打架：

```bash
# Linux / macOS
mv ~/.config/nvim{,.bak}        # 备份配置目录
mv ~/.local/share/nvim{,.bak}   # 备份数据目录（swap、undo 等）
mv ~/.local/state/nvim{,.bak}   # 备份状态目录（Neovim 0.8+）
mv ~/.cache/nvim{,.bak}         # 备份缓存目录

# 如果某个目录不存在，mv 会报错，忽略即可
```

> ❌ **反模式**：不备份直接装。后果：旧配置的插件和新配置冲突，启动时报一堆错，
> 你根本不知道是谁的锅。

### 步骤 2：clone LazyVim starter

LazyVim 官方提供了 **starter 仓库**——一个最小可用的起点：

```bash
# Linux / macOS
git clone https://github.com/LazyVim/starter ~/.config/nvim

# 装完后可以删掉 .git，建立你自己的版本控制
rm -rf ~/.config/nvim/.git
```

starter 仓库的内容很简单（下一节详解），它不是一个"成品"——它是你定制的基础。

> 💡 **为什么用 starter 而不是直接 clone LazyVim 主仓库**？
> LazyVim 主仓库是开发用的，包含完整源码和测试。starter 是用户用的，只有几个文件：
> `init.lua`、`lua/config/`、`lua/plugins/`、`.gitignore`、`README.md`。

### 步骤 3：首次启动

```bash
nvim
```

第一次启动时会发生这些事（LazyVim 在幕后自动完成）：

1. **lazy.nvim bootstrap**：`init.lua` 检测到 lazy.nvim 没装，自动从 GitHub clone
2. **插件下载**：lazy.nvim 读取 LazyVim 的插件列表，逐个 clone 到 `~/.local/share/nvim/lazy/`
3. **插件加载**：按懒加载策略加载（很多插件首次启动时不会全加载）
4. **Treesitter 解析器安装**：根据你打开的文件类型，安装对应的语法解析器

**首次启动会比较慢**（要下载几十个插件），耐心等。后续启动会快得多（懒加载的威力）。

> ⚠️ **如果首次启动报错**：最常见原因是网络问题（GitHub 访问慢）。
> 国内用户可以设置 git 代理或用 GitHub 镜像。

### 步骤 4：健康检查

装完后，**立刻运行健康检查**：

```vim
:LazyHealth
```

这会运行 Neovim 自带的 `:checkhealth`，并额外检查 LazyVim 的配置是否正确。
你会看到类似这样的输出：

```
lazy: require("lazy.health").check
==============================================================================
  - OK {lazy.nvim} version 11.x.x
  - OK {git} `git` version 2.x.x
  - OK {nvim} version 0.10+

LazyVim: require("lazyvim").health()
==============================================================================
  - OK {LazyVim} version 11.x.x
  - OK {vim.g} `vim.g.lazyvim_*` are valid
  - OK {vim.opt} `vim.opt.*` are valid
```

**看到 `OK` 就没问题，看到 `ERROR` 或 `WARNING` 就按提示修**。常见警告：
- 缺少外部工具（`ripgrep`、`fd`、`lazygit`）→ 用包管理器装
- Nerd Font 没装 → 图标显示成方块

### 步骤 5：第一次 `:Lazy sync`

```vim
:Lazy sync
```

`:Lazy sync` = `:Lazy install` + `:Lazy clean` + `:Lazy update` 三合一：

| 子命令 | 干什么 |
|--------|--------|
| `install` | 安装 `lazy-lock.json` 里锁定但本地没装的插件 |
| `clean`   | 删除本地有但配置里没引用的插件 |
| `update`  | 更新所有插件到最新版本（更新 `lazy-lock.json`） |

第一次 `:Lazy sync` 后，你的 `lazy-lock.json` 会被更新（如果 starter 带了锁定文件，它会按锁定版本装）。

---

## 目录结构总览

装完 LazyVim starter，你的 `~/.config/nvim/` 长这样：

```
~/.config/nvim/
├── init.lua                  ← 入口文件（lazy.nvim bootstrap + LazyVim setup）
├── lua/
│   ├── config/               ← 你的个人配置（LazyVim 自动 source）
│   │   ├── options.lua       ← vim 选项（vim.opt.X = value）
│   │   ├── keymaps.lua       ← 快捷键（vim.keymap.set）
│   │   ├── autocmds.lua      ← 自动命令（vim.api.nvim_create_autocmd）
│   │   └── lazy.lua          ← lazy.nvim 的 setup 配置（可选）
│   └── plugins/              ← 你的插件配置（LazyVim 自动 source）
│       └── example.lua       ← 每个 .lua 返回一个 spec table
├── lazy-lock.json            ← 插件版本锁定文件
├── stylua.toml               ← Lua 代码格式化配置（可选）
└── .gitignore
```

### `init.lua` 的角色

`init.lua` 是 Neovim 的**唯一入口**——Neovim 启动时只会读这一个文件。
它做两件事：
1. **bootstrap lazy.nvim**：检测 lazy.nvim 没装就 clone，然后 `vim.opt.rtp:prepend`
2. **调用 `require("lazy").setup`**：告诉 lazy.nvim 去加载 LazyVim 的默认插件 + 你的插件

> 💡 **关键**：`init.lua` 里**不写业务配置**（options、keymaps、autocmds）。
> 业务配置放在 `lua/config/` 里，LazyVim 会自动 source。下一章详解。

### `lua/config/` vs `lua/plugins/`

这两个目录的区别是新手最容易混淆的点：

| 目录 | 放什么 | 每个文件的内容 | LazyVim 如何处理 |
|------|--------|----------------|------------------|
| `lua/config/` | 你的个人配置 | 直接执行 Lua 语句（`vim.opt.X = ...`） | 启动时**全部 source**（像 `:source`） |
| `lua/plugins/` | 插件 spec | `return { "repo/name", opts = {...} }` | 收集成 spec 列表，交给 lazy.nvim 处理 |

**一句话区分**：
- 想改 Neovim 本身的设置（行号、缩进、快捷键）→ 写到 `lua/config/`
- 想装/改一个插件 → 写到 `lua/plugins/`

> ⚠️ **反模式**：在 `lua/plugins/` 里写 `vim.opt.number = true`。
> 这个目录的文件**必须返回一个 table**，写裸语句会报错。
> 改 Neovim 选项请放 `lua/config/options.lua`。

---

## 第一次 `:Lazy sync` 体验（看幕后发生了什么）

运行 `:Lazy sync` 时，打开 `:Lazy log` 你能看到完整的过程。这里用 ASCII 图概括：

```
:Lazy sync 触发
       │
       ▼
┌─────────────────────────────────┐
│ 1. 读取 spec                    │  ← LazyVim 默认 spec + 你的 lua/plugins/*.lua
│    （所有插件定义）              │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│ 2. install: 对比 lazy-lock.json │  ← 锁定文件说装 v1.2，本地没有 → clone v1.2
│    与本地实际安装，补齐缺失      │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│ 3. clean: 本地有但 spec 没引用  │  ← 你删了某个插件 spec，本地副本会被删
│    的插件，删除                  │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│ 4. update: 拉 spec 引用的插件   │  ← git pull，更新到最新 commit
│    到最新版本                    │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│ 5. 写入 lazy-lock.json          │  ← 记录每个插件的 commit hash
│    （版本锁定文件）              │
└─────────────────────────────────┘
```

**`lazy-lock.json` 的作用**（第 5、6 章详解）：它是"插件版本快照"，保证你和队友、
你的多台机器上跑的是**完全相同**的插件版本。换机器时只要把 `lazy-lock.json` 同步过去，
`:Lazy sync` 就能还原出一样的环境。

---

## 反模式（什么不该做）

### ❌ 不备份旧配置直接装

```bash
# 坏：直接 clone，旧配置被覆盖（或共存导致冲突）
git clone https://github.com/LazyVim/starter ~/.config/nvim

# 正确：先备份
mv ~/.config/nvim{,.bak}
git clone https://github.com/LazyVim/starter ~/.config/nvim
```

**后果**：旧配置的 `init.lua` 残留，启动时加载顺序混乱，报莫名其妙的错。

### ❌ 把 lazy.nvim 当普通插件手动 clone

```bash
# 坏：手动 clone lazy.nvim，绕过 bootstrap 逻辑
git clone https://github.com/folke/lazy.nvim ~/.local/share/nvim/lazy/lazy.nvim

# 正确：让 init.lua 的 bootstrap 逻辑自动管理
```

**后果**：lazy.nvim 升级时你不会跟着更新，容易触发兼容性问题。
正确做法是用 starter 的 `init.lua`，它的 bootstrap 会检查并自动 clone。

### ❌ 在 `lua/plugins/` 写裸语句

```lua
-- ❌ 坏：lua/plugins/options.lua（放错地方了）
vim.opt.number = true
vim.keymap.set("n", "<leader>w", ":w<CR>")

-- 正确：这些应该放 lua/config/options.lua 和 lua/config/keymaps.lua
```

**后果**：`lua/plugins/` 的文件被 lazy.nvim 当 spec 处理，不返回 table 会报错。
即使你加 `return {}` 绕过，`vim.opt` 也会在插件加载阶段执行（时机不对）。

### ❌ 装完不改默认配置就以为"学会了"

LazyVim 的默认值很好，但**不学原理就改配置** = 等着踩坑。

> ✅ **正确姿势**：装完先用一个月（熟悉默认行为），再按本教程第 5-6 章学配置目录，
> 第 7-20 章逐个理解插件。**急不来。**

---

## 常见错误

> 概念懂了，实际操作还是会踩坑。这些是 Vim/Neovim 新手最常犯的错误。

| 错误 | 症状 | 解决 |
|------|------|------|
| 不备份旧配置直接装 LazyVim | 旧插件和新插件冲突，启动报一堆错 | 先 `mv ~/.config/nvim{,.bak}` 再装，四个目录都要备份 |
| 在 `lua/plugins/` 里写 `vim.opt.number = true` | 启动报错，提示 spec 不是 table | 选项放 `lua/config/options.lua`，`lua/plugins/` 必须 `return { spec }` |
| 首次启动卡住不动或报网络错误 | 插件下载超时，界面卡在 loading | 设 git 代理或用 GitHub 镜像，耐心等几分钟 |
| 手动 clone lazy.nvim 到 lazy/ 目录 | lazy.nvim 升级时不跟着更新，版本不兼容 | 让 `init.lua` 的 bootstrap 逻辑自动管理，不要手动 clone |
| 装完 LazyVim 改了配置但没生效 | `:Lazy sync` 后配置还是默认的 | 检查是否改对了目录：选项放 `config/`，插件 spec 放 `plugins/` |

---

## 运行验证

本章没有要写的配置——重点是理解安装过程。但你可以验证 starter 的 `init.lua` 能被 Neovim 解析：

```bash
# 进入本章目录
cd lazyvim/04-lazyvim-intro

# 验证 init.lua 语法（注意：init.lua 会尝试 bootstrap lazy.nvim，
# 在没有网络/lazy.nvim 没装时会优雅降级，但语法本身必须正确）
nvim --headless -u lua/init.lua -c 'qa!'

# 如果上面的命令报错（因为真的会尝试 bootstrap），用这个只检查语法：
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
```

预期：退出码 0，无错误输出（或只有 lazy.nvim 没装的网络警告，可忽略）。

---

## 下一步

你已经装好了 LazyVim，知道它"装了什么"。但**怎么改**还没讲——

- `lua/config/options.lua` 怎么写？
- `lua/config/keymaps.lua` 怎么用 `vim.keymap.set`？
- `lua/plugins/example.lua` 的 spec table 长什么样？
- LazyVim 如何"自动 source"这两个目录？
- 你的 spec 和 LazyVim 的默认 spec 怎么 merge？

**第 05 章「配置目录架构」** 会逐个文件拆解，并用 ASCII 图展示加载顺序。

> 💡 **Part 1 的三章节奏**：第 04 章（本章）装好 LazyVim → 第 05 章理解配置目录 →
> 第 06 章学 lazy.nvim 的 spec 格式。三章节完，你就具备了读懂任何 LazyVim 配置的能力。

---

## 代码

- [`lua/init.lua`](./lua/init.lua) — LazyVim starter 的 `init.lua` 结构（教学示例）
- [`exercises/`](./exercises/README.md) — 4 道练习题（对比发行版、理解目录、健康检查）

**上一章**：[03-neovim-basics](../03-neovim-basics/)（Part 0 收尾）
**下一章**：[05-config-architecture](../05-config-architecture/)（配置目录架构）
