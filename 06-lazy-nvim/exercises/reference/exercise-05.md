# 练习 5 参考答案 — `:Lazy` 命令实战

## 1. 加了新插件后怎么安装？

```vim
:Lazy sync
```

或更精确（只装新插件，不 update/clean）：

```vim
:Lazy install
```

`:Lazy sync` = `install` + `clean` + `update`，适合改了配置后一键同步。

## 2. 查看哪个插件最耗时？

```vim
:Lazy profile
```

这会打开性能分析器，显示每个插件的加载耗时和触发事件。
找到最慢的几个，考虑改成更激进的懒加载（比如把 `event` 改成 `keys`）。

进阶：用 `nvim --startuptime startup.log` 查看完整的启动时间线。

## 3. 队友 push 了 lazy-lock.json，你怎么同步？

```vim
:Lazy sync
```

或更精确（只按 lock 装，不 update）：

```vim
:Lazy install
```

`:Lazy install` 会读取更新后的 `lazy-lock.json`，按锁定的 commit hash 安装缺失插件，
保证你本地的插件版本和队友**完全一致**。

如果想"强制还原"到 lock 记录的版本（如果你本地装了更新的版本想回退）：

```vim
:Lazy restore
```

## 4. `:Lazy sync` = 哪三个命令？

`:Lazy sync` = `:Lazy install` + `:Lazy clean` + `:Lazy update`

| 子命令 | 干什么 |
|--------|--------|
| `install` | 安装 lazy-lock.json 里锁定但本地没装的插件 |
| `clean`   | 删除本地有但 spec 没引用的插件 |
| `update`  | 更新 spec 引用的插件到最新版本（更新 lazy-lock.json） |

## 5. 禁用 LazyVim 默认插件

在你的 `lua/plugins/` 目录下创建一个文件（如 `lua/plugins/disable.lua`）：

```lua
return {
  -- 禁用滚动动画
  { "echasnovski/mini.animate", enabled = false },

  -- 禁用 bufferline（如果你用别的 tab 插件）
  { "akinsho/bufferline.nvim", enabled = false },

  -- 禁用 dashboard 启动页
  { "goolord/alpha-nvim", enabled = false },
}
```

**原理**：lazy.nvim 按 URL 匹配 spec，你的 `enabled = false` 会覆盖 LazyVim 默认的 `enabled = true`。
插件不会被加载，但也不会报错（lazy.nvim 会跳过 disabled 的 spec）。

> 💡 **进阶**：如果你想条件禁用（比如只在终端是 tmux 时禁用某个插件），
> 用 `enabled = function() return vim.env.TMUX == nil end`。

**回到 [练习题](../README.md)**
