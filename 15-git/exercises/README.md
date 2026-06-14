# 第15章 练习 — Git 集成

> 做练习前先读完 [本章 README](../README.md)。

---

## 练习 1：选择正确的懒加载策略

**题目**：以下 Git 相关插件，应该用哪种懒加载策略？

| 插件 | 功能 | 推荐策略 | 触发条件 |
|------|------|----------|----------|
| (a) `gitsigns.nvim` | 行内 Git 标记 | ? | ? |
| (b) `lazygit.nvim` | 终端 Git GUI | ? | ? |
| (c) `vim-fugitive` | Git 命令集（`:Git` 命令） | ? | ? |
| (d) `diffview.nvim` | Diff 视图（`:DiffviewOpen` 命令） | ? | ? |
| (e) `gitlinker.nvim` | 生成 Git 链接（`<leader>gy`） | ? | ? |

**提示**：
- 需要一打开文件就显示标记的 → `event`
- 按快捷键才用的 → `keys`
- 用命令调用的 → `cmd`
- 不常用的工具 → `cmd` + `keys` 双懒加载

---

## 练习 2：写 gitsigns extend spec

**题目**：你想修改 gitsigns 的默认配置，要求：

1. 把新增行的标记符号从 `▎` 改成 `+`
2. 把修改行的标记符号从 `▎` 改成 `~`
3. 启用 `current_line_blame`（在行尾显示 blame 信息）
4. 设置 `current_line_blame_delay = 500`（延迟 500ms 显示）

写出完整的 spec，要求用 extend 模式（`opts = function`）。

**参考答案要点**：
- 用 `opts = function(_, opts) ... end`
- 用 `vim.tbl_deep_extend("force", opts.signs or {}, {...})` 扩展 signs
- `current_line_blame` 和 `current_line_blame_delay` 直接赋值（新字段，不覆盖）

---

## 练习 3：git blame vs LazyGit 使用场景

**题目**：以下场景，应该用 gitsigns（`<leader>gh*`）还是 LazyGit（`<leader>gg`）？

| 场景 | 用哪个？ |
|------|----------|
| (a) 看当前行是谁改的 | ? |
| (b) 暂存当前 hunk | ? |
| (c) 创建新分支 | ? |
| (d) 交互式 rebase 最近 3 个 commit | ? |
| (e) 还原当前 hunk 的改动 | ? |
| (f) 解决合并冲突 | ? |
| (g) 预览当前 hunk 的 diff | ? |
| (h) 查看完整提交历史 | ? |

---

## 练习 4（进阶）：自定义 hunk 操作快捷键

**题目**：你想用 `<leader>ghn` 和 `<leader>ghp` 代替默认的 `]c` 和 `[c` 来跳转 hunk。
写出 `opts = function` 里的 on_attach 实现。

**要求**：
- `<leader>ghn` 跳转到下一个 hunk
- `<leader>ghp` 跳转到上一个 hunk
- 用 `vim.keymap.set`，带 `desc`
- 处理 diff 模式（`vim.wo.diff`）的特殊情况

**提示**：参考 `lua/plugins/git.lua` 里的 on_attach 示例。

---

## 如何使用本章代码

```bash
cd lazyvim/15-git

# 验证所有 Lua 文件语法
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/git.lua" -c 'qa!'
# 预期：退出码 0

# 真实环境测试（如果你装了 LazyVim）：
# cp lua/plugins/git.lua ~/.config/nvim/lua/plugins/15-git.lua
# nvim  → 打开一个 Git 仓库里的文件 → 观察行号栏标记
```

做完所有练习后，进入 [第16章 调试器 DAP](../16-dap/)。
