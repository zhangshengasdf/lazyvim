# 第19章 练习 — Extras 系统

> 做练习前先读完 [本章 README](../README.md)。练习答案先自己想，实在不会再看 `reference/`。

---

## 练习 1：理解 import 机制

**题目**：回答以下问题：

1. `{ import = "lazyvim.plugins.extras.lang.python" }` 这行做了什么？
2. import 进来的 spec 和你自己的 spec 会怎么合并？
3. 如果 import 的 Extra 里有 `opts = { ensure_installed = { "python" } }`，而你自己的 spec 也有 `opts = { ensure_installed = { "rust" } }`，最终结果是什么？
4. 如果 Extra 里用的是 `opts = function(_, opts) vim.list_extend(opts.ensure_installed, { "python" }) end`，结果又是什么？

**参考答案**：见 [`reference/exercise-01.md`](./reference/exercise-01.md)

---

## 练习 2：启用语言支持

**题目**：你想让 LazyVim 支持以下语言，写出完整的 `lua/plugins/extras.lua`：

1. Python（LSP + 格式化 + 调试）
2. Rust（LSP + 格式化 + 调试）
3. Go（LSP + 格式化 + 调试）
4. TypeScript（LSP + 格式化）
5. Lua（LSP + 格式化）

要求：
- 用 `import` 语句
- 返回格式：`return { ... }`
- 加中文注释说明每个 Extra 包含什么

**参考答案**：见 [`reference/exercise-02.md`](./reference/exercise-02.md)

---

## 练习 3：写自定义 Extra

**题目**：为 Zig 语言创建一个自定义 Extra，文件位置：`lua/plugins/extras/lang/zig.lua`

要求包含：
1. Treesitter 解析器（`zig`）
2. LSP 服务器（`zls`）
3. 格式化工具（`zigfmt`）
4. 用 extend 模式（不要覆盖 LazyVim 默认值）

然后在 `lua/plugins/extras.lua` 里 import 它。

**参考答案**：见 [`reference/exercise-03.md`](./reference/exercise-03.md)

---

## 练习 4：Extra 冲突与覆盖

**题目**：回答以下问题：

1. 你同时启用了 `ai.copilot` 和 `ai.codeium`，会发生什么？为什么？
2. Extra 里启用了 pyright LSP，但你想把 `typeCheckingMode` 改为 `"strict"`。怎么做？
3. 你想禁用某个 Extra 里的某个插件（比如 Extra 启用了 indent-blankline，但你不想要）。怎么做？
4. Extra 和你自己的 spec 谁的优先级更高？为什么？

**参考答案**：见 [`reference/exercise-04.md`](./reference/exercise-04.md)

---

## 如何使用本章代码

```bash
cd lazyvim/19-extras

# 验证所有 Lua 文件语法
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/extras.lua" -c 'qa!'
# 预期：退出码 0

# 真实环境测试（如果你装了 LazyVim）：
# cp lua/plugins/extras.lua ~/.config/nvim/lua/plugins/19-demo.lua
# nvim  → :LazyExtras → 查看可用的 Extras
# nvim  → :Lazy sync → 观察 import 的 Extra 是否被正确加载
```

做完所有练习后，进入 [第20章 性能优化与健康检查](../20-performance/)。
