# 第08章 练习 — which-key 探索式学习

> 做练习前先读完 [本章 README](../README.md)。练习答案先自己想，实在不会再看参考。

---

## 练习 1：探索式工作流实操

**题目**：假设你完全不知道 LazyVim 的快捷键，用 which-key 菜单完成以下操作。
写出你的**按键序列**（不需要记住快捷键，用 which-key 菜单"导航"到目标）。

1. 想搜索项目中的某个函数名（提示：属于"搜索"或"查找"类）
2. 想查看当前文件的 Git 修改状态（提示：属于"git"类）
3. 想关闭当前 buffer 以外的所有 buffer（提示：属于"buffer"类）
4. 想切换到暗色主题（提示：属于"UI"类）

**示例回答格式**：
```
操作：查找文件
按键：Space → 等 300ms → 看到 "f 查找" → 按 f → 看到 "f 查找文件" → 按 f
```

---

## 练习 2：注册自定义分组标签

**题目**：你定义了以下自定义快捷键：

```lua
vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "浮动终端" })
vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", { desc = "底部终端" })
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })
vim.keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "Git 状态" })
vim.keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "Git 提交" })
```

用 `wk.add()` 注册分组标签，让 which-key 菜单显示：
- `<leader>t*` 的分组名是"终端"
- `<leader>g*` 的分组名是"git"

写出完整的 `wk.add({...})` 调用。

---

## 练习 3：which-key 配置调优

**题目**：回答以下问题：

1. 你觉得 300ms 延迟太慢了，想改成 200ms。在 `setup()` 里怎么改？
2. 你只想在 Normal 模式下触发 which-key（不想在 Visual 模式弹菜单）。怎么改 `triggers`？
3. 你不想看到没有 `desc` 的映射（比如 Vim 原生的 `dd`）。which-key 默认就会过滤掉吗？
4. 你改了 `delay = 0`，结果每次按 `<Space>` 都弹菜单，打字很快也弹。这是为什么？怎么解决？

---

## 练习 4：`wk.add()` vs `vim.keymap.set`

**题目**：以下两种写法有什么区别？哪种更推荐？为什么？

**写法 A**（只用 `wk.add()`）：
```lua
wk.add({
  { "<leader>f", group = "查找" },
  { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件" },
  { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "实时 grep" },
})
```

**写法 B**（`vim.keymap.set` + `wk.add` 只加分组）：
```lua
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "查找文件" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "实时 grep" })
wk.add({
  { "<leader>f", group = "查找" },
})
```

考虑以下场景：
1. which-key 插件没装（比如你用纯 Neovim）
2. which-key 插件装了但没启用
3. which-key 正常工作

两种写法在以上场景中分别表现如何？

---

## 如何使用本章代码

```bash
cd lazyvim/08-which-key

# 验证 init.lua 语法
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
# 预期：退出码 0，打印 [demo] 消息

# 验证 plugins/which-key.lua 语法
nvim --headless -u NONE -c "luafile lua/plugins/which-key.lua" -c 'qa!'
# 预期：退出码 0

# 交互式测试（如果你装了 LazyVim）：
# cp lua/plugins/which-key.lua ~/.config/nvim/lua/plugins/08-demo.lua
# nvim  → 按 <Space> 等 300ms → 观察 which-key 菜单
```

做完所有练习后，进入 [第09章 Telescope](../09-telescope/)，学习模糊搜索神器。
