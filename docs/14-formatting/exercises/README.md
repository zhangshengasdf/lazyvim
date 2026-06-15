# 第14章 练习 — 格式化与代码检查

> 做练习前先读完 [本章 README](../README.md)。练习答案先自己想，实在不会再看参考。

---

## 练习 1：格式化器配置

**题目**：以下配置有错误，找出并改正：

```lua
-- 错误配置
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
      },
    },
  },
}
```

**问题**：
1. 这个配置哪里错了？（提示：LazyVim 默认有 conform.nvim 的 formatters_by_ft 配置吗？）
2. 改正后，JavaScript/TypeScript 的格式化器还在吗？
3. 如果你想给 Lua 追加一个 `luafmt` 格式化器（在 stylua 之后执行），应该怎么做？

---

## 练习 2：linter 配置

**题目**：你想给 Python 文件添加 `ruff` linter（比 pylint 更快）。

已知：
- linter 名称：`ruff`
- 应该追加到默认的 pylint 后面（不覆盖）

写出完整的 spec，要求：
1. 用 extend 模式（不覆盖默认 linter）
2. 设置合理的配置
3. 返回格式：`return { ... }`

---

## 练习 3：自动格式化开关

**题目**：回答以下关于自动格式化开关的问题：

1. `<leader>uf` 和 `<leader>uF` 的区别是什么？
2. 你在编辑一个遗留项目的文件，不想改动格式。应该用哪个快捷键？
3. 你改完后想重新启用自动格式化，再次按同一个快捷键就行吗？
4. 如果你想永久禁用某种文件类型的自动格式化（比如 Markdown），应该怎么配置？

---

## 练习 4：格式化 vs LSP 格式化

**题目**：回答以下关于格式化方式的问题：

1. LSP 格式化和 conform.nvim 格式化有什么区别？
2. 如果 LSP 服务器支持格式化（比如 tsserver），LazyVim 会用哪个？
3. 为什么说 conform.nvim 是"调度器"？
4. 如果你没装 stylua，按 `<leader>cf` 格式化 Lua 文件会怎样？

---

## 练习 5（进阶）：自定义格式化器选项

**题目**：你想让 prettier 用单引号（single quote）而不是双引号，tab 宽度为 4。

1. 写出修改 prettier 选项的配置代码
2. 如果你想让 stylua 用 tab 缩进而不是空格，怎么改？
3. 这些修改会影响 LazyVim 默认的其他格式化器吗？

---

## 如何使用本章代码

```bash
cd lazyvim/14-formatting

# 验证所有 Lua 文件语法
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/formatting.lua" -c 'qa!'
# 预期：退出码 0

# 真实环境测试（如果你装了 LazyVim）：
# cp lua/plugins/formatting.lua ~/.config/nvim/lua/plugins/14-formatting.lua
# nvim  → :Lazy sync → 打开 Lua 文件 → 按 <leader>cf 看看有没有格式化
```

做完所有练习后，进入 [第15章 Git 集成](../15-git/)，开始 Part 4「开发工作流」。
