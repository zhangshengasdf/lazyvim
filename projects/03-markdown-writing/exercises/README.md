# 项目 3 练习 — Markdown 写作环境

本项目有 3 道练习，从简单到复杂，逐步扩展你的写作环境。

---

## 练习 1：添加博客模板

### 背景

你经常写博客，每次都手动输入 frontmatter（标题、日期、标签等）。
用 Neovim 的 snippet 或 template 机制自动插入模板。

### 任务

创建一个 Lua 文件 `lua/plugins/templates.lua`，为 Markdown 文件添加自动模板：

```lua
-- 提示：用 vim.api.nvim_create_autocmd 监听 BufNewFile 事件
-- 当新建 .md 文件时，自动插入模板内容
return {
  init = function()
    local augroup = vim.api.nvim_create_augroup("MarkdownTemplate", { clear = true })
    vim.api.nvim_create_autocmd("BufNewFile", {
      group = augroup,
      pattern = "*.md",
      callback = function()
        -- 在这里插入模板
        -- 提示：vim.api.nvim_buf_set_lines(0, 0, 0, false, { "行1", "行2" })
      end,
      desc = "新建 Markdown 文件时插入模板",
    })
  end,
}
```

### 要求

1. 模板至少包含：`---`、`title: `、`date: `、`tags: []`、`---`
2. 日期自动填入今天（`os.date("%Y-%m-%d")`）
3. 光标停在 `title: ` 后面（用 `vim.api.nvim_win_set_cursor`）
4. 自动进入插入模式

### 验证

```bash
nvim test-blog.md
# 预期：自动出现模板内容，光标在 title: 后面
```

### 思考

- 为什么用 `BufNewFile` 而不是 `BufReadPost`？
- 如果你有多种模板（博客、笔记、文档），怎么选择？

---

## 练习 2：配置自动目录（TOC）

### 背景

长文档需要目录。Markdown 的 TOC 通常是标题列表加锚点链接：

```markdown
- [第一章](#第一章)
  - [1.1 小节](#11-小节)
- [第二章](#第二章)
```

### 任务

配置 `markdown-toc` 或类似工具，在保存 Markdown 文件时自动生成/更新目录。

**方式 A：用外部工具 `markdown-toc`**

```bash
npm install -g markdown-toc
```

然后在 `lua/plugins/formatting.lua` 中扩展 conform 配置：

```lua
-- 提示：在 opts.formatters 中添加 markdown-toc 配置
opts.formatters["markdown-toc"] = {
  -- markdown-toc 的命令行参数
}
```

**方式 B：用纯 Lua 函数**

创建一个 Lua 函数，读取 buffer 中所有标题，生成目录文本，插入到文件开头。

### 要求

1. 目录包含所有 `##` 及以上的标题
2. 缩进正确（`##` 无缩进，`###` 缩进 2 空格）
3. 锚点链接正确（小写、空格变连字符）
4. 更新时替换已有目录（不重复插入）

### 验证

```bash
nvim test-toc.md
# 输入一些标题，保存，检查目录是否自动生成
```

### 思考

- 为什么目录通常放在文件开头而不是末尾？
- 如果标题包含中文，锚点怎么处理？

---

## 练习 3：添加拼写检查

### 背景

写作时拼写错误很尴尬。Neovim 内置了拼写检查（`:set spell`），
但默认的英文词典可能不够用（技术术语、缩写等）。

### 任务

为 Markdown 文件配置智能拼写检查：

1. **启用拼写检查**：在 Markdown 文件中自动开启
2. **自定义词典**：添加技术术语到拼写词典
3. **快捷键集成**：用 `z=` 快速修复拼写错误

创建 `lua/plugins/spellcheck.lua`：

```lua
return {
  init = function()
    local augroup = vim.api.nvim_create_augroup("MarkdownSpell", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      pattern = "markdown",
      callback = function()
        vim.opt_local.spell = true
        vim.opt_local.spelllang = { "en", "cjk" }
        -- 提示：vim.opt_local.spellfile 指向自定义词典文件
      end,
      desc = "Markdown 文件启用拼写检查",
    })
  end,
}
```

### 要求

1. 只在 Markdown 文件中启用拼写检查
2. 支持英文和 CJK（中文、日文、韩文不会被标为拼写错误）
3. 自定义词典文件路径：`~/.config/nvim/spell/custom.utf-8.add`
4. 添加 10 个常用技术术语到词典（如 API、JSON、README 等）

### 验证

```bash
nvim test-spell.md
# 输入 "This is a tset"，运行 :set spell
# 预期：tset 被标为拼写错误，z= 可以修复
```

### 思考

- 为什么 `spelllang = { "en", "cjk" }` 而不是只用 `"en"`？
- 如果你写中英混合的文档，拼写检查会误报中文吗？

---

## 完成标准

- [ ] 练习 1：新建 `.md` 文件时自动出现模板
- [ ] 练习 2：保存时目录自动更新
- [ ] 练习 3：Markdown 文件中拼写检查正常工作

全部完成后，你就有了一套完整的 Markdown 写作环境。
这套配置可以复制到任何 LazyVim 安装中使用。
