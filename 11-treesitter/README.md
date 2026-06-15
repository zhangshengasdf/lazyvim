# 第11章 Treesitter 语法引擎 — 从正则高亮到语法树

> **没有 Treesitter 的 Neovim 就像没有 X 光的外科医生**——只能凭经验猜代码结构，
> 有了它，每一行代码都被拆解成精确的语法节点，高亮、选择、导航全部基于真正的语法树而非脆弱的正则。
> 本章带你理解 Treesitter 的工作原理，掌握增量选择、文本对象等杀手级功能，
> 学会用 extend 模式安全地添加语言解析器。
> 学完本章，你的 Neovim 能精确理解 100+ 种语言的代码结构。

---

## TL;DR

> **30 秒速读**：Treesitter 用语法树替代正则做高亮，让 Neovim 精确理解代码结构，配合增量选择和文本对象实现精确代码操作。
> 
> **如果只记一件事**：永远用 `opts = function(_, opts) vim.list_extend(...)` 扩展 `ensure_installed`，用 `opts = {}` 会覆盖默认解析器。

---

## 本章目标

学完本章，你将能够：

1. **区分正则高亮与 Treesitter 高亮**：知道为什么正则会"误判"，Treesitter 不会
2. **安装和管理语言解析器**：用 `:TSInstall` 和 `ensure_installed` 配置所需语言
3. **使用增量选择**：`gn` 逐级扩大选区，精确选中语法节点
4. **掌握 Treesitter 文本对象**：`vaf`/`vir`/`vac`/`vic` 选中函数、参数、类、条件
5. **用 extend 模式添加解析器**：`opts = function(_, opts) vim.list_extend(...)` 而非覆盖

> **前置条件**：完成第 06 章（理解 lazy.nvim spec 格式和 extend 模式）。
> 本章是 Part 3「代码智能」的第一章，后面三章（LSP、补全、格式化）都建立在 Treesitter 基础上。

---

## 钩子：为什么你的高亮总是错

打开一个 JavaScript 文件，看看这段代码：

```javascript
const greeting = `Hello, ${name}! Welcome to ${city}.`;
```

正则高亮会怎么处理？它用一组正则规则逐行匹配：

- 匹配到反引号 `` ` `` → 标记为"字符串开始"
- 遇到 `${` → 但它在字符串内部，正则不知道这是模板表达式
- 结果：整个 `` `Hello, ${name}! Welcome to ${city}.` `` 被标记为纯字符串
- `${name}` 和 `${city}` 的变量名没有被高亮

Treesitter 呢？它把这段代码解析成一棵语法树：

```
template_string
├── template_fragment  "Hello, "
├── template_substitution
│   └── identifier     "name"
├── template_fragment  "! Welcome to "
├── template_substitution
│   └── identifier     "city"
└── template_fragment  "."
```

每个部分都有精确的语法类型。变量 `name` 和 `city` 会被正确高亮为变量名，而不是"字符串的一部分"。

**这就是正则和语法树的根本区别**：正则只看文本模式，Treesitter 理解代码结构。

---

## Treesitter vs 正则高亮：核心对比

| 维度 | 正则高亮（Vim 传统） | Treesitter 高亮 |
|------|----------------------|-----------------|
| **工作原理** | 逐行正则匹配 | 解析完整语法树（AST） |
| **上下文感知** | 无（每行独立） | 有（理解嵌套、作用域） |
| **模板字符串** | 整体标记为字符串 | 内嵌表达式正确高亮 |
| **多行结构** | 经常失败 | 始终正确 |
| **性能** | 每次编辑重新匹配整行 | 增量解析（只更新变化的节点） |
| **语言覆盖** | 每种语言一个 .vim 文件 | 每种语言一个 .so 解析器（编译好的 C/Rust） |
| **新语言支持** | 手写正则（费时费力） | 写 grammar.js 编译即可 |
| **精确度** | 模糊匹配（经常误判） | 精确到每个语法节点 |
| **额外能力** | 只有高亮 | 高亮 + 代码折叠 + 增量选择 + 文本对象 |

> 💡 **一句话总结**：正则是"猜"，Treesitter 是"懂"。

---

## Treesitter 是什么

Treesitter（tree-sitter）是一个增量解析器生成器，由 Max Brunsfeld 创建。
它把源代码解析成具体的语法树（Concrete Syntax Tree，CST），然后基于这棵树提供各种能力。

### 核心概念

**解析器（Parser）**：每种语言有一个独立的解析器，编译成 `.so`（Linux）或 `.dylib`（macOS）文件。
解析器是用 C 或 Rust 写的，性能极高，解析速度通常在毫秒级。

**语法树（Syntax Tree）**：解析器把源代码转换成树结构。
每个节点代表一个语法元素（函数、变量、字符串、关键字……）。

**查询（Query）**：Treesitter 用 S-expression 查询语言匹配语法树节点。
高亮、文本对象、折叠都是通过查询实现的。

### 工作流程

```
源代码 → 解析器（.so） → 语法树 → 查询（高亮/选择/折叠） → Neovim 显示
  │                      │
  │ 编辑后               │ 增量更新（只修改变化的子树）
  └──────────────────────┘
```

当你编辑代码时，Treesitter 不会重新解析整个文件——它只更新受影响的子树。
这就是为什么它比正则更快、更准。

---

## 安装语言解析器

### 交互式安装：`:TSInstall`

```vim
:TSInstall lua        " 安装 Lua 解析器
:TSInstall javascript " 安装 JavaScript 解析器
:TSInstall python     " 安装 Python 解析器
```

安装完成后，解析器文件保存在 `~/.local/share/nvim/lazy/nvim-treesitter/parser/` 下。

### 查看已安装解析器

```vim
:TSInstallInfo       " 列出所有可用解析器（installed 列显示状态）
:checkhealth nvim_treesitter  " 健康检查（显示安装状态）
```

### 配置自动安装：`ensure_installed`

手动一个个装太麻烦，用 `ensure_installed` 列表让 Treesitter 启动时自动安装：

```lua
-- ❌ 错误：直接覆盖（默认解析器全没了）
opts = {
  ensure_installed = { "lua", "python" },
}

-- ✅ 正确：extend 模式（追加到默认列表）
opts = function(_, opts)
  vim.list_extend(opts.ensure_installed, {
    "lua",
    "python",
    "javascript",
    "typescript",
  })
end
```

> ⚠️ **铁律**：永远用 extend 模式扩展 `ensure_installed`。
> LazyVim 默认已安装的解析器（bash/c/css/html/js/json/lua/python/vim 等）会被保留。

### 解析器管理命令

| 命令 | 作用 |
|------|------|
| `:TSInstall <lang>` | 安装指定语言解析器 |
| `:TSInstallInfo` | 列出所有解析器状态 |
| `:TSUpdate` | 更新所有已安装的解析器 |
| `:TSUpdate <lang>` | 更新指定解析器 |
| `:TSUninstall <lang>` | 卸载指定解析器 |

---

## 增量选择（Incremental Selection）

增量选择是 Treesitter 最实用的功能之一。传统 `v` 选择是基于字符的，
增量选择则基于语法节点——按一次选中当前节点，再按扩大到父节点。

### 默认快捷键

| 按键 | 作用 |
|------|------|
| `gn` | 选中当前语法节点（init selection） |
| `gn`（再按） | 扩大选区到父节点（increment） |
| `gN` | 缩小选区到子节点（decrement） |

### 使用示例

假设有这段 Lua 代码：

```lua
local greeting = string.format("Hello, %s!", name)
```

光标在 `name` 上：
1. 按 `gn` → 选中 `name`（identifier 节点）
2. 再按 `gn` → 选中整个函数参数 `"Hello, %s!", name`（arguments 节点）
3. 再按 `gn` → 选中整个 `string.format("Hello, %s!", name)`（function_call 节点）
4. 再按 `gn` → 选中整个赋值语句 `local greeting = ...`（assignment 节点）
5. 按 `gN` → 回到上一级（function_call）

这个过程不需要你数括号、找配对，Treesitter 知道每个节点的边界。

### 配置增量选择

增量选择默认已启用。如果需要自定义按键，在 `treesitter.lua` 里配置：

```lua
opts = function(_, opts)
  -- 追加语言（extend 模式）
  vim.list_extend(opts.ensure_installed, { "lua", "python" })

  -- 自定义增量选择按键
  opts.incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gn",     -- 选中当前节点
      node_incremental = "gn",   -- 扩大到父节点
      scope_incremental = false, -- 不绑定扩大到作用域
      node_decremental = "gN",   -- 缩小到子节点
    },
  }
end
```

---

## 文本对象：`vaf`/`vir`/`vac`/`vic`

Treesitter 文本对象是 Neovim 中最强大的代码选择方式。
它让你像操作单词一样操作函数、参数、类、条件块。

### 工作原理

传统 Vim 文本对象（`viw`、`da"`）基于字符模式——找到配对的引号或括号。
Treesitter 文本对象基于语法树——它知道"这个函数从哪里开始、到哪里结束"。

### 默认文本对象

LazyVim 通过 `nvim-treesitter-textobjects` 插件提供了这些文本对象：

| 按键 | 文本对象 | 说明 |
|------|----------|------|
| `vaf` / `daf` / `yaf` | `@function.outer` | 整个函数（含 def/func 头） |
| `vir` / `dir` / `yir` | `@function.inner` | 函数体（不含头尾签名行） |
| `vac` / `dac` / `yac` | `@class.outer` | 整个类（含 class 头） |
| `vic` / `dic` / `yic` | `@class.inner` | 类体（不含头尾） |
| `vaa` / `daa` / `yaa` | `@parameter.outer` | 整个参数（含逗号） |
| `via` / `dia` / `yia` | `@parameter.inner` | 参数值（不含逗号） |
| `va` | `@assignment.outer` | 整个赋值语句 |
| `vi` | `@assignment.inner` | 赋值右侧 |
| `val` / `vil` | `@loop.outer` / `@loop.inner` | 循环块 |
| `vai` / `vii` | `@conditional.outer` / `@conditional.inner` | 条件块 |

> 💡 **记忆法**：`a` = around（含外层），`i` = inner（不含外层）。
> `f` = function，`r` = routine（function 的别名），`c` = class，`a` = argument。

### 使用示例

```python
def greet(name, city):           # ← 光标在这一行
    message = f"Hello, {name}!"
    print(message, city)
    return message
```

- 光标在 `greet` 行，按 `vaf` → 选中整个 `def greet(...): ... return message`
- 光标在 `greet` 行，按 `vir` → 选中函数体（三行，不含 def 行和最后的空行）
- 光标在 `name` 参数，按 `vaa` → 选中 `name,`（含逗号）
- 光标在 `name` 参数，按 `via` → 选中 `name`（不含逗号）

### nvim-treesitter-textobjects

这些文本对象来自 `nvim-treesitter-textobjects` 插件，LazyVim 已内置。
它的查询文件定义在 `queries/<lang>/textobjects.scm` 里，每种语言的定义可能不同。

配置示例（在 `treesitter.lua` 里扩展）：

```lua
opts = function(_, opts)
  vim.list_extend(opts.ensure_installed, { "lua", "python" })

  -- 自定义文本对象选择和移动
  opts.textobjects = {
    select = {
      enable = true,
      lookahead = true,  -- 光标后的目标也匹配
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true,  -- 记录跳转到 jumplist
      goto_next_start = {
        ["]f"] = "@function.outer",
        ["]c"] = "@class.outer",
      },
      goto_next_end = {
        ["]F"] = "@function.outer",
        ["]C"] = "@class.outer",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
        ["[c"] = "@class.outer",
      },
      goto_previous_end = {
        ["[F"] = "@function.outer",
        ["[C"] = "@class.outer",
      },
    },
  }
end
```

---

## LazyVim 内置的 Treesitter 配置

LazyVim 为 nvim-treesitter 提供了默认 spec，包括：

1. **默认解析器列表**：bash, c, css, html, javascript, json, lua, python, vim, vimdoc 等
2. **高亮启用**：`highlight = { enable = true }`
3. **增量选择启用**：`incremental_selection = { enable = true }`
4. **文本对象**：通过 `nvim-treesitter-textobjects` 提供
5. **自动安装**：`:TSUpdate` 在插件更新时自动运行

你的任务是**扩展**这个列表，而不是替换它。

### 查看 LazyVim 默认配置

想知道 LazyVim 给 Treesitter 默认配了什么？运行：

```vim
:lua print(vim.inspect(require("nvim-treesitter.configs").get_module("ensure_installed")))
```

或者直接看 LazyVim 源码：`~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/editor.lua`。

---

## `ensure_installed` 的 extend 模式详解

这是本章最核心的配置技巧，也是第 06 章 extend 模式的直接应用。

### 为什么不能直接覆盖

```lua
-- ❌ 反模式：直接用 opts table
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "lua", "rust", "toml" },
    },
  },
}
```

这段代码的问题：`opts = {...}` 是 table，lazy.nvim 合并时会**整体替换** `ensure_installed`。
LazyVim 默认的 bash/c/css/html/js/json/lua/python/vim/vimdoc 全部消失。

### 正确做法：opts = function

```lua
-- ✅ 正确：用 function 接收默认 opts，再 extend
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- opts.ensure_installed 已包含 LazyVim 默认值
      -- vim.list_extend 追加到末尾，不覆盖
      vim.list_extend(opts.ensure_installed, {
        "lua",
        "rust",
        "toml",
        "ron",      -- Rust 配置格式
        "python",
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "json",
        "yaml",
        "toml",
        "bash",
        "markdown",
        "markdown_inline",
      })
    end,
  },
}
```

### 合并流程

```
LazyVim 默认 opts.ensure_installed = { "bash", "c", "css", "html", "js", "json", "lua", ... }
                                                                    │
你的 opts = function(_, opts)                                       │
  vim.list_extend(opts.ensure_installed, { "rust", "toml" })       │
                                                                    │
最终结果 = { "bash", "c", "css", "html", "js", "json", "lua", ..., "rust", "toml" }
```

---

## 其他 Treesitter 功能

### 代码折叠

Treesitter 可以基于语法树折叠代码（比 `indent` 折叠更准确）：

```lua
-- 在 lua/config/options.lua 中设置
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
```

> ⚠️ LazyVim 默认可能已配置折叠。如果不想用，在 options.lua 里覆盖即可。

### 高亮模块自定义

```lua
opts = function(_, opts)
  vim.list_extend(opts.ensure_installed, { "lua" })

  -- 自定义高亮（通常不需要改）
  opts.highlight = vim.tbl_deep_extend("force", opts.highlight or {}, {
    enable = true,
    -- 禁用传统正则高亮（Treesitter 接管后不需要）
    additional_vim_regex_highlighting = false,
  })
end
```

### Playground（调试语法树）

想看 Treesitter 生成的语法树？安装 playground 插件：

```lua
-- 追加到 lua/plugins/treesitter.lua
{ "nvim-treesitter/playground", cmd = "TSPlaygroundToggle" }
```

按 `:TSPlaygroundToggle` 打开语法树视图，实时查看每个节点的类型。

---

## 反模式（什么不该做）

### ❌ 用 `opts = {...}` 覆盖 ensure_installed

```lua
-- ❌ 坏：默认解析器全没了
{ "nvim-treesitter/nvim-treesitter",
  opts = { ensure_installed = { "lua", "rust" } } }

-- ✅ 正确：extend 模式
{ "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts) vim.list_extend(opts.ensure_installed, { "lua", "rust" }) end }
```

### ❌ 手动下载解析器文件

```bash
# ❌ 坏：手动下载 .so 文件到 parser 目录
curl -o ~/.local/share/nvim/lazy/nvim-treesitter/parser/lua.so ...

# ✅ 正确：用 :TSInstall 或 ensure_installed 自动管理
:TSInstall lua
```

### ❌ 把所有语言都塞进 ensure_installed

```lua
-- ❌ 坏：装 100 个解析器，大部分你永远用不到
vim.list_extend(opts.ensure_installed, {
  "ada", "agda", "arduino", "astro", "bash", "bibtex", "c", "c_sharp",
  -- ... 100 多种语言
})

-- ✅ 正确：只装你实际使用的语言
vim.list_extend(opts.ensure_installed, {
  "lua", "python", "javascript", "typescript", "tsx",
  "html", "css", "json", "yaml", "bash", "markdown",
})
```

### ❌ 忘记 `additional_vim_regex_highlighting = false`

```lua
-- ❌ 坏：Treesitter 和正则同时运行，颜色冲突
opts.highlight = { enable = true }
-- additional_vim_regex_highlighting 默认可能是 true（取决于版本）

-- ✅ 正确：明确关闭正则高亮
opts.highlight = {
  enable = true,
  additional_vim_regex_highlighting = false,
}
```

### ❌ 不用 extend 模式就加新字段

```lua
-- ⚠️ 注意：添加默认没有的字段时，直接用 opts = {...} 是安全的
-- 因为默认没有 incremental_selection 字段，不会覆盖任何东西
opts = {
  incremental_selection = {
    enable = true,
    keymaps = { init_selection = "gn" },
  },
}

-- ✅ 但如果同时要 extend ensure_installed，必须用 function
opts = function(_, opts)
  vim.list_extend(opts.ensure_installed, { "lua" })
  opts.incremental_selection = {  -- 新增字段，安全
    enable = true,
    keymaps = { init_selection = "gn" },
  }
end
```

---

## 常见错误

> 概念懂了，实际操作还是会踩坑。

| 错误 | 症状 | 解决 |
|------|------|------|
| 用 `opts = {}` 覆盖 ensure_installed | 默认解析器全没了，高亮大面积失效 | 改成 `opts = function(_, opts) vim.list_extend(...)` |
| 新装的文件类型没有高亮 | 打开 .rs/.go 等文件无语法高亮 | `:TSInstall <lang>` 或加入 `ensure_installed` 列表 |
| Treesitter 和正则高亮冲突 | 同一行出现两套颜色，闪烁 | 设置 `additional_vim_regex_highlighting = false` |
| 增量选择 `gn` 按了没反应 | 按 gn 只进 visual 模式，不扩大选区 | 确认 treesitter 插件已加载，检查 `incremental_selection.enable = true` |

---

## 运行验证

本章的 `lua/plugins/treesitter.lua` 包含 extend 模式的完整示例。

```bash
cd lazyvim/11-treesitter

# 验证 init.lua（pcall guard 模式）
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
# 预期：退出码 0，无报错（pcall guard 降级为 demo message）

# 验证 treesitter.lua（return { ... } 形式）
nvim --headless -u NONE -c "luafile lua/plugins/treesitter.lua" -c 'qa!'
# 预期：退出码 0（spec table 被创建并丢弃，没有 require 依赖）
```

> 💡 **真实环境验证**：把 `lua/plugins/treesitter.lua` 复制到
> `~/.config/nvim/lua/plugins/`，运行 `:Lazy sync`，确认 spec 被识别且不覆盖默认解析器。

---

## 下一步

Treesitter 让 Neovim 理解了代码的"形状"，但它不知道代码的"含义"。
一个变量是函数参数还是全局变量？函数的返回类型是什么？这些需要 LSP。

- **第 12 章「LSP 语言服务与 Mason」**：LSP 让 Neovim 真正"懂"代码——
  跳转定义、查看引用、自动补全、诊断错误，全靠它。
- **第 13 章「补全」**：基于 LSP 和 Treesitter 的智能补全
- **第 14 章「格式化」**：代码格式化和 linting

> 💡 **本章核心**：Treesitter 是语法层（理解代码结构），LSP 是语义层（理解代码含义）。
> 两者配合才能让 Neovim 真正变成 IDE。

---

## 代码

- [`lua/init.lua`](./lua/init.lua) — pcall guard 模式（Treesitter 模块加载保护）
- [`lua/plugins/treesitter.lua`](./lua/plugins/treesitter.lua) — extend 模式 spec 示例
- [`exercises/`](./exercises/README.md) — 4 道练习题

**上一章**：[10-neo-tree](../10-neo-tree/)（Neo-tree 文件浏览器）
**下一章**：[12-lsp-mason](../12-lsp-mason/)（LSP 语言服务与 Mason）
