# 第07章 练习 — Leader 键体系与核心快捷键

> 做练习前先读完 [本章 README](../README.md)。练习答案先自己想，实在不会再看参考。

---

## 练习 1：Leader 前缀分类

**题目**：以下操作属于哪个 Leader 前缀组？填入正确的前缀字母。

| 操作 | 前缀 | 完整快捷键 |
|------|------|------------|
| 查找文件 | ? | `<leader>?f` |
| Git blame | ? | `<leader>?b` |
| 代码重命名 | ? | `<leader>?r` |
| 切换主题 | ? | `<leader>?t` |
| 关闭当前 buffer | ? | `<leader>?d` |
| 搜索当前光标下的词 | ? | `<leader>?w` |

**提示**：参考本章 README 的「6 大前缀速查表」。

---

## 练习 2：注册自定义 Leader 快捷键

**题目**：用 `vim.keymap.set` 注册以下快捷键，写出完整代码：

1. `<leader>fn` — 在当前目录新建文件（提示：用 `:enew` 命令）
2. `<leader>cp` — 复制当前文件的完整路径到系统剪贴板（提示：用 `vim.fn.expand("%:p")`）
3. `<leader>tw` — 切换自动换行（提示：`vim.opt.wrap`）

要求：
- 用 `vim.keymap.set`（不用 `vim.api.nvim_set_keymap`）
- 每个都带 `desc` 字段
- 第 2 题和第 3 题用 Lua function 作为 rhs

---

## 练习 3：Buffer 和窗口操作

**题目**：回答以下问题（不需要写代码，回答操作即可）：

1. 你打开了 5 个文件，当前显示第 3 个。按什么键切换到第 2 个？按什么键切换到第 4 个？
2. 你用 `:vsplit` 分了左右两个窗口。按什么键从左边窗口跳到右边窗口？
3. 你想关闭当前 buffer 但不关闭窗口（保留窗口布局）。按什么？
4. 你按了 `<C-l>` 但没有窗口切换，屏幕反而闪了一下。发生了什么？

---

## 练习 4：Leader 键的加载顺序

**题目**：以下代码有 bug，找出问题并修正：

```lua
-- my-config/init.lua
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "保存文件" })
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "查找文件" })
-- ... 50 个 <leader> 快捷键 ...

vim.g.mapleader = " "  -- 设 Leader 为空格
```

1. 这段代码有什么问题？
2. `<leader>w` 实际会绑定到什么键？
3. 正确的顺序应该是什么？

---

## 练习 5（进阶）：设计你自己的前缀体系

**题目**：假设你要给 LazyVim 添加一个新的前缀组 `<leader>t`（terminal，终端相关），
包含以下操作：

- `<leader>tt` — 打开/关闭浮动终端
- `<leader>tf` — 打开/关闭底部终端
- `<leader>tg` — 在终端中运行 `lazygit`
- `<leader>tn` — 在终端中运行 `node`

用 `vim.keymap.set` 写出完整的注册代码。每个快捷键都带 `desc`。
终端命令用 `<cmd>ToggleTerm<CR>` 或 Lua function 包裹 `vim.fn.system()`。

---

## 如何使用本章代码

```bash
cd lazyvim/07-leader-keys

# 验证 init.lua 语法
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
# 预期：退出码 0，打印 demo 消息

# 交互式测试（如果你装了 LazyVim）：
# nvim -u lua/init.lua some-file.txt
# 按 <Space> 等 300ms，观察 which-key 是否弹出
# 按 <S-h> / <S-l> 测试 buffer 切换
# 按 <C-h> / <C-l> 测试窗口导航（先 :vsplit 分屏）
```

做完所有练习后，进入 [第08章 which-key](../08-which-key/)，学习快捷键探索神器。
