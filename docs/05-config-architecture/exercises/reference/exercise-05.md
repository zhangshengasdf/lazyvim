# 练习 5 参考答案 — 修复错误配置

## 原始配置（有错误）

```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua",
        "rust",
      },
    },
  },
}
```

## 1. 错误在哪里？

错误在 `opts = { ensure_installed = { "lua", "rust" } }`。

这是**覆盖**而非**扩展**。LazyVim 为 nvim-treesitter 定义了一个默认的 `ensure_installed` 列表
（包含 bash/c/css/html/javascript/json/... 等十几种解析器），用 table 直接赋值会**整体替换**这个列表。

## 2. 会造成什么后果？

LazyVim 默认装的解析器（bash、c、css、html、javascript、json、markdown、python、regex、
tsx、typescript、vim、vimdoc、yaml 等）**全部不再自动安装**。

你打开一个 `.js` 文件，Treesitter 不会高亮（因为没有 javascript 解析器）。
你必须手动 `:TSInstall javascript` 才行——而且每次换机器都要重装。

## 3. 正确版本

```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- opts 是 LazyVim 默认的 opts（引用传递，包含默认的 ensure_installed 列表）
      -- vim.list_extend 把你的语言追加到默认列表后面
      vim.list_extend(opts.ensure_installed, {
        "lua",
        "rust",
      })
      -- 不需要 return（修改引用即生效）
    end,
  },
}
```

## 验证

装完正确版本后，打开 Neovim 运行：

```vim
:TSInstallInfo
```

应该能看到 `lua` 和 `rust`（你加的）以及 `bash`、`c`、`css`...（LazyVim 默认的）都在列表里。

如果用错误版本，只会看到 `lua` 和 `rust`，其他全没了。

## 核心铁律

**扩展列表型字段，永远用 `opts = function(_, opts) vim.list_extend(opts.X, {...}) end`**。

这包括：
- `ensure_installed`（treesitter、none-ls、nvim-lspconfig 等）
- `keys`（虽然 keys 是追加的，但复杂定制还是建议用 function）
- 任何 LazyVim 默认已定义的 list 字段

**回到 [练习题](../README.md)**
