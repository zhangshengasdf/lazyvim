# 第16章 调试器 DAP — 在 Neovim 里断点调试

> **print("here")** — 你在代码里打了多少个这样的调试语句？
> 改一行，保存，运行，看输出，删掉 print，再改……循环往复？
> 断点调试能让你在任意位置暂停程序，查看变量、调用栈、逐行执行，
> 比 print 调试快 10 倍。本章把 VS Code 的调试体验搬进 Neovim。

---

## TL;DR

> **30 秒速读**：DAP 是调试协议，nvim-dap 是客户端，debugpy/js-debug 是语言适配器，三者配合才能断点调试。
> 
> **如果只记一件事**：用 `keys` 懒加载 nvim-dap，调试适配器（debugpy 等）必须单独安装，nvim-dap 本身只是协议客户端。

---

## 本章目标

学完本章，你将能够：

1. **理解 DAP 协议**：为什么需要一个通用协议，而不是每个语言写一套调试器
2. **用 `<leader>db` 设断点**：在当前行插入/删除断点
3. **用 `<leader>dc`/`<leader>dn`/`<leader>di` 控制执行**：继续、步过、步入
4. **查看变量和调用栈**：在调试会话中检查程序状态
5. **配置 dap-ui**：自动打开调试面板，不用手动开窗口
6. **配置 debugpy 和 node-debugger**：Python 和 TypeScript 的调试适配器

> ⚠️ **前置条件**：完成第 06 章（理解 lazy.nvim spec 格式）。不需要 DAP 或调试协议的前置知识。

---

## DAP 是什么

### 从 print 到断点

调试代码有两种方式：

```
print 调试：                          断点调试：
  改代码加 print                        设断点
  保存                                  运行调试
  运行                                  程序在断点暂停
  看输出                                查看变量/调用栈
  删 print                              逐行执行
  重复……                                继续运行
```

print 调试的问题：改代码、污染输出、忘记删 print、无法查看复杂对象。
断点调试的优势：不改代码、暂停时查看一切、逐行执行追踪逻辑。

### DAP 协议

**DAP**（Debug Adapter Protocol）是微软定义的调试协议，和 LSP 是同一家族：

```
LSP  →  让编辑器和语言服务器对话（补全、跳转、诊断）
DAP  →  让编辑器和调试适配器对话（断点、单步、变量查看）
```

架构图：

```
┌─────────────┐      DAP 协议      ┌──────────────┐      调试协议      ┌──────────┐
│   Neovim    │ ←────────────────→ │  调试适配器   │ ←────────────────→ │  运行时   │
│  (nvim-dap) │    JSON-RPC        │ (debugpy等)  │    各语言私有       │ (Python等)│
└─────────────┘                    └──────────────┘                    └──────────┘
```

关键点：**nvim-dap 只实现 DAP 协议**，具体怎么调试 Python、怎么调试 TypeScript，
由**调试适配器**（debug adapter）负责。你需要为每种语言安装对应的适配器。

| 语言 | 调试适配器 | 安装方式 |
|------|-----------|----------|
| Python | debugpy | `pip install debugpy` 或 Mason |
| TypeScript/JavaScript | js-debug (node-debugger) | Mason 自动安装 |
| Go | delve | `go install github.com/go-delve/delve/cmd/dlv@latest` |
| Rust | codelldb | Mason 自动安装 |
| Lua | 无需适配器 | nvim-dap 内置 |

> 💡 你不需要理解 DAP 协议的 JSON-RPC 细节。知道"nvim-dap 是客户端，debug adapter 是服务端"就够了。

---

## 断点操作

### 设置断点：`<leader>db`

在当前行按 `<leader>db`（debug breakpoint），会切换断点：

- 没有断点 → 插入断点（行号栏显示红色圆点 ●）
- 已有断点 → 删除断点

```
行号栏
  42 │●  local result = process(data)    ← 断点在这行
  43 │   print(result)
  44 │●  return result                   ← 断点在这行
```

> 💡 断点信息存在 Neovim 内存里，不影响源代码文件。

### 条件断点

有时候你只想在特定条件下暂停——比如循环到第 100 次时。
按 `<leader>dB`（大写 B）设置条件断点，输入 Lua 表达式：

```
条件: i == 100
```

程序运行到这行时，只有 `i == 100` 为真才会暂停。

---

## 执行控制

程序运行后，你需要控制它的执行流程。LazyVim 的快捷键：

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `<leader>dc` | 继续（Continue） | 运行到下一个断点或程序结束 |
| `<leader>dn` | 步过（Next） | 执行当前行，跳到下一行（不进入函数内部） |
| `<leader>di` | 步入（Step Into） | 如果当前行是函数调用，进入函数内部 |
| `<leader>do` | 步出（Step Out） | 从当前函数返回到调用处 |
| `<leader>dp` | 暂停（Pause） | 暂停正在运行的程序 |
| `<leader>dr` | 打开 REPL | 打开调试 REPL，可以输入表达式求值 |
| `<leader>dl` | 运行到最后 | 运行到光标所在行 |
| `<leader>dt` | 终止（Terminate） | 结束调试会话 |

### 执行流程图

```
设断点 (<leader>db)
    │
    ▼
启动调试 (<leader>dc 或配置的启动键)
    │
    ▼
程序在断点暂停
    │
    ├── <leader>dn  步过 → 执行当前行，停在下一行
    ├── <leader>di  步入 → 进入函数内部
    ├── <leader>do  步出 → 从函数返回
    ├── <leader>dc  继续 → 运行到下一个断点
    └── <leader>dt  终止 → 结束调试
```

---

## 变量查看与调用栈

### 变量查看

程序暂停时，dap-ui 会自动显示当前作用域的变量：

```
┌─ Scopes ──────────────────────┐
│ Local                         │
│   i = 42                      │
│   name = "hello"              │
│   result = { a = 1, b = 2 }   │
│   items = [1, 2, 3, 4, 5]    │
│ Global                        │
│   _VERSION = "Lua 5.1"        │
└───────────────────────────────┘
```

你也可以在 REPL 里输入表达式求值：

```lua
> print(result.a)
1
> vim.inspect(items)
{ 1, 2, 3, 4, 5 }
```

### 调用栈

调用栈显示函数调用链——从当前函数一路回溯到入口：

```
┌─ Stack ───────────────────────┐
│ > process()     main.lua:42   │ ← 当前在这里
│   handle()      main.lua:28   │ ← process() 被 handle() 调用
│   main()        main.lua:10   │ ← handle() 被 main() 调用
└───────────────────────────────┘
```

点击调用栈的任意一层，可以跳转到那个函数的上下文，查看那个时刻的变量。

---

## dap-ui：可视化调试面板

没有 dap-ui，你需要手动用命令打开变量窗口、调用栈窗口、REPL 窗口。
有了 dap-ui，启动调试时自动弹出面板，结束时自动关闭。

LazyVim 默认集成了 nvim-dap-ui，你通常不需要额外配置。

### dap-ui 布局

启动调试后，dap-ui 自动在代码窗口周围打开辅助面板：左侧显示 Scopes（变量）和 Stack（调用栈），底部显示 REPL（表达式求值）。关闭调试时自动消失。

---

## Python 调试示例（debugpy）

### 安装

```bash
# 方法 1：pip 安装
pip install debugpy

# 方法 2：Mason 安装（推荐，LazyVim 集成）
# 在 Neovim 中运行 :Mason，搜索 debugpy，按 i 安装
```

### 配置

LazyVim 的 Python Extra 已包含 debugpy 配置。手动配置时，在 `lua/plugins/dap.lua` 的 nvim-dap dependencies 里加 `"mfussenegger/nvim-dap-python"`，然后调 `dap_python.setup("python")`。完整示例见本章 spec 文件。

### 调试 Python 文件

用一个简单的 Python 文件测试：设断点 → `<leader>dc` 启动 → 查看 Scopes 面板里的变量 → `<leader>dn` 步过 → `<leader>dc` 继续运行。

---

## TypeScript 调试示例（js-debug）

安装：运行 `:Mason`，搜索 `js-debug-adapter`，按 `i` 安装。

配置原理和 Python 一样：`nvim-dap` + 语言专属适配器（`nvim-dap-vscode-js`）。
具体 spec 见本章 `lua/plugins/dap.lua`。

调试流程和 Python 完全相同：设断点 → 启动调试 → 查看变量 → 逐行执行。

---

## spec 格式详解

### nvim-dap spec 结构

完整的 spec 见 [`lua/plugins/dap.lua`](./lua/plugins/dap.lua)。核心结构：

```lua
{
  "mfussenegger/nvim-dap",
  dependencies = {
    { "rcarriga/nvim-dap-ui", ... },      -- 可视化面板
    { "mfussenegger/nvim-dap-python" },   -- Python 适配器（可选）
  },
  keys = {
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: 切换断点" },
    { "<leader>dc", function() require("dap").continue() end,          desc = "DAP: 继续" },
    -- 更多快捷键...
  },
}
```

### 为什么 nvim-dap 用 `keys` 懒加载？

DAP 只在调试时才用。用 `keys` 懒加载意味着：
- 不按调试快捷键 → 不加载，启动速度不受影响
- 按了 `<leader>db` → 立即加载 nvim-dap 和所有依赖

这比 `event = "BufReadPost"` 更合理——你不需要每次打开文件都加载调试器。

### dap-ui 为什么需要 `nvim-neotest/nvim-nio`？

nvim-nio 是一个异步 IO 库，dap-ui 用它来处理异步的 DAP 事件。
没有它，dap-ui 会报错。这是依赖关系，不需要你深入了解。

---

## 反模式（什么不该做）

### ❌ 用 `lazy = false` 加载 nvim-dap

```lua
-- ❌ 坏：启动时就加载调试器，浪费 30-50ms
{ "mfussenegger/nvim-dap", lazy = false }

-- ✅ 正确：用 keys 懒加载
{ "mfussenegger/nvim-dap", keys = { "<leader>db", "<leader>dc" } }
```

调试器是按需使用的工具。90% 的时间你不需要它，没必要拖慢启动。

### ❌ 不给调试快捷键写 desc

```lua
-- ❌ 坏：which-key 里只显示按键
keys = { "<leader>db", "<leader>dc" }

-- ✅ 正确：带 desc
keys = {
  { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: 切换断点" },
  { "<leader>dc", function() require("dap").continue() end,          desc = "DAP: 继续" },
}
```

### ❌ 忘记配置 dap-ui 的自动打开/关闭

```lua
-- ❌ 坏：只装了 dap-ui，没配置自动打开
{ "rcarriga/nvim-dap-ui", opts = {} }

-- ✅ 正确：配置 listeners 让 dap-ui 自动响应调试事件
config = function(_, opts)
  local dapui = require("dapui")
  dapui.setup(opts)
  local dap = require("dap")
  dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
  dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
  dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
end
```

### ❌ 不安装调试适配器就用 nvim-dap

```lua
-- ❌ 坏：装了 nvim-dap，但没装 debugpy/js-debug
-- 按 <leader>dc 会报错：no adapter found for python

-- ✅ 正确：nvim-dap + 调试适配器一起配
{
  "mfussenegger/nvim-dap",
  dependencies = {
    "mfussenegger/nvim-dap-python",  -- Python 适配器
  },
}
```

nvim-dap 只是 DAP 协议的客户端，没有适配器它无法连接任何运行时。

### ❌ 用 `event = "BufReadPost"` 加载 nvim-dap

```lua
-- ❌ 坏：每次打开文件都加载调试器
{ "mfussenegger/nvim-dap", event = "BufReadPost" }

-- ✅ 正确：用 keys 懒加载（调试时才需要）
{ "mfussenegger/nvim-dap", keys = { "<leader>db" } }
```

调试器和 gitsigns 不同。gitsigns 需要打开文件就显示标记，
调试器只有你主动设断点/启动调试时才需要。

## 常见错误

> 概念懂了，实际操作还是会踩坑。

| 错误 | 症状 | 解决 |
|------|------|------|
| 没装调试适配器就用 nvim-dap | 按 `<leader>dc` 报 "no adapter found" | `:Mason` 安装 debugpy 或 js-debug-adapter |
| 断点设了但程序没停 | 代码直接跑完，红点形同虚设 | 确认用 `<leader>dc` 启动调试（不是 `:Run`），且适配器已安装 |
| dap-ui 面板没弹出来 | 调试启动了但看不到变量/调用栈 | 检查是否配了 `dap.listeners` 自动 open（见反模式第 3 条） |
| 条件断点不生效 | 输入 `i == 100` 但每次都在这行停 | 条件表达式语言要匹配运行时（Python 用 Python 语法，Lua 用 Lua 语法） |

---

## 运行验证

本章的 Lua 文件可以独立验证语法：

```bash
cd lazyvim/16-dap

# 验证 init.lua（pcall guard，没装插件也能跑）
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
# 预期：退出码 0，输出 [demo] 消息

# 验证 dap.lua（return table，语法检查）
nvim --headless -u NONE -c "luafile lua/plugins/dap.lua" -c 'qa!'
# 预期：退出码 0
```

> 💡 **真实环境验证**：
> 1. 复制 `lua/plugins/dap.lua` 到 `~/.config/nvim/lua/plugins/`
> 2. 运行 `:Lazy sync` 安装 nvim-dap 和依赖
> 3. 运行 `:Mason` 安装 debugpy（Python）或 js-debug-adapter（TypeScript）
> 4. 打开一个 Python/TS 文件，按 `<leader>db` 设断点
> 5. 按 `<leader>dc` 启动调试，dap-ui 应该自动弹出

---

## 下一步

本章你学会了 DAP 调试的完整工作流：

- **DAP 协议**：nvim-dap（客户端）+ debug adapter（服务端）
- **断点**：`<leader>db` 设断点，条件断点 `<leader>dB`
- **执行控制**：继续/步过/步入/步出
- **变量查看**：dap-ui 自动显示 Scopes、Stack、REPL
- **语言适配**：Python 用 debugpy，TypeScript 用 js-debug

回顾 Part 4（开发工作流），你现在已经具备：

- **第 15 章**：Git 集成（gitsigns 行内标记 + LazyGit GUI）
- **第 16 章**：DAP 调试（断点 + 单步 + 变量查看 + dap-ui）

下一章进入 **Part 5（定制扩展）**：

- **第 17 章「插件配置模式」**：如何读懂和写复杂插件的 spec
- **第 18 章「自定义快捷键」**：打造属于你的键位体系
- **第 19 章「Extras」**：LazyVim 的可选扩展包

> 💡 **本章核心**：nvim-dap 用 `keys` 懒加载（调试时才用，不要拖慢启动）。
> 调试适配器（debugpy、js-debug）必须单独安装，nvim-dap 本身只是 DAP 客户端。
> dap-ui 的自动打开/关闭通过 `dap.listeners` 实现。

---

## 代码

- [`lua/init.lua`](./lua/init.lua) — pcall guard 教学示例
- [`lua/plugins/dap.lua`](./lua/plugins/dap.lua) — DAP + dap-ui spec
- [`exercises/`](./exercises/README.md) — 5 道练习题

**上一章**：[15-git](../15-git/)（Git 集成）
**下一章**：[17-plugin-patterns](../17-plugin-patterns/)（插件配置模式）
