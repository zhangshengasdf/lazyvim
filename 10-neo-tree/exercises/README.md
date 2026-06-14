# 第10章 练习 — Neo-tree 文件管理

> 做练习前先读完 [本章 README](../README.md)。练习答案先自己想，实在不会再看 `reference/`。

---

## 练习 1：Neo-tree 文件操作

**题目**：在 Neo-tree 里执行以下操作，写出对应的快捷键：

1. 在当前目录下新建一个文件 `utils/helper.lua`
2. 删除 `temp.txt` 文件
3. 把 `old-name.lua` 重命名为 `new-name.lua`
4. 复制 `config.lua` 到 `backup/` 目录
5. 显示/隐藏 `.gitignore` 里列出的文件

**参考答案**：见 [`reference/exercise-01.md`](./reference/exercise-01.md)

---

## 练习 2：bufferline 标签页管理

**题目**：回答以下关于 bufferline 标签页的问题：

1. 如何固定一个标签，让它不会被 `<leader>bo`（关闭其他标签）关闭？
2. `]b` 和 `[b` 的作用是什么？
3. 如何关闭当前标签？
4. 如何按修改时间排序标签？
5. bufferline 和 Neo-tree 是什么关系？它们是同一个插件吗？

**参考答案**：见 [`reference/exercise-02.md`](./reference/exercise-02.md)

---

## 练习 3：Neo-tree 自定义配置

**题目**：写一个 Neo-tree spec，满足以下要求：

1. 用 `cmd` 和 `keys` 双懒加载
2. 窗口位置改为 `right`（右侧显示）
3. 窗口宽度改为 40 列
4. 显示隐藏文件（`hide_dotfiles = false`）
5. 跟随当前文件（`follow_current_file.enabled = true`）

写出完整的 `return { ... }` 格式。

**参考答案**：见 [`reference/exercise-03.md`](./reference/exercise-03.md)

---

## 练习 4：dashboard 与文件浏览器

**题目**：回答以下问题：

1. snacks.nvim 的 dashboard 和 Neo-tree 是什么关系？它们是同一个插件吗？
2. 不带参数打开 Neovim 时，dashboard 启动页的 `f` 键做什么？
3. 如果你想用 snacks.explorer 替代 Neo-tree，应该怎么做？
4. `:Neotree git_status` 命令显示什么内容？
5. Neo-tree 的三个数据源（sources）分别是什么？

**参考答案**：见 [`reference/exercise-04.md`](./reference/exercise-04.md)

---

## 如何使用本章代码

```bash
cd lazyvim/10-neo-tree

# 验证所有 Lua 文件语法
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/neo-tree.lua" -c 'qa!'
# 预期：退出码 0

# 真实环境测试（如果你装了 LazyVim）：
# cp lua/plugins/neo-tree.lua ~/.config/nvim/lua/plugins/10-neo-tree.lua
# nvim  → :Lazy sync → 按 <leader>e 测试
```

做完所有练习后，进入 [第11章 Treesitter](../11-treesitter/)，开始 Part 3「代码智能」。
