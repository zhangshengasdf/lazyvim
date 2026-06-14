# 第06章 练习 — lazy.nvim 插件管理器

> 做练习前先读完 [本章 README](../README.md)。练习答案先自己想，实在不会再看 `reference/`。

---

## 练习 1：选择正确的懒加载策略

**题目**：以下每个插件，应该用 `event`、`ft`、`keys`、`cmd` 哪种懒加载？还是不懒加载？

| 插件 | 功能 | 推荐策略 | 触发条件 |
|------|------|----------|----------|
| (a) `nvim-treesitter` | 语法高亮 | ? | ? |
| (b) `telescope.nvim` | 模糊搜索 | ? | ? |
| (c) `gitsigns.nvim` | Git 状态标记（行内 +xx） | ? | ? |
| (d) `rust-tools.nvim` | Rust 专属 LSP 工具 | ? | ? |
| (e) `lazygit.nvim` | Git GUI（`:LazyGit` 命令） | ? | ? |
| (f) `tokyonight.nvim` | 配色主题 | ? | ? |
| (g) `nvim-lspconfig` | LSP 配置 | ? | ? |

**参考答案**：见 [`reference/exercise-01.md`](./reference/exercise-01.md)

---

## 练习 2：写 spec（基本模式）

**题目**：为以下插件写一个基本 spec：

1. **tokyonight.nvim**（配色插件）
   - 地址：`folke/tokyonight.nvim`
   - 选项：`style = "moon"`, `transparent = true`
   - 要求：不懒加载，优先加载（`priority = 1000`）

2. **vim-fugitive**（Git 命令行工具）
   - 地址：`tpope/vim-fugitive`
   - 要求：用 `cmd` 懒加载，触发命令：`"Git"`, `"G"`, `"Gvdiffsplit"`

写出完整的 `return { ... }` 格式。

**参考答案**：见 [`reference/exercise-02.md`](./reference/exercise-02.md)

---

## 练习 3：extend vs overwrite（核心练习）

**题目**：以下是某用户的 `lua/plugins/none-ls.lua`，他想给 none-ls 追加几个内置源（builtins）。
这个配置有**错误**，找出并改正：

```lua
-- 错误配置
return {
  {
    "nvimtools/none-ls.nvim",
    opts = {
      sources = {
        require("null-ls").builtins.formatting.stylua,
        require("null-ls").builtins.formatting.prettier,
      },
    },
  },
}
```

**问题**：
1. 这个配置哪里错了？（提示：LazyVim 默认有 none-ls 的 sources 配置吗？如果用 table 会怎样？）
2. 写出正确的 extend 版本。
3. 如果这个插件 LazyVim **没有默认配置**（你新增的），上面的错误版本还能用吗？为什么？

**参考答案**：见 [`reference/exercise-03.md`](./reference/exercise-03.md)

---

## 练习 4：完整 spec 设计

**题目**：你要装一个叫 `markdown-preview.nvim` 的插件，需求如下：

- 地址：`iamcco/markdown-preview.nvim`
- 功能：Markdown 实时预览（在浏览器打开预览页面）
- 用法：在 `.md` 文件里按 `<leader>mp` 打开预览
- 构建命令：`cd app && npm install`（安装后需要跑一次）
- 只在打开 Markdown 文件时才有用

写出完整的 spec，要求：
1. 用正确的懒加载策略
2. 绑定 `<leader>mp` 快捷键（带 desc）
3. 设置 build 命令
4. 返回格式：`return { ... }`

**参考答案**：见 [`reference/exercise-04.md`](./reference/exercise-04.md)

---

## 练习 5（进阶）：`:Lazy` 命令实战

**题目**：回答以下关于 `:Lazy` 命令的问题：

1. 你改了 `lua/plugins/example.lua`，加了一个新插件。重启 Neovim 后，应该运行哪个命令来安装它？
2. 你觉得 Neovim 启动变慢了，想看哪个插件最耗时。运行哪个命令？
3. 队友在 GitHub push 了新的 `lazy-lock.json`，你 pull 后应该运行哪个命令保证版本一致？
4. `:Lazy sync` 等价于哪三个命令的组合？
5. 你想完全禁用 LazyVim 默认的某个插件（比如 mini.animate），不改 LazyVim 源码。怎么做到？

**参考答案**：见 [`reference/exercise-05.md`](./reference/exercise-05.md)

---

## 如何使用本章代码

```bash
cd lazyvim/06-lazy-nvim

# 验证所有 Lua 文件语法
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/example.lua" -c 'qa!'
# 预期：退出码 0

# 真实环境测试（如果你装了 LazyVim）：
# cp lua/plugins/example.lua ~/.config/nvim/lua/plugins/06-demo.lua
# nvim  → :Lazy sync → 观察 spec 是否被识别
```

做完所有练习后，进入 [第07章 Leader 键体系](../07-leader-keys/)，开始 Part 2「核心工作流」。
