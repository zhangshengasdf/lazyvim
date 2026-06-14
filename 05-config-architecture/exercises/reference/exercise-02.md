# 练习 2 参考答案 — extend vs 覆盖

## (a) 覆盖（❌ 错误）

```lua
opts = { ensure_installed = { "lua" } }
```

**问题**：直接用 table 设置 `ensure_installed`，会**整体覆盖** LazyVim 默认的列表。
LazyVim 默认装 `bash`/`c`/`css`/`html`/`javascript`/... 等十几种解析器，全没了。

## (b) extend（✅ 正确）

```lua
opts = function(_, opts)
  vim.list_extend(opts.ensure_installed, { "lua" })
end
```

**正确**：用 function 接收默认 opts（引用传递），`vim.list_extend` 把 `lua` 追加到默认列表后面。
默认的十几种解析器全部保留。

## (c) extend（✅ 正确）

```lua
opts = function(_, opts)
  opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
    layout_strategy = "horizontal",
  })
end
```

**正确**：用 `vim.tbl_deep_extend("force", ...)` 深度合并 table 字段。
`"force"` 表示遇到同名 key，后面的覆盖前面的（你的覆盖默认的）。
`opts.defaults or {}` 是防御性写法（万一默认没有 defaults 字段）。

## (d) 覆盖（⚠️ 有风险）

```lua
opts = { defaults = { layout_strategy = "horizontal" } }
```

**问题**：这会用 `{ layout_strategy = "horizontal" }` **整体替换** LazyVim 默认的 `defaults` table。
LazyVim 默认的 `defaults` 里可能有 `file_ignore_patterns`、`mappings`、`vimgrep_arguments` 等，
全部丢失。

**不过**：如果你只想设一个字段、不在意其他默认值丢失，这个写法"能用"。
但**推荐用 (c) 的 extend 模式**，更安全。

## 总结

| 场景 | 推荐写法 |
|------|----------|
| 扩展列表字段（`ensure_installed`、`keys`） | `opts = function(_, opts) vim.list_extend(opts.X, {...}) end` |
| 扩展 table 字段（`defaults`、`setup`） | `opts = function(_, opts) vim.tbl_deep_extend("force", opts.X or {}, {...}) end` |
| 设置全新字段（默认没有的） | `opts = { new_field = value }` 安全（默认没这个字段，无所谓覆盖） |

**回到 [练习题](../README.md)**
