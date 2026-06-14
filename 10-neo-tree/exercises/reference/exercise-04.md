# 练习 4 参考答案 — dashboard 与文件浏览器

**1. snacks.nvim dashboard 和 Neo-tree 的关系？**

它们是**完全不同的东西**：
- **Neo-tree**（nvim-neo-tree/neo-tree.nvim）：文件树插件，左侧显示目录结构
- **snacks.nvim dashboard**（folke/snacks.nvim 的 dashboard 模块）：启动页，不带参数打开 Neovim 时显示 ASCII art + 快捷入口

两者独立，但都属于 LazyVim 的默认配置。

**2. dashboard 的 `f` 键做什么？**

打开 Telescope 的 `find_files` picker（查找文件）。和按 `<leader>ff` 效果一样。

**3. 如何用 snacks.explorer 替代 Neo-tree？**

在 LazyVim extras 里启用 `snacks.explorer`（运行 `:LazyExtras`，搜索 `explorer`）。
启用后，LazyVim 会自动禁用 Neo-tree，并把 `<leader>e` 绑定到 snacks.explorer。

**4. `:Neotree git_status` 显示什么？**

显示所有有 Git 变更的文件：
- `` — 已暂存（staged）
- `` — 未暂存（unstaged）
- `✖` — 已删除（deleted）
- `` — 未跟踪（untracked）
- `` — 冲突（conflict）

**5. Neo-tree 的三个数据源是什么？**

1. **filesystem** — 文件系统（默认，显示目录树）
2. **buffers** — 缓冲区列表（显示所有打开的 buffer）
3. **git_status** — Git 状态（显示有变更的文件）

**回到 [练习题](../README.md)**
