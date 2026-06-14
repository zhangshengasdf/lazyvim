# 第08章 which-key 探索式学习 — 不用背快捷键的秘诀

> **which-key 是你的快捷键备忘单**——按下 `<Space>` 等 300ms，所有快捷键一览无余。
> 本章教你用 which-key 的弹出菜单**探索式学习**快捷键，而不是死记硬背。
> 还会教你用 `wk.add()` 自定义分组标签，让菜单更清晰。
> 学完本章，你再也不需要查文档找快捷键——按一下 Leader 键就知道该按什么。

---

## 本章目标

学完本章，你将能够：

1. **理解 which-key 的弹出机制**：按下前缀键后何时弹出、显示什么
2. **掌握探索式工作流**：按前缀键 → 看菜单 → 选操作，边用边学
3. **用 `wk.add()` 注册自定义分组**：给你的快捷键加中文标签
4. **理解 which-key 与 `vim.keymap.set` 的关系**：desc 字段是桥梁
5. **知道 which-key 的配置选项**：延迟时间、图标、触发条件

> ⚠️ **前置条件**：完成第 07 章（理解 Leader 键体系和 `vim.keymap.set`）。
> 本章是第 07 章的直接延续——Leader 键是"调度中心"，which-key 是"菜单显示屏"。

---

## which-key 是什么

### 问题：快捷键太多记不住

LazyVim 内置了 100+ 个快捷键。就算你理解了第 07 章的前缀分类逻辑，
也不可能记住每个 `<leader>f` 后面跟什么字母。

### 解决方案：按下前缀键，弹出菜单

which-key 的核心功能极其简单：

```
按下 <Space>        →  等 300ms  →  弹出菜单，显示所有 <Space>* 快捷键
                                │
                                ▼
                         ┌─────────────────────────┐
                         │  f  查找  →              │
                         │  s  搜索  →              │
                         │  b  buffer               │
                         │  g  git     →            │
                         │  c  代码    →            │
                         │  w  保存文件              │
                         │  q  退出                  │
                         └─────────────────────────┘
                                │
                         按 f（进入"查找"子菜单）
                                │
                                ▼
                         ┌─────────────────────────┐
                         │  f  查找文件              │
                         │  g  实时 grep             │
                         │  b  buffer 列表           │
                         │  r  最近文件              │
                         │  h  帮助标签              │
                         └─────────────────────────┘
```

**你不需要背任何快捷键**——只需要知道大概的分类（第 07 章学的），
然后用 which-key 菜单"导航"到目标操作。

---

## 弹出机制详解

### 触发条件

which-key 在以下条件下弹出：

1. **按下前缀键**（如 `<Space>`、`g`、`z`、`<C-w>`）后等待 `delay` 毫秒
2. **延迟时间内没有按下一个键**——如果快速连续按键（`<Space>ff`），菜单不会弹出
3. **按键有后续映射**——如果 `<Space>` 本身绑定了完整操作（不是前缀），直接执行，不弹菜单

### 延迟时间（delay）

```lua
-- which-key 默认延迟 300ms
-- 你打字快的话，300ms 内已经按完了完整快捷键，菜单不会弹出
-- 只有你"停下来想"的时候，菜单才会出现——正好是你需要它的时候
delay = 300
```

| 延迟 | 体验 |
|------|------|
| 100ms | 太快，正常打字也会弹菜单（烦人） |
| 300ms | 推荐，快速按键不会触发，停下来想时刚好弹出 |
| 500ms | 太慢，等菜单出来已经不耐烦了 |
| 0 | 立即弹出（不推荐，干扰正常操作） |

### 哪些键会触发 which-key

which-key 不只监听 `<Space>`。它会监听**所有有后续映射的键**：

| 前缀键 | 显示内容 |
|--------|----------|
| `<Space>` | 所有 Leader 快捷键（LazyVim 的核心） |
| `g` | Vim 的 "go to" 前缀（gd=定义，gr=引用，等等） |
| `z` | Vim 的折叠/拼写前缀 |
| `<C-w>` | Vim 的窗口管理前缀 |
| `"` | 寄存器选择 |
| `'` 和 `` ` `` | mark 跳转 |

> 💡 **按 `g` 也能弹菜单**：如果你想看所有 `g` 开头的操作（gd、gr、gi...），
> 按下 `g` 等 300ms，which-key 会列出所有 `g*` 映射。

---

## 探索式工作流

### 核心理念：边用边学

传统 Vim 学习：查文档 → 背快捷键 → 用 → 忘记 → 再查文档。

which-key 学习：按前缀键 → 看菜单 → 选操作 → 重复几次就记住了。

```
传统方式：  文档 → 背诵 → 使用 → 遗忘 → 文档（循环）
which-key：使用 → 菜单 → 选择 → 使用 → 自然记住（正循环）
```

### 实际操作示例

**场景：你想搜索文件，但忘了按什么**

1. 按 `<Space>`（Leader 键），等 300ms
2. which-key 弹出菜单，看到 `f  查找 →`
3. 按 `f`，进入"查找"子菜单
4. 看到 `f  查找文件`，按 `f` 执行

用了 3-4 次后，你自然记住了 `<Space>ff` = 查找文件。

**场景：你想看 Git 状态，不确定前缀**

1. 按 `<Space>`，看菜单
2. 看到 `g  git →`，按 `g`
3. 看到 `s  Git 状态`，按 `s`

**场景：你想关闭当前 buffer**

1. 按 `<Space>`，看菜单
2. 看到 `b  buffer`，按 `b`
3. 看到 `d  关闭当前`，按 `d`

---

## `wk.add()` — 自定义分组标签

### 为什么需要分组标签

which-key 自动拾取所有带 `desc` 的快捷键，但它们默认是**平铺列表**，
没有分组信息。你需要用 `wk.add()` 给前缀加"目录名"。

### 没有分组 vs 有分组

```
没有分组（平铺）：                 有分组（结构化）：
┌────────────────────┐            ┌────────────────────┐
│ ff  查找文件        │            │ f  查找 →          │
│ fg  实时 grep       │            │ s  搜索 →          │
│ fb  buffer 列表     │            │ b  buffer           │
│ sw  搜索当前词      │            │ g  git →            │
│ sk  搜索快捷键      │            │ c  代码 →           │
│ bb  切换到上一个    │            │ w  保存文件          │
│ bd  关闭当前        │            │ q  退出              │
│ gg  LazyGit         │            └────────────────────┘
│ ...（30+ 条混在一起）│
└────────────────────┘
```

### `wk.add()` 语法

```lua
local wk = require("which-key")

wk.add({
  -- 分组标签（没有 rhs，只有 group）
  { "<leader>f", group = "查找" },
  { "<leader>g", group = "git" },

  -- 快捷键（有 rhs 和 desc）
  { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件" },
  { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" },
})
```

### 两种条目类型

| 类型 | 有 rhs | 有 desc | 有 group | 作用 |
|------|--------|---------|----------|------|
| 分组标签 | ❌ | ❌ | ✅ | 给前缀加目录名，不注册快捷键 |
| 快捷键 | ✅ | ✅ | ❌ | 注册快捷键 + 描述（等价于 `vim.keymap.set`） |

### `wk.add()` vs `vim.keymap.set`

`wk.add()` 注册快捷键时**等价于** `vim.keymap.set`，但语法更紧凑：

```lua
-- 用 vim.keymap.set（传统方式，每个一行）
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "查找文件" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "实时 grep" })

-- 用 wk.add()（which-key 方式，批量注册）
wk.add({
  { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件" },
  { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "实时 grep" },
})
```

> 💡 **推荐**：用 `vim.keymap.set` 注册快捷键（更通用，不依赖 which-key），
> 用 `wk.add()` 只注册分组标签。这样即使 which-key 没装，快捷键也能用。

---

## which-key 配置选项

### setup 参数

```lua
require("which-key").setup({
  -- 延迟弹出时间（毫秒）
  delay = 300,

  -- 键位提示图标
  icons = {
    breadcrumb = "»",   -- 子菜单路径分隔符（如 "查找 » 查找文件"）
    separator = "→",    -- 按键和描述之间的分隔符（如 "ff → 查找文件"）
    group = "+",        -- 分组图标的前缀（如 "+git"）
  },

  -- 触发 which-key 的键模式
  triggers = {
    { "<auto>", mode = "nixsotc" },
  },

  -- 过滤函数：哪些映射显示在菜单里
  filter = function(mapping)
    return mapping.desc and mapping.desc ~= ""
  end,
})
```

### 常用配置覆盖

```lua
-- 改延迟为 200ms（更快弹出）
require("which-key").setup({ delay = 200 })

-- 改分隔符为箭头
require("which-key").setup({
  icons = { separator = "=>" },
})

-- 只在 Normal 和 Visual 模式触发
require("which-key").setup({
  triggers = {
    { "<leader>", mode = { "n", "v" } },
  },
})
```

---

## which-key 与 `desc` 字段的关系

### 核心关系

```
vim.keymap.set("n", "<leader>ff", "...", { desc = "查找文件" })
                                              │
                                              ▼
                                    which-key 自动拾取 desc
                                              │
                                              ▼
                                    菜单显示：ff → 查找文件
```

**没有 desc 的快捷键不会出现在 which-key 菜单里**（默认过滤行为）。

### 哪些来源的 desc 会被拾取

| 来源 | 是否被 which-key 拾取 | 说明 |
|------|----------------------|------|
| `vim.keymap.set` 的 `desc` 字段 | ✅ | 最常见来源 |
| lazy.nvim spec 的 `keys` table 的 `desc` 字段 | ✅ | 插件的懒加载快捷键 |
| `wk.add()` 的 `desc` 字段 | ✅ | which-key 专用注册 |
| Vim 原生映射（无 desc） | ❌ | 如 `dd`（删除行）不会出现在菜单 |
| 没有 desc 的 `vim.keymap.set` | ❌ | 默认被过滤掉 |

> 💡 **这就是为什么第 07 章反复强调"必须带 desc"**——不带 desc 的快捷键
> 在 which-key 里是"隐形"的，你永远不会发现它们。

---

## 反模式（什么不该做）

### ❌ 设 `delay = 0`（立即弹出）

```lua
-- ❌ 坏：每次按前缀键都弹菜单，干扰正常快速操作
require("which-key").setup({ delay = 0 })

-- ✅ 正确：保持默认 300ms，快速按键不触发，停下来想时才弹
require("which-key").setup({ delay = 300 })
```

### ❌ 只用 `wk.add()` 注册快捷键（不用 `vim.keymap.set`）

```lua
-- ❌ 坏：如果 which-key 没装，这些快捷键全部失效
wk.add({
  { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件" },
})

-- ✅ 正确：用 vim.keymap.set 注册快捷键（通用），用 wk.add 只加分组标签
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "查找文件" })
wk.add({ { "<leader>f", group = "查找" } })
```

### ❌ 注册分组标签时不匹配已有前缀

```lua
-- ❌ 坏：如果没有任何 <leader>t* 快捷键，这个分组标签无意义
wk.add({ { "<leader>t", group = "终端" } })

-- ✅ 正确：先注册快捷键，再加分组标签
vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "浮动终端" })
wk.add({ { "<leader>t", group = "终端" } })
```

### ❌ 忘记 `desc` 字段

```lua
-- ❌ 坏：which-key 菜单里看不到这个快捷键
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>")

-- ✅ 正确：带 desc
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "查找文件" })
```

---

## 运行验证

本章包含两个 Lua 文件，验证语法：

```bash
cd lazyvim/08-which-key

# 验证 init.lua（pcall guard，不会因缺少 which-key 报错）
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

# 验证 plugins/which-key.lua（return { ... } 格式，luafile 直接解析）
nvim --headless -u NONE -c "luafile lua/plugins/which-key.lua" -c 'qa!'
```

预期：两个命令都退出码 0，无错误。init.lua 会打印 `[demo]` 消息说明 which-key 未安装。

> 💡 **真实环境验证**：把 `lua/plugins/which-key.lua` 复制到
> `~/.config/nvim/lua/plugins/` 下，运行 `:Lazy sync`，然后按 `<Space>` 等 300ms，
> 能看到 which-key 菜单弹出。

---

## 下一步

你已经掌握了 which-key 的探索式工作流——不用背快捷键，按 Leader 键就有菜单。

接下来 **第 09 章「Telescope」** 会深入 LazyVim 最常用的插件：
模糊搜索文件、搜索文本、搜索 Git 提交... Telescope 是 `<leader>f` 和 `<leader>s` 背后的引擎。

> 💡 **本章核心**：which-key 是"边用边学"的工具——按前缀键 → 看菜单 → 选操作。
> 用 `wk.add()` 只加**分组标签**，快捷键还是用 `vim.keymap.set` 注册。
> `desc` 字段是 which-key 和 `vim.keymap.set` 之间的桥梁，永远不要省略。

---

## 代码

- [`lua/init.lua`](./lua/init.lua) — which-key setup + wk.add() 分组演示
- [`lua/plugins/which-key.lua`](./lua/plugins/which-key.lua) — which-key.nvim 的 lazy.nvim spec
- [`exercises/`](./exercises/README.md) — 4 道练习题（探索式工作流、分组自定义、配置调优）

**上一章**：[07-leader-keys](../07-leader-keys/)（Leader 键体系）
**下一章**：[09-telescope](../09-telescope/)（Telescope 模糊搜索）
