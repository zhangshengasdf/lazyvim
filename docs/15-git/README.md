# 第15章 Git 集成 — 行内标记、Hunk 操作与 LazyGit

> **代码写完了，diff 在哪？** 离开编辑器去终端跑 `git diff` 再回来改？
> 每次改几行代码都要切到 `git add -p` 逐块确认？
> 本章把 Git 工作流直接嵌入 Neovim——改了哪行、删了哪行、冲突在哪，
> 全部在编辑器里标出来，不用离开键盘。

---

## TL;DR

> **30 秒速读**：gitsigns 在行号栏标记改动行（绿/蓝/红），`<leader>ghs` 暂存 hunk，`<leader>gg` 打开 LazyGit 处理复杂 Git 操作。
> 
> **如果只记一件事**：hunk 级操作用 gitsigns（`<leader>gh`），文件/分支/rebase 操作用 LazyGit（`<leader>gg`），两者互补。

---

## 本章目标

学完本章，你将能够：

1. **读懂 gitsigns 行内标记**：新增行（绿）、修改行（蓝）、删除行（红）一眼识别
2. **用 `<leader>gh` 操作 hunk**：预览、暂存、还原单个代码块
3. **用 `<leader>gg` 打开 LazyGit**：全功能 Git GUI，不用离开 Neovim
4. **查看 git blame**：光标所在行是谁改的、什么时候改的
5. **写 gitsigns + lazygit 的 spec**：用正确的懒加载策略和 extend 模式

> ⚠️ **前置条件**：完成第 06 章（理解 lazy.nvim spec 格式和懒加载策略）。
> 假设你已掌握 Git 基本操作（commit、diff、branch），本章不教 Git 本身。

---

## 为什么需要 Git 集成

日常开发的 Git 工作流：

```
写代码 → 看 diff → 暂存改动 → 提交 → 推送
         ↑
     这一步最频繁，也最容易被打断
```

传统做法：开两个终端窗口，一个写代码一个跑 Git 命令。
每次看 diff 都要切窗口、复制文件名、找行号……来回切换消耗注意力。

LazyVim 的方案：**把 Git 信息直接叠加在编辑器里**。

| 场景 | 传统做法 | LazyVim 做法 |
|------|----------|--------------|
| 看改了哪行 | `git diff` 终端输出 | 行号栏彩色标记（绿/蓝/红） |
| 暂存某个改动 | `git add -p` 逐块确认 | `<leader>ghs` 一键暂存当前 hunk |
| 还原某个改动 | `git checkout -- file` | `<leader>ghr` 只还原当前 hunk |
| 看谁改的 | `git blame file` | `<leader>gb` 浮窗显示 blame |
| 复杂 Git 操作 | 切到终端用 Git CLI | `<leader>gg` 打开 LazyGit GUI |

---

## gitsigns：行内 Git 标记

gitsigns 是 LazyVim 默认集成的 Git 插件，负责两件事：

1. **行号栏标记**：哪些行新增、修改、删除，一目了然
2. **Hunk 操作**：对单个代码块（hunk）进行暂存、还原、预览

### 行号栏标记

打开任何 Git 仓库里的文件，行号栏会出现彩色符号：

```
行号栏    含义
─────────────────────────────
  绿色 +   新增行（git diff 的 + 行）
  蓝色 ~   修改行（git diff 的 ~ 行）
  红色 _   删除行（git diff 的 - 行，删除位置留标记）
  黄色 |   有未暂存的改动
```

实际效果像这样：

```
  42 │   function hello()
  43 │+    print("new line")      ← 绿色 +：这行是新加的
  44 │~    return result          ← 蓝色 ~：这行被改过
  45 │     local x = 1           ← 无标记：没改动
  46 │_                           ← 红色 _：下面原来有行被删了
  47 │     end
```

> 💡 行号栏标记是只读信息，不会修改你的代码。它只是 gitsigns 在渲染层叠加的视觉提示。

### Hunk 概念

**Hunk**（代码块）是 Git diff 里的一个连续改动区域。比如：

```diff
@@ -10,6 +10,8 @@ function process()
   local a = 1
+  local b = 2    ← ┐
+  local c = 3    ← ┘ 这两行是一个 hunk
   return a
 end
```

gitsigns 把每个 hunk 当作一个操作单元：你可以预览它、暂存它、还原它，
不需要像 `git add -p` 那样逐行确认。

---

## Hunk 操作快捷键

LazyVim 为 gitsigns 预设了一套 `<leader>gh`（git hunk）快捷键：

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `<leader>ghs` | 暂存 hunk（stage） | 把当前 hunk 加入暂存区 |
| `<leader>ghr` | 还原 hunk（reset） | 丢弃当前 hunk 的改动 |
| `<leader>ghp` | 预览 hunk（preview） | 浮窗显示当前 hunk 的 diff |
| `<leader>ghu` | 撤销暂存（unstage） | 把当前 hunk 从暂存区移除 |
| `<leader>ghS` | 暂存整个 buffer | 把当前文件所有改动加入暂存区 |
| `<leader>ghR` | 还原整个 buffer | 丢弃当前文件所有改动 |

> 💡 `s` = stage, `r` = reset, `p` = preview, `u` = unstage。记住首字母就行。

### 典型工作流

```
1. 写代码，gitsigns 自动在行号栏显示改动
2. 按 <leader>ghp 预览当前 hunk，确认改动正确
3. 按 <leader>ghs 暂存这个 hunk
4. 移到下一个 hunk，重复 2-3
5. 所有 hunk 暂存完后，按 <leader>gg 打开 LazyGit 提交
```

比 `git add -p` 快得多——你不需要离开编辑器，也不用回答 y/n 问题。

---

## git blame

想知道光标所在行是谁改的、什么时候改的？按 `<leader>gb`。

LazyVim 会弹出一个浮窗，显示当前行的 blame 信息：

```
abc1234 zhang 2025-06-01 fix: handle edge case in parser
```

包含：commit hash、作者、日期、commit message。

> 💡 `<leader>gb` 默认显示在浮窗里，不影响你的代码布局。
> 再按一次或按 `q` 关闭。

---

## LazyGit：全功能 Git GUI

有些 Git 操作比 hunk 操作更复杂：创建分支、解决冲突、交互式 rebase、cherry-pick……
这些用快捷键逐个映射不现实，LazyGit 来解决这个问题。

### 什么是 LazyGit

LazyGit 是一个终端里的 Git GUI——全键盘操作、界面清晰、速度快。
LazyVim 通过 `lazygit.nvim` 插件把 LazyGit 嵌入 Neovim 的浮动终端。

按 `<leader>gg` 打开：

```
┌─ LazyGit ──────────────────────────────────────┐
│ Status    │ Branches │ Files │ Commits │ Stash  │
│           │          │       │         │        │
│ main      │          │ mod.lua│ abc1 fix│        │
│ * feature │          │ new.lua│ def2 add│        │
│           │          │       │         │        │
│─────────────────────────────────────────────────│
│ m: commit  s: stage  d: diff  q: quit           │
└─────────────────────────────────────────────────┘
```

在 LazyGit 里，你可以：

- **`s`** 暂存文件/行
- **`c`** 提交
- **`P`** 推送
- **`p`** 拉取
- **`space`** 切换选中状态
- **`d`** 查看 diff
- **`q`** 退出

> 💡 LazyGit 有自己的快捷键体系，不在 which-key 里显示。
> 按 `?` 可以查看 LazyGit 内置的帮助。

### 什么时候用 LazyGit

| 场景 | 用 gitsigns | 用 LazyGit |
|------|-------------|------------|
| 暂存单个 hunk | `<leader>ghs` | 不需要 |
| 查看某个 hunk 的 diff | `<leader>ghp` | 不需要 |
| 提交暂存的改动 | 需要退出 | `<leader>gg` → `c` |
| 创建/切换分支 | 不支持 | `<leader>gg` → branches 面板 |
| 交互式 rebase | 不支持 | `<leader>gg` → commits 面板 |
| 解决合并冲突 | 不支持 | `<leader>gg` → files 面板 |
| 查看完整提交历史 | 不支持 | `<leader>gg` → commits 面板 |

**简单规则**：hunk 级操作用 gitsigns，文件/分支/rebase 操作用 LazyGit。

---

## spec 格式详解

### gitsigns spec

gitsigns 在 LazyVim 中默认已配置，你通常只需要 **extend** 它，不需要从零写。

核心结构：

```lua
{
  "lewis6991/gitsigns.nvim",
  event = "BufReadPost",  -- 打开文件后加载（不是 keys 或 cmd）
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
    },
    -- 更多选项...
  },
}
```

**为什么用 `event = "BufReadPost"`？**

gitsigns 需要在打开文件时就显示行号栏标记。如果用 `keys` 懒加载，
不按快捷键就看不到标记，失去了"一目了然"的意义。

### lazygit.nvim spec

```lua
{
  "kdheepak/lazygit.nvim",
  cmd = { "LazyGit", "LazyGitCurrentFile", "LazyGitFilter" },
  keys = {
    { "<leader>gg", "<cmd>LazyGit<CR>", desc = "打开 LazyGit" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
```

**为什么用 `cmd` + `keys` 双懒加载？**

- `cmd = "LazyGit"`：运行 `:LazyGit` 命令时加载
- `keys = { "<leader>gg" }`：按快捷键时加载
- 两种触发方式，满足任一就加载——LazyGit 不常用，没必要一启动就加载

### extend 模式示例

如果你想给 gitsigns 添加自定义配置，用 extend 模式：

```lua
-- lua/plugins/git.lua
return {
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      -- 在 LazyVim 默认配置基础上追加
      opts.on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        -- 自定义快捷键...
      end
    end,
  },
}
```

> ⚠️ 不要直接写 `opts = { signs = {...} }` 覆盖默认的 signs 配置。
> 如果 LazyVim 有默认值，table 赋值会整体替换。用 `opts = function` extend 更安全。

---

## 反模式（什么不该做）

### ❌ 用 `lazy = false` 加载 gitsigns

```lua
-- ❌ 坏：启动时就加载，拖慢启动
{ "lewis6991/gitsigns.nvim", lazy = false }

-- ✅ 正确：打开文件时才加载
{ "lewis6991/gitsigns.nvim", event = "BufReadPost" }
```

gitsigns 需要在 `BufReadPost` 事件触发时加载，而不是 Neovim 启动时。
用 `lazy = false` 会让它参与启动流程，白白增加 10-20ms。

### ❌ 不给 `<leader>gg` 写 desc

```lua
-- ❌ 坏：which-key 里只显示 <leader>gg，不知道干什么
keys = { "<leader>gg" }

-- ✅ 正确：带 desc，which-key 显示"打开 LazyGit"
keys = {
  { "<leader>gg", "<cmd>LazyGit<CR>", desc = "打开 LazyGit" },
}
```

### ❌ 用 cmd 加载 gitsigns

```lua
-- ❌ 坏：没有 :Gitsigns 命令可用，cmd 永远不会触发
{ "lewis6991/gitsigns.nvim", cmd = "Gitsigns" }

-- ✅ 正确：用 event 加载
{ "lewis6991/gitsigns.nvim", event = "BufReadPost" }
```

gitsigns 是被动显示的插件（行号栏标记），没有用户主动触发的命令。
用 `cmd` 懒加载永远加载不了，标记不会出现。

### ❌ 覆盖 gitsigns 默认 signs 配置

```lua
-- ❌ 坏：直接覆盖，丢失默认配置
opts = {
  signs = {
    add = { text = "+" },  -- 只设了 add，其他全丢了
  },
}

-- ✅ 正确：用 function extend
opts = function(_, opts)
  opts.signs = vim.tbl_deep_extend("force", opts.signs or {}, {
    add = { text = "+" },
  })
end
```

---

## 常见错误

> 概念懂了，实际操作还是会踩坑。

| 错误 | 症状 | 解决 |
|------|------|------|
| 打开 Git 仓库文件但行号栏无标记 | 没有绿色/蓝色/红色标记 | 检查 gitsigns 是否加载（`:Lazy` 看状态），确认文件在 Git 仓库内 |
| `<leader>gg` 打不开 LazyGit | 按快捷键没反应或报错 | 确认 `lazygit` 已安装（`which lazygit`），`:MasonInstall` 不管它，需系统安装 |
| `opts = { signs = {...} }` 覆盖了默认配置 | 只有 add 标记，change/delete 标记丢失 | 改用 `opts = function(_, opts) vim.tbl_deep_extend(...)` extend |
| gitsigns 用 `cmd` 懒加载 | 插件永远不加载，行号栏无标记 | gitsigns 没有用户命令，必须用 `event = "BufReadPost"` 加载 |

---

## 运行验证

本章的 Lua 文件可以独立验证语法：

```bash
cd lazyvim/15-git

# 验证 init.lua（pcall guard，没装 lazy.nvim 也能跑）
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
# 预期：退出码 0，输出 [demo] 消息

# 验证 git.lua（return table，语法检查）
nvim --headless -u NONE -c "luafile lua/plugins/git.lua" -c 'qa!'
# 预期：退出码 0
```

> 💡 **真实环境验证**：复制 `lua/plugins/git.lua` 到 `~/.config/nvim/lua/plugins/`，
> 重启 Neovim，运行 `:Lazy` 查看 gitsigns 和 lazygit 的加载状态。
> 打开一个 Git 仓库里的文件，行号栏应该出现绿色/蓝色标记。

---

## 下一步

本章你学会了 Git 集成的两种工具：

- **gitsigns**：行内标记 + hunk 操作（日常微操）
- **LazyGit**：全功能 Git GUI（分支、rebase、冲突解决）

下一章 **第 16 章「调试器 DAP」** 会教你另一个开发必备技能：

- DAP 协议是什么、为什么需要它
- nvim-dap 的断点、单步、变量查看
- dap-ui 的可视化调试面板
- Python (debugpy) 和 TypeScript (node-debugger) 的配置示例

> 💡 **本章核心**：gitsigns 用 `event = "BufReadPost"` 懒加载（打开文件就显示标记），
> lazygit 用 `cmd` + `keys` 双懒加载（不常用，按需加载）。
> 扩展 gitsigns 配置时，用 `opts = function(_, opts) ... end` extend，不要 overwrite。

---

## 代码

- [`lua/init.lua`](./lua/init.lua) — pcall guard 教学示例
- [`lua/plugins/git.lua`](./lua/plugins/git.lua) — gitsigns + lazygit spec
- [`exercises/`](./exercises/README.md) — 4 道练习题

**上一章**：[14-formatting](../14-formatting/)（代码格式化）
**下一章**：[16-dap](../16-dap/)（调试器 DAP）
