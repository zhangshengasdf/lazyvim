# 第09章 练习 — Telescope 模糊搜索

> 做练习前先读完 [本章 README](../README.md)。练习答案先自己想，实在不会再看 `reference/`。

---

## 练习 1：选择正确的 picker

**题目**：以下每个场景，应该用哪个 Telescope picker？写出快捷键和 picker 名称。

| 场景 | 推荐 picker | 快捷键 |
|------|-------------|--------|
| (a) 想打开 `lua/plugins/telescope.lua`，但不记得完整路径 | ? | ? |
| (b) 想找到项目里所有调用了 `vim.keymap.set` 的地方 | ? | ? |
| (c) 想快速切换到刚才编辑过的 `config.lua` | ? | ? |
| (d) 想查看 Neovim 里 `vim.lsp` 模块的帮助文档 | ? | ? |
| (e) 光标在 `require("telescope")` 上，想找所有用了这个模块的地方 | ? | ? |

**参考答案**：见 [`reference/exercise-01.md`](./reference/exercise-01.md)

---

## 练习 2：keys 懒加载 vs event 懒加载

**题目**：回答以下关于 Telescope 懒加载的问题：

1. 为什么 Telescope 用 `keys` 懒加载而不是 `event = "BufReadPost"`？
2. 如果 Telescope 用 `event = "BufReadPost"` 懒加载，会对启动时间有什么影响？
3. `keys` 字段里的 `desc` 有什么用？不写 `desc` 会怎样？
4. 按下 `<leader>ff` 后，lazy.nvim 做了哪三件事？

**参考答案**：见 [`reference/exercise-02.md`](./reference/exercise-02.md)

---

## 练习 3：fzf-native 扩展

**题目**：以下关于 `telescope-fzf-native.nvim` 的说法，哪些是正确的？

1. fzf-native 是用 Lua 实现的 fzf 排序算法
2. fzf-native 需要 C 编译器才能安装
3. 如果 fzf-native 没装成功，Telescope 会报错无法使用
4. fzf-native 的匹配算法和 `fzf` 命令行工具一样
5. `pcall(telescope.load_extension, "fzf")` 的作用是什么？

**参考答案**：见 [`reference/exercise-03.md`](./reference/exercise-03.md)

---

## 练习 4：自定义 Telescope 配置

**题目**：写一个 Telescope spec，满足以下要求：

1. 用 `keys` 懒加载，绑定 `<leader>ff` 和 `<leader>sg`
2. 修改默认布局为 `vertical`（上下排列）
3. 修改 `find_files` 使用 `fd` 命令
4. 添加文件忽略规则：忽略 `node_modules` 和 `.git`
5. 加载 fzf-native 扩展（用 pcall 保护）

写出完整的 `return { ... }` 格式。

**参考答案**：见 [`reference/exercise-04.md`](./reference/exercise-04.md)

---

## 如何使用本章代码

```bash
cd lazyvim/09-telescope

# 验证所有 Lua 文件语法
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/telescope.lua" -c 'qa!'
# 预期：退出码 0

# 真实环境测试（如果你装了 LazyVim）：
# cp lua/plugins/telescope.lua ~/.config/nvim/lua/plugins/09-telescope.lua
# nvim  → :Lazy sync → 按 <leader>ff 测试
```

做完所有练习后，进入 [第10章 Neo-tree](../10-neo-tree/)，学习文件管理。
