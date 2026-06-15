# 第18章 练习 — 自定义快捷键与自动命令

> 做练习前先读完 [本章 README](../README.md)。练习答案先自己想，实在不会再看 `reference/`。

---

## 练习 1：vim.keymap.set 四参数

**题目**：解释以下每个 `vim.keymap.set` 调用的四个参数分别是什么：

```lua
-- 调用 A
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "查找文件" })

-- 调用 B
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "复制到系统剪贴板" })

-- 调用 C
vim.keymap.set("n", "<leader>x", function()
  print(vim.fn.expand("%:p"))
end, { desc = "打印文件路径", silent = true })

-- 调用 D
vim.keymap.set("i", "<C-s>", function()
  vim.cmd("write")
end, { desc = "保存", buffer = true })
```

**问题**：
1. 调用 A 的 mode、lhs、rhs、opts 分别是什么？
2. 调用 B 的 mode 是什么类型？为什么用 table？
3. 调用 C 的 rhs 是什么类型？和调用 A 有什么区别？
4. 调用 D 的 opts 里 `buffer = true` 是什么意思？

**参考答案**：见 [`reference/exercise-01.md`](./reference/exercise-01.md)

---

## 练习 2：which-key 分组

**题目**：注册以下 which-key 分组，写出完整的 `vim.keymap.set` 调用：

1. `<leader>t` 组：名称为 "+终端"
2. `<leader>l` 组：名称为 "+LSP"
3. `<leader>n` 组：名称为 "+通知"

**参考答案**：见 [`reference/exercise-02.md`](./reference/exercise-02.md)

---

## 练习 3：写 keymaps.lua

**题目**：在 `lua/config/keymaps.lua` 里实现以下快捷键：

1. `<leader>sv`：水平分屏（`<cmd>vsplit<CR>`）
2. `<leader>sh`：垂直分屏（`<cmd>split<CR>`）
3. `<leader>tn`：新建 tab（`<cmd>tabnew<CR>`）
4. `<leader>tc`：关闭 tab（`<cmd>tabclose<CR>`）
5. 可视模式下 `<leader>p`：用系统剪贴板粘贴（不覆盖默认寄存器）

要求：
- 用 `vim.keymap.set`
- 每个都带 `desc`
- 用 `silent = true`（避免命令输出）

**参考答案**：见 [`reference/exercise-03.md`](./reference/exercise-03.md)

---

## 练习 4：写 autocmds.lua

**题目**：在 `lua/config/autocmds.lua` 里实现以下自动命令：

1. 打开文件时，如果行数超过 500 行，自动关闭 Treesitter 高亮（性能优化）
2. 进入插入模式时，关闭行号显示；离开时恢复
3. 保存 `.lua` 文件时，自动运行 `luacheck`（如果可用）

要求：
- 用 `augroup` 管理
- 每个都带 `desc`
- 用 `callback`（不用 `command`）

**参考答案**：见 [`reference/exercise-04.md`](./reference/exercise-04.md)

---

## 练习 5（进阶）：buffer-local 快捷键

**题目**：写一个自动命令，在 LSP 附加到 buffer 时注册以下 buffer-local 快捷键：

1. `gd`：跳转到定义（`vim.lsp.buf.definition()`）
2. `gr`：查找引用（`vim.lsp.buf.references()`）
3. `K`：悬停文档（`vim.lsp.buf.hover()`）
4. `<leader>ca`：代码操作（`vim.lsp.buf.code_action()`）
5. `<leader>rn`：重命名（`vim.lsp.buf.rename()`）

要求：
- 用 `LspAttach` 事件
- 用 `buffer = event.buf`（只对当前 buffer 生效）
- 用 `augroup` 管理
- 每个都带 `desc`

**参考答案**：见 [`reference/exercise-05.md`](./reference/exercise-05.md)

---

## 如何使用本章代码

```bash
cd lazyvim/18-custom-keymaps

# 验证所有 Lua 文件语法
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/config/keymaps.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/config/autocmds.lua" -c 'qa!'
# 预期：退出码 0

# 真实环境测试（如果你装了 LazyVim）：
# cp lua/config/keymaps.lua ~/.config/nvim/lua/config/keymaps.lua
# cp lua/config/autocmds.lua ~/.config/nvim/lua/config/autocmds.lua
# nvim  → :map <leader>  → 查看你的快捷键是否生效
```

做完所有练习后，进入 [第19章 Extras 系统](../19-extras/)。
