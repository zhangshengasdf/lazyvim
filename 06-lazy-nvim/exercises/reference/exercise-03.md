# 练习 3 参考答案 — extend vs overwrite

## 错误配置回顾

```lua
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

## 1. 这个配置哪里错了？

**两个问题**：

### 问题 A：`require("null-ls")` 在 spec 解析阶段就执行

spec 文件在 lazy.nvim 收集阶段被 `return`，这时 `none-ls` 插件**还没加载**，
`require("null-ls")` 会报错（或返回 nil，导致 `.builtins.formatting.stylua` 访问 nil）。

spec 里**不应该**在 table 字面量里调用 `require(PLUGIN)`——这是在插件加载前执行的。

### 问题 B：如果 LazyVim 有默认 sources，table 会覆盖

假设 LazyVim 为 none-ls 定义了默认 `sources`（比如 eslint、prettierd），
你用 `opts = { sources = {...} }` 会**整体覆盖**默认列表，默认的源全没了。

## 2. 正确的 extend 版本

```lua
return {
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      -- opts 是 LazyVim 默认的 opts（引用传递）
      -- 在 function 内部 require 是安全的（此时插件已加载）
      local null_ls = require("null-ls")

      -- ✅ 正确：用 function 接收默认 opts，再 extend
      vim.list_extend(opts.sources, {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.prettier,
      })
    end,
  },
}
```

**关键改进**：
- `opts = function(_, opts)` 而非 `opts = {...}`——拿到默认 opts 引用
- `require("null-ls")` 放在 function **内部**——此时插件已加载，require 安全
- `vim.list_extend(opts.sources, {...})`——追加到默认列表，不覆盖

## 3. 如果 LazyVim 没有默认配置，错误版本还能用吗？

**部分能用，但仍不推荐**。

如果 LazyVim 没有为 none-ls 定义默认 `sources`：
- `opts = { sources = {...} }` 不会覆盖任何东西（默认没有）
- **但** `require("null-ls").builtins.formatting.stylua` 在 spec 解析阶段执行仍会报错

所以要解决 require 时机问题，即使 LazyVim 没有默认配置，也必须用 function：

```lua
-- 即使 LazyVim 没默认配置，也推荐用 function（解决 require 时机）
opts = function()
  local null_ls = require("null-ls")
  return {
    sources = {
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.prettier,
    },
  }
end,
```

**核心铁律**：
1. spec 的 table 字面量里**绝不**写 `require(PLUGIN)`（插件还没加载）
2. 扩展 LazyVim 默认的列表字段**必须**用 `opts = function(_, opts) vim.list_extend(...) end`
3. 即使没有默认配置，涉及 `require(PLUGIN)` 也要用 function 形式（保证加载时机正确）

**回到 [练习题](../README.md)**
