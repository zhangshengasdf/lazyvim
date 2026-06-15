# 第13章 练习 — 自动补全 nvim-cmp

> 做练习前先读完 [本章 README](../README.md)。练习答案先自己想，实在不会再看参考。

---

## 练习 1：补全来源优先级

**题目**：以下配置有错误，找出并改正：

```lua
-- 错误配置
return {
  {
    "hrsh7th/nvim-cmp",
    opts = {
      sources = {
        { name = "buffer" },
        { name = "path" },
        { name = "nvim_lsp" },
        { name = "luasnip" },
      },
    },
  },
}
```

**问题**：
1. 这个配置哪里错了？（提示：LazyVim 默认有 nvim-cmp 的 sources 配置吗？）
2. 改正后，补全来源的正确顺序应该是什么？（按优先级从高到低）
3. 如果你想在 LSP 补全前面加一个 emoji 来源，应该怎么做？

---

## 练习 2：追加补全来源

**题目**：你想在补全菜单里添加 `cmp-calc` 来源（数学计算补全，输入 `=` 后弹出计算器结果）。

已知：
- 插件地址：`hrsh7th/cmp-calc`
- 来源名称：`calc`
- 优先级：应该比 buffer 高，比 path 低

写出完整的 spec，要求：
1. 用 extend 模式（不覆盖默认来源）
2. 添加正确的 dependencies
3. 设置合理的 priority
4. 返回格式：`return { ... }`

---

## 练习 3：Tab 映射的上下文感知

**题目**：回答以下关于 `<Tab>` 映射的问题：

1. 在补全菜单弹出时，按 `<Tab>` 会发生什么？
2. 在 snippet 展开后，按 `<Tab>` 会发生什么？
3. 补全菜单没弹出、也没有 snippet 时，按 `<Tab>` 会发生什么？
4. 为什么说 `<Tab>` 是"上下文感知"的？
5. 如果你自己写了 `<Tab>` 映射覆盖 LazyVim 的默认映射，可能会丢失什么功能？

---

## 练习 4：snippet 引擎选择

**题目**：回答以下关于 snippet 引擎的问题：

1. LazyVim 默认用哪个 snippet 引擎？
2. 如果你想切换到 mini.snippets，应该怎么做？（提示：LazyVim Extras）
3. snippet 的"占位符跳转"是什么意思？举例说明。
4. 为什么说 snippet 来源依赖 snippet 引擎？如果没有 LuaSnip，snippet 来源会怎样？

---

## 练习 5（进阶）：补全外观自定义

**题目**：你想让补全菜单显示来源名称（比如 `[LSP]`、`[Buffer]`），但不想显示图标。

1. 写出 `formatting.format` 函数的代码
2. 如何禁用 LazyVim 默认的 LSP kind 图标？
3. 如果你想让补全菜单用双线边框（`double`），怎么改 `window` 配置？

---

## 如何使用本章代码

```bash
cd lazyvim/13-completion

# 验证所有 Lua 文件语法
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/completion.lua" -c 'qa!'
# 预期：退出码 0

# 真实环境测试（如果你装了 LazyVim）：
# cp lua/plugins/completion.lua ~/.config/nvim/lua/plugins/13-completion.lua
# nvim  → :Lazy sync → 打开 Lua 文件 → 输入 require("cmp"). 看看有没有补全菜单
```

做完所有练习后，进入 [第14章 格式化与代码检查](../14-formatting/)。
