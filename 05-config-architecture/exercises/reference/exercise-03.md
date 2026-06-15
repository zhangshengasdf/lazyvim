# 练习 3 参考答案 — 创建 config 文件

## options.lua

```lua
-- lua/config/options.lua
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.g.mapleader = " "
```

## keymaps.lua

```lua
-- lua/config/keymaps.lua
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "保存文件" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "跳到左窗口" })
```

## 验证命令

```bash
cd lazyvim/05-config-architecture
nvim --headless -u NONE \
  -c "luafile lua/config/options.lua" \
  -c "luafile lua/config/keymaps.lua" \
  -c "lua verify = dofile('../shared/verify.lua')" \
  -c "lua verify.run({
        {fn = verify.check_opt, args = {'number', true}},
        {fn = verify.check_opt, args = {'tabstop', 4}},
        {fn = verify.check_keymap, args = {'n', '<leader>w'}},
      })" \
  -c 'qa!'
```

## 预期输出

```
=== Verification Summary ===
  OK  vim.o.number = true (OK)
  OK  vim.o.tabstop = 4 (OK)
  OK  [n] <leader>w -> 保存文件 (OK)

Total: 3 | Passed: 3 | Failed: 0
RESULT: ALL CHECKS PASSED
```

## 易错点

1. **`vim.g.mapleader` 不能用 `vim.opt`**：全局变量用 `vim.g`，选项用 `vim.opt`。
2. **`<leader>w` 必须在设 `mapleader` 之后定义**：否则 leader 还是默认的 `\`。
3. **`{ desc = "..." }` 不能省**：which-key 需要这个字段显示描述。

**回到 [练习题](../README.md)**
