# 第11章 练习 — Treesitter 语法引擎

> 做练习前先读完 [本章 README](../README.md)。练习答案先自己想，实在不会再看参考。

---

## 练习 1：Treesitter vs 正则高亮

**题目**：以下代码片段，正则高亮和 Treesitter 高亮分别会怎么处理？写出预期差异。

```javascript
const html = `<div class="${cls}">
  <span>${getText(item)}</span>
</div>`;
```

**问题**：
1. 正则高亮会如何处理 `${cls}` 和 `${getText(item)}`？为什么会出错？
2. Treesitter 会生成怎样的语法树？哪些节点会被正确高亮？
3. 如果这个文件没有安装 JavaScript 解析器，Neovim 会回退到什么？

**参考思路**：
- 正则高亮：反引号内的所有内容被标记为字符串，`${...}` 内的变量名不会被高亮
- Treesitter：`template_substitution` 节点内的 `identifier` 和 `call_expression` 会被正确识别
- 无解析器时：Neovim 回退到正则高亮

---

## 练习 2：extend vs overwrite（核心练习）

**题目**：以下是三个用户的 Treesitter 配置，判断哪些正确、哪些有 bug：

```lua
-- 配置 A
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "lua", "rust", "python" },
    },
  },
}
```

```lua
-- 配置 B
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "lua", "rust", "python" })
    end,
  },
}
```

```lua
-- 配置 C
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = { "lua", "rust", "python" }
    end,
  },
}
```

**问题**：
1. 哪个配置会丢失 LazyVim 默认的解析器？为什么？
2. 哪个配置是正确的 extend 模式？
3. 配置 C 的问题在哪？（提示：`=` 赋值 vs `vim.list_extend` 的区别）

---

## 练习 3：文本对象操作

**题目**：对于以下 Python 代码，写出每步操作后选中的内容：

```python
def process(data, threshold):       # 行 1
    result = []                      # 行 2
    for item in data:                # 行 3
        if item > threshold:         # 行 4
            result.append(item)      # 行 5
    return result                    # 行 6
```

**操作序列**（光标初始在行 3 的 `for` 关键字上）：

| 步骤 | 按键 | 选中内容 |
|------|------|----------|
| 1 | `vaf` | ? |
| 2 | `gN`（从步骤 1 的选区开始） | ? |
| 3 | 重新定位光标到行 4 `if`，按 `vai` | ? |
| 4 | 重新定位光标到行 1 的 `data` 参数，按 `vaa` | ? |
| 5 | 重新定位光标到行 1 的 `data` 参数，按 `via` | ? |

---

## 练习 4：配置语言解析器

**题目**：你是一个全栈开发者，主要使用 TypeScript/React 前端和 Go 后端。
写出你的 `ensure_installed` extend 配置，要求：

1. 包含所有 TypeScript/React 相关解析器
2. 包含 Go 相关解析器
3. 包含常用的配置文件格式（JSON, YAML, TOML）
4. 包含文档格式（Markdown）
5. 不要包含你不用的语言（比如 Ruby, Haskell, Elixir）

写出完整的 spec，用 `opts = function(_, opts)` 形式。

**参考答案**：

```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        -- 你的答案
      })
    end,
  },
}
```

---

## 如何使用本章代码

```bash
cd lazyvim/11-treesitter

# 验证所有 Lua 文件语法
nvim --headless -u NONE -c "luafile lua/init.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/treesitter.lua" -c 'qa!'
# 预期：退出码 0

# 真实环境测试（如果你装了 LazyVim）：
# cp lua/plugins/treesitter.lua ~/.config/nvim/lua/plugins/11-demo.lua
# nvim  → :Lazy sync → :TSInstallInfo 确认解析器列表
```

做完所有练习后，进入 [第12章 LSP 语言服务与 Mason](../12-lsp-mason/)。
