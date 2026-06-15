# 第16章 练习 — 调试器 DAP

> 做练习前先读完 [本章 README](../README.md)。

---

## 练习 1：DAP 架构理解

**题目**：回答以下关于 DAP 架构的问题：

1. DAP 和 LSP 有什么共同点？（提示：都是协议）
2. nvim-dap 是客户端还是服务端？它能直接调试 Python 吗？
3. 为什么需要单独安装 debugpy？nvim-dap 不自带吗？
4. nvim-dap-ui 的作用是什么？没有它能不能调试？

**参考答案要点**：
- DAP 和 LSP 都是微软定义的编辑器协议
- nvim-dap 是客户端，不能直接调试 Python，需要 debugpy 适配器
- nvim-dap 只实现 DAP 协议，不包含具体语言的调试逻辑
- dap-ui 是可选的可视化面板，没有它也能调试（用命令操作）

---

## 练习 2：选择正确的懒加载策略

**题目**：以下调试相关插件，应该用哪种懒加载策略？

| 插件 | 功能 | 推荐策略 | 触发条件 |
|------|------|----------|----------|
| (a) `nvim-dap` | DAP 客户端 | ? | ? |
| (b) `nvim-dap-ui` | 调试 UI 面板 | ? | ? |
| (c) `nvim-dap-python` | Python 调试适配器 | ? | ? |
| (d) `gitsigns.nvim` | Git 行内标记（对比） | ? | ? |
| (e) `lazygit.nvim` | Git GUI（对比） | ? | ? |

**提示**：
- nvim-dap 和 gitsigns 的懒加载策略为什么不同？
- nvim-dap-ui 应该作为 nvim-dap 的 dependency 还是独立加载？

---

## 练习 3：写 nvim-dap spec

**题目**：你想配置一个精简的 DAP 环境，要求：

1. nvim-dap 用 `keys` 懒加载
2. 只配置 3 个快捷键：断点（`<leader>db`）、继续（`<leader>dc`）、步过（`<leader>dn`）
3. 所有快捷键带 `desc`
4. 不配置 dap-ui（你想用纯命令行调试）

写出完整的 `return { ... }` spec。

**参考答案要点**：
- `keys` 字段包含 3 个 table，每个有 lhs、rhs、desc
- rhs 用 `function() require("dap").xxx() end` 形式
- 不需要 dependencies（不装 dap-ui）

---

## 练习 4：调试流程排错

**题目**：以下调试场景出了问题，找出原因：

**场景 A**：按 `<leader>db` 设断点，行号栏没有出现红色圆点。

可能原因：
1. ?
2. ?

**场景 B**：设了断点，按 `<leader>dc` 启动调试，报错 "no adapter found for python"。

可能原因：
1. ?
2. ?

**场景 C**：调试启动了，但没有自动弹出 dap-ui 面板。

可能原因：
1. ?
2. ?

**参考答案要点**：
- A：nvim-dap 没加载（keys 懒加载没触发）、文件不在 Git 仓库里
- B：没装 debugpy、没配置 dap-python
- C：没装 nvim-dap-ui、没配置 listeners 自动打开

---

## 练习 5（进阶）：调试 vs print 调试

**题目**：以下场景，你会用断点调试还是 print 调试？为什么？

| 场景 | 用哪个？ | 原因 |
|------|----------|------|
| (a) 循环到第 1000 次时出 bug | ? | ? |
| (b) 快速确认一个变量的值 | ? | ? |
| (c) 追踪函数调用链（A→B→C→D） | ? | ? |
| (d) 调试一个异步回调函数 | ? | ? |
| (e) 在远程服务器上调试 | ? | ? |

**提示**：
- 条件断点适合 (a)
- print 适合 (b)（快，不需要启动调试器）
- 调用栈面板适合 (c)
- 异步调试需要 DAP 支持（有些适配器不支持）
- 远程调试需要 remote attach 配置

---

## 如何使用本章代码

```bash
cd lazyvim/16-dap

# 验证所有 Lua 文件语法
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/dap.lua" -c 'qa!'
# 预期：退出码 0

# 真实环境测试（如果你装了 LazyVim）：
# cp lua/plugins/dap.lua ~/.config/nvim/lua/plugins/16-dap.lua
# nvim  → :Lazy sync → :Mason (装 debugpy) → 打开 .py 文件 → <leader>db → <leader>dc
```

做完所有练习后，进入 [第17章 插件配置模式](../17-plugin-patterns/)，开始 Part 5「定制扩展」。
