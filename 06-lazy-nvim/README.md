# 第06章 lazy.nvim 插件管理器 — spec 格式与懒加载策略

> **lazy.nvim 是 LazyVim 的引擎**——没有它，LazyVim 只是一堆 spec 纸上谈兵。
> 本章逐个字段拆解 spec 格式，用对比表格说清 `event`/`ft`/`keys`/`cmd` 四种懒加载策略的取舍，
> 并详解 **extend vs overwrite** 这个 LazyVim 配置的核心心法。
> 学完本章，你写任何插件的 spec 都不会再翻文档。

---

## 本章目标

学完本章，你将能够：

1. **读懂 spec 的每个字段**：url、opts、keys、event、ft、cmd、config、dependencies、enabled 等
2. **选择正确的懒加载策略**：event vs ft vs keys vs cmd——什么时候用哪种
3. **掌握 `:Lazy` 命令全家桶**：install、sync、update、clean、log、profile、debug、restore
4. **精通 extend vs overwrite 模式**：为什么用 `opts = function` 而非 `opts = {...}` 扩展列表
5. **管理 `lazy-lock.json`**：版本锁定、还原、团队协作

> ⚠️ **前置条件**：完成第 04 章（装好 LazyVim）和第 05 章（理解目录架构与合并语义）。
> 本章是 Part 1 的收尾——三章节完，你就具备了读懂任何 LazyVim 配置的能力。

---

## lazy.nvim spec 格式详解

### 最小 spec

```lua
{ "folke/tokyonight.nvim" }
```

这行就够了——lazy.nvim 会从 GitHub clone `folke/tokyonight.nvim`，启动时加载。
但大多数插件需要配置，于是 spec 多了各种字段。

### 完整字段表

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `[1]` 或 `url` | string | 插件地址（GitHub 简写或完整 URL） | `"folke/tokyonight.nvim"` 或 `"https://github.com/folke/tokyonight.nvim"` |
| `dir` | string | 本地目录（替代 url，开发插件时用） | `"~/projects/my-plugin"` |
| `opts` | table \| function | 传给 `require(PLUGIN).setup(opts)` 的选项 | `opts = { style = "storm" }` |
| `config` | function \| true | 插件初始化函数；`true` 表示用默认 `require(PLUGIN).setup(opts)` | `config = function() require("xxx").setup({}) end` |
| `keys` | table | 懒加载：按这些键时才加载 | `keys = { "<leader>ff", "<leader>fg" }` |
| `event` | string \| table | 懒加载：触发这些事件时才加载 | `event = "BufReadPost"` |
| `ft` | table | 懒加载：打开这些文件类型时才加载 | `ft = { "go", "rust" }` |
| `cmd` | string \| table | 懒加载：执行这些命令时才加载 | `cmd = "Neotree"` |
| `dependencies` | table | 依赖的其他插件（在当前插件之前加载） | `dependencies = { "nvim-lua/plenary.nvim" }` |
| `enabled` | bool \| function | 是否启用（可条件启用） | `enabled = vim.fn.has("nvim-0.10") == 1` |
| `branch` | string | 指定 Git 分支 | `branch = "dev"` |
| `tag` | string | 指定 Git tag | `tag = "v1.0.0"` |
| `version` | string \| false | 版本（`"*"` 表示最新 stable tag） | `version = "*"` |
| `pin` | bool | 锁定版本（不随 update 更新） | `pin = true` |
| `priority` | number | 加载优先级（数字大先加载，配色插件常用） | `priority = 1000` |
| `lazy` | bool | 是否标记为懒加载（不指定任何触发条件时用） | `lazy = true` |
| `build` | string \| function | 安装/更新后执行的构建命令 | `build = "make"` 或 `build = ":TSUpdate"` |
| `init` | function | 在插件加载**之前**执行的代码 | `init = function() vim.g.xxx = 1 end` |
| `cond` | bool \| function | 条件加载（类似 enabled 但更细粒度） | `cond = function() return vim.g.use_xxx end` |

### 字段详解：哪些字段容易踩坑

#### `opts` vs `config` — 什么时候用哪个

| 字段 | 适用场景 | 不适用场景 |
|------|----------|------------|
| `opts = {...}` | 插件有 `setup()` 函数，你只想传选项 | 插件没有 `setup()`，或你需要复杂的初始化逻辑 |
| `config = function() ... end` | 你需要写复杂的初始化代码，或插件不用 `setup()` | 只是想传几个选项（用 opts 更简洁） |
| `config = true` | 等价于 `config = function() require(PLUGIN).setup(opts) end` | 你想完全自定义 config |

**90% 的情况用 `opts`**——大多数现代插件都有 `setup(opts)` 函数。
当你发现 `opts` 不够用时（比如要在 setup 前后做事），再升级到 `config`。

```lua
-- 简单：用 opts
{ "nvim-telescope/telescope.nvim", opts = { defaults = { layout_strategy = "horizontal" } } }

-- 复杂：用 config（需要在 setup 后执行额外代码）
{
  "nvim-telescope/telescope.nvim",
  config = function()
    local telescope = require("telescope")
    telescope.setup({ defaults = { layout_strategy = "horizontal" } })
    telescope.load_extension("fzf")  -- setup 后加载扩展
  end,
}
```

#### `dependencies` vs `init` — 都是"插件加载前后"做事

| 字段 | 执行时机 | 用途 |
|------|----------|------|
| `dependencies` | 当前插件加载**之前** | 声明依赖的其他插件（lazy.nvim 保证依赖先加载） |
| `init` | 当前插件加载**之前**（但 Neovim 启动时就执行，即使插件还没加载） | 设置全局变量、注册命令，为插件的懒加载做准备 |

```lua
{
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },  -- 依赖先加载
  init = function()
    vim.g.telescope_keys = true  -- 即使 telescope 还没加载，这个变量也设好了
  end,
}
```

> ⚠️ **`init` 是全局执行的**——即使插件因为懒加载还没加载，`init` 也会在启动时执行。
> 不要在 `init` 里 `require` 插件本身（会报错），只设全局变量或注册命令。

---

## 懒加载策略详解 — event vs ft vs keys vs cmd

这是本章的核心实用知识。lazy.nvim 之所以能让 Neovim 启动飞快（< 50ms），
全靠懒加载——插件用的时候才加载，不用永远不加载。

### 四种懒加载触发器对比

| 触发器 | 何时触发加载 | 典型场景 | 示例 |
|--------|--------------|----------|------|
| `event` | Neovim 事件发生时（`BufRead`、`BufWrite`、`InsertEnter`...） | 插件需要在编辑时才用 | `event = "BufReadPost"`（读文件后加载） |
| `ft` | 打开指定文件类型时 | 语言专属插件（LSP、补全、格式化） | `ft = { "go", "rust" }`（打开 Go/Rust 文件时加载） |
| `keys` | 按下指定键时 | 命令式工具（搜索、文件树、Git） | `keys = "<leader>ff"`（按 Leader+f+f 时加载 Telescope） |
| `cmd` | 执行指定命令时 | 偶尔用的命令式插件 | `cmd = "LazyGit"`（运行 `:LazyGit` 时加载） |

### 选择策略的决策树

```
这个插件什么时候需要？
│
├─ 只在编辑特定语言的文件时 → 用 ft
│   例：rust-tools.nvim → ft = { "rust" }
│
├─ 绑定了快捷键，按键才用 → 用 keys
│   例：telescope.nvim → keys = { "<leader>ff", ... }
│
├─ 用 :命令 调用，不绑快捷键 → 用 cmd
│   例：lazygit.nvim → cmd = "LazyGit"
│
├─ 需要在每次打开文件时都就绪 → 用 event
│   例：gitsigns.nvim → event = "BufReadPost"
│
└─ 需要一直就绪（配色、UI 框架）→ 不懒加载，加 priority
    例：tokyonight.nvim → priority = 1000（不设 event/ft/keys/cmd）
```

### keys 字段详解（最常用）

`keys` 可以是字符串列表，也可以是带描述的 table：

```lua
-- 简单形式：字符串列表
keys = { "<leader>ff", "<leader>fg", "<leader>fb" }

-- 完整形式：带 desc、mode、rhs
keys = {
  { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件", mode = "n" },
  { "<leader>fg", "<cmd>Telescope live_grep<CR>",   desc = "实时 grep", mode = "n" },
  { "<leader>fb", "<cmd>Telescope buffers<CR>",     desc = "切换 buffer",  mode = "n" },
}
```

**完整形式的 `keys` 等价于**：
1. 注册快捷键（像 `vim.keymap.set`）
2. 按下时先加载插件，再执行 rhs
3. `desc` 会被 which-key 拾取（第 08 章详解）

> 💡 **推荐用完整形式**——带 `desc` 的 keymap 会在 which-key 里显示功能描述，
> 不带 desc 的只有按键没有说明，等于没用。

### event 字段详解

`event` 可以是字符串或字符串列表：

```lua
-- 单个事件
event = "BufReadPost"        -- 打开文件后加载（最常用）

-- 多个事件
event = { "BufReadPost", "BufNewFile" }  -- 打开已有文件或新建文件时加载

-- 带通配符
event = "User SomeCustomEvent"  -- 自定义事件（插件可以触发）
```

**常见事件**：
- `BufReadPost` — 打开文件后（文件已读入 buffer）
- `BufEnter` — 进入 buffer 时
- `InsertEnter` — 进入 insert 模式时
- `BufWritePre` — 保存前
- `VimEnter` — Neovim 启动完成后（比不懒加载稍晚，但 UI 已就绪）

### ft 字段详解

`ft` 是"filetype"缩写，指定文件类型：

```lua
ft = { "go", "rust", "python" }  -- 打开 Go/Rust/Python 文件时加载
```

**vs event 的区别**：`event = "BufReadPost"` 是**所有文件**打开后加载；
`ft = { "go" }` 是**只打开 Go 文件**时加载。语言专属插件用 `ft` 更精确。

---

## `:Lazy` 命令全家桶

| 命令 | 作用 | 常用程度 |
|------|------|----------|
| `:Lazy` | 打开 lazy.nvim UI 面板（查看所有插件状态） | ★★★ |
| `:Lazy install` | 安装 lazy-lock.json 里锁定但本地没装的插件 | ★★★ |
| `:Lazy clean` | 删除本地有但 spec 没引用的插件 | ★★☆ |
| `:Lazy update` | 更新所有插件到最新版本（更新 lazy-lock.json） | ★★★ |
| `:Lazy sync` | install + clean + update 三合一 | ★★★ |
| `:Lazy restore` | 还原所有插件到 lazy-lock.json 记录的版本 | ★★☆ |
| `:Lazy log` | 查看插件更新日志（git log） | ★★☆ |
| `:Lazy profile` | 启动性能分析器（查看每个插件加载耗时） | ★★☆ |
| `:Lazy debug` | 启用调试模式（查看加载详情） | ★☆☆ |
| `:Lazy load <plugin>` | 手动加载某个懒加载插件 | ★☆☆ |
| `:Lazy health` | 运行 lazy.nvim 健康检查 | ★★★ |
| `:Lazy extras` | （LazyVim 扩展）查看/启用 Extras | ★★☆ |

### 最常用的三个命令

```vim
:Lazy sync     " 装完新插件后同步（install + clean + update）
:Lazy update   " 只更新（不 clean/install）
:LazyHealth    " 检查配置是否健康
```

### `:Lazy profile` — 性能调优神器

如果你觉得 Neovim 启动慢，运行 `:Lazy profile` 会显示每个插件的加载耗时：

```
plugin              time     event
tokyonight.nvim     2.3ms    VimEnter
telescope.nvim      15.2ms   keys <leader>ff
nvim-treesitter     45.6ms   BufReadPost
```

找到最慢的插件，考虑是否改成更激进的懒加载（比如把 `event` 改成 `keys`）。

---

## override vs extend 模式（核心心法）

这是本章最重要的概念，也是 LazyVim 配置的第一铁律。

### 问题背景

LazyVim 为每个内置插件定义了默认 spec（包括默认 opts、keys、event 等）。
你想定制时，**不是重新写一个 spec 覆盖**，而是**写一个 spec 与默认的合并**。

### ❌ 反模式：用 table 覆盖列表字段

```lua
-- ❌ 坏：直接覆盖 ensure_installed
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "lua", "rust" },  -- 覆盖！默认的 bash/c/css 全没了
    },
  },
}
```

**后果**：LazyVim 默认装的一堆解析器（bash/c/css/html/js/json/...）全部消失，
因为这些列表字段用 table 赋值会**整体替换**，不是追加。

### ✅ 正确模式：用 function extend 列表字段

```lua
-- ✅ 正确：用 opts = function 接收默认 opts，再 extend
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- opts 是 LazyVim 默认的 opts（引用传递）
      -- opts.ensure_installed 已经包含默认的 bash/c/css/...
      -- vim.list_extend 把你的追加到默认列表后面
      vim.list_extend(opts.ensure_installed, {
        "lua",
        "rust",
        "toml",
      })
      -- 不需要 return（修改引用即生效）
    end,
  },
}
```

### 为什么 `opts = function` 能 extend？

lazy.nvim 的合并规则（第 05 章详解）：

| `opts` 类型 | 合并策略 |
|-------------|----------|
| table（`opts = {...}`） | 深度合并：同名 key 你的覆盖默认的；列表字段整体替换 |
| function（`opts = function(_, opts) ... end`） | lazy.nvim 先准备好默认 opts，作为第二个参数传给你的 function，你修改它 |

所以 `opts = function(_, opts)` 让你**拿到默认 opts 的引用**，可以任意修改。
这是 extend 的唯一正确方式。

### 完整的 extend/overwrite 对照表

| 场景 | 推荐写法 | 说明 |
|------|----------|------|
| 扩展 `ensure_installed` 列表 | `opts = function(_, opts) vim.list_extend(opts.ensure_installed, {...}) end` | 追加语言 |
| 扩展 `defaults` table 字段 | `opts = function(_, opts) opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {...}) end` | 追加配置 |
| 设置默认没有的字段 | `opts = { new_field = value }` | 安全（默认没这个字段，无所谓覆盖） |
| 完全替换某个字段 | `opts = { field = value }` | 明确知道要覆盖全部时用 |
| 禁用默认插件 | `enabled = false` | 在 spec 里加 `enabled = false` |

### `vim.list_extend` vs `vim.tbl_deep_extend`

| 函数 | 操作对象 | 用途 |
|------|----------|------|
| `vim.list_extend(target, source)` | 列表（array） | 把 source 的元素追加到 target 后面 |
| `vim.tbl_deep_extend("force", t1, t2)` | table（dict） | 递归合并 t2 到 t1，同名 key t2 覆盖 t1 |
| `vim.tbl_extend("force", t1, t2)` | table（dict） | 浅合并（不递归） |

```lua
-- vim.list_extend：列表追加
local a = { "x", "y" }
vim.list_extend(a, { "z", "w" })
-- a = { "x", "y", "z", "w" }

-- vim.tbl_deep_extend：table 深度合并
local t = { defaults = { layout = "horizontal", mappings = {} } }
local result = vim.tbl_deep_extend("force", t, { defaults = { sorting = "ascending" } })
-- result = { defaults = { layout = "horizontal", mappings = {}, sorting = "ascending" } }
-- 注意 mappings 没丢，sorting 追加了
```

---

## `lazy-lock.json` 详解

### 文件结构

```json
{
  "LazyVim": { "branch": "main", "commit": "abc1234def5678", "version": false },
  "bufferline.nvim": { "branch": "main", "commit": "a1b2c3d4", "version": false },
  "lazy.nvim": { "branch": "main", "commit": "e5f6g7h8", "version": false },
  "nvim-treesitter": { "branch": "main", "commit": "i9j0k1l2", "version": false }
}
```

每个插件记录三个字段：
- `branch` — Git 分支
- `commit` — 具体的 commit hash（版本锁定的核心）
- `version` — 如果插件有 tag，这里是 tag 名；`false` 表示不用 tag

### 什么时候会更新

| 操作 | 是否更新 lazy-lock.json |
|------|-------------------------|
| `:Lazy install` | ✅ 否（按现有 lock 装） |
| `:Lazy update` | ✅ 是（装最新版后更新 lock） |
| `:Lazy sync` | ✅ 是（包含 update） |
| `:Lazy restore` | ❌ 否（按现有 lock 还原） |
| 手动改 spec 后重启 | ❌ 否（只改 spec 不改 lock） |

### 团队协作工作流

```
队友 A 加了新插件 → 改 spec + :Lazy sync → commit lazy-lock.json → push
                                                                        │
                                                                        ▼
你 pull 仓库 → :Lazy sync（读取新 lock，安装队友加的插件）→ 版本完全一致
```

> 💡 **铁律**：**commit `lazy-lock.json`**。不要 gitignore，否则换机器就装到不同版本，
> 引入莫名其妙的 bug。这和 `package-lock.json`、`poetry.lock` 是一个道理。

---

## 反模式（什么不该做）

### ❌ 用 `opts = {...}` 覆盖列表字段

```lua
-- ❌ 坏
{ "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = { "lua" } } }

-- ✅ 正确
{ "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts) vim.list_extend(opts.ensure_installed, { "lua" }) end }
```

### ❌ 给每个插件都设 `lazy = false`（禁用懒加载）

```lua
-- ❌ 坏：启动时全加载，启动慢
{ "telescope.nvim", lazy = false }
{ "gitsigns.nvim", lazy = false }
-- ... 50 个插件全部 lazy = false，启动 2 秒

-- ✅ 正确：用 event/ft/keys/cmd 精确懒加载
{ "telescope.nvim", keys = { "<leader>ff" } }
{ "gitsigns.nvim", event = "BufReadPost" }
```

### ❌ 在 `keys` 字符串形式不写 desc

```lua
-- ❌ 坏：which-key 只显示按键，不显示功能
keys = { "<leader>ff", "<leader>fg" }

-- ✅ 正确：用 table 形式带 desc
keys = {
  { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件" },
  { "<leader>fg", "<cmd>Telescope live_grep<CR>",   desc = "实时 grep" },
}
```

### ❌ 在 `init` 里 require 插件本身

```lua
-- ❌ 坏：init 在插件加载前执行，require 会报错
{ "telescope.nvim",
  init = function() require("telescope").setup({}) end,  -- 报错！
}

-- ✅ 正确：用 opts 或 config（它们在插件加载后执行）
{ "telescope.nvim", opts = {} }
-- 或
{ "telescope.nvim", config = function() require("telescope").setup({}) end }
```

### ❌ gitignore `lazy-lock.json`

```gitignore
# ❌ 坏
lazy-lock.json

# ✅ 正确：commit 它
```

---

## 运行验证

本章的 `lua/plugins/example.lua` 包含 3 种 spec 模式，验证语法：

```bash
cd lazyvim/06-lazy-nvim

# 验证 init.lua（演示 lazy.nvim bootstrap）
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'

# 验证 example.lua（return { ... } 形式，直接 luafile 不会报错）
nvim --headless -u NONE -c "luafile lua/plugins/example.lua" -c 'qa!'
```

预期：退出码 0，无错误。

> 💡 **真实环境验证**：如果你已经装了 LazyVim，把 `lua/plugins/example.lua` 复制到
> `~/.config/nvim/lua/plugins/` 下，然后运行 `:Lazy sync`，能看到 spec 被正确识别。

---

## 下一步

恭喜你完成了 Part 1（架构篇）！回顾一下你学到了什么：

- **第 04 章**：LazyVim 是什么、怎么装、目录结构概览
- **第 05 章**：`lua/config/` 和 `lua/plugins/` 的组织方式、合并语义
- **第 06 章**（本章）：lazy.nvim 的 spec 格式、懒加载策略、extend vs overwrite

现在你具备了读懂任何 LazyVim 配置的能力。**Part 2（核心工作流）** 会进入"用"的阶段：

- **第 07 章「Leader 键」**：LazyVim 默认 Leader 键体系全解析
- **第 08 章「which-key」**：快捷键提示神器
- **第 09 章「Telescope」**：模糊搜索一切
- **第 10 章「Neo-tree」**：文件浏览器

> 💡 **本章核心**：记住"extend 不 overwrite"——这是 lazy.nvim spec 的第一条铁律。
> 任何时候你要扩展列表型字段，都用 `opts = function(_, opts) vim.list_extend(opts.X, {...}) end`。

---

## 代码

- [`lua/init.lua`](./lua/init.lua) — lazy.nvim bootstrap + setup 教学示例
- [`lua/plugins/example.lua`](./lua/plugins/example.lua) — 3 种 spec 模式示例
- [`exercises/`](./exercises/README.md) — 5 道练习题（写 spec、选懒加载策略、extend vs overwrite）

**上一章**：[05-config-architecture](../05-config-architecture/)（配置目录架构）
**下一章**：[07-leader-keys](../07-leader-keys/)（Leader 键体系）
