# 练习 2 参考答案 — bufferline 标签页管理

**1. 如何固定标签？**

按 `<leader>bp`。固定后的标签有特殊标记（锁图标），不会被 `<leader>bo`（关闭其他标签）关闭。

**2. `]b` 和 `[b` 的作用？**

- `]b` — 切换到下一个标签
- `[b` — 切换到上一个标签

这是 LazyVim 默认的标签切换快捷键，类似 Vim 的 `]c` / `[c`（下一个/上一个 diff）的模式。

**3. 如何关闭当前标签？**

按 `<leader>bd`。也可以用 `:bd` 命令。

**4. 如何按修改时间排序？**

按 `<leader>bsm`（bufferline sort by modification time）。

**5. bufferline 和 Neo-tree 的关系？**

它们是**完全不同的插件**，但都属于"文件导航"的范畴：
- **Neo-tree**（nvim-neo-tree/neo-tree.nvim）：左侧文件树，浏览目录结构
- **bufferline**（akinsho/bufferline.nvim）：顶部标签栏，管理打开的缓冲区

两者独立工作，互不依赖。

**回到 [练习题](../README.md)**
