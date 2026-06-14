# 练习 4 参考答案 — 理解加载顺序

## 1. 四个 config 文件的 source 顺序

```
1. options.lua    ← 先设选项（其他文件可能依赖某些选项，如 mapleader）
2. keymaps.lua    ← 再设快捷键（依赖 leader 键已设好）
3. autocmds.lua   ← 再注册 autocmd（依赖选项和键位就绪）
4. lazy.lua       ← 最后配置 lazy.nvim（覆盖 init.lua 的 setup，可选）
```

**为什么是这个顺序**：
- `options.lua` 必须最先，因为 `vim.g.mapleader` 要在 `keymaps.lua` 之前设
- `keymaps.lua` 依赖 leader 键就绪
- `autocmds.lua` 可能引用选项和键位
- `lazy.lua` 是 lazy.nvim 的全局配置，最后处理

## 2. `init.lua` 的 `setup` 和 `lua/config/lazy.lua` 的关系

- **`init.lua`** 里的 `require("lazy").setup({...})` 是**默认配置**，starter 自带
- **`lua/config/lazy.lua`** 是**可选的覆盖配置**——如果你创建了它，LazyVim 会用它**合并/覆盖** `init.lua` 的 setup 参数

**什么时候用 `lazy.lua`**：当你想改 lazy.nvim 的 `install`、`checker`、`performance` 等全局行为，
但不想动 `init.lua`（保持 starter 的 `init.lua` 不变，方便 starter 升级）。

**大多数人不写 `lazy.lua`**——默认配置已经够好。

## 3. `lua/plugins/` 的处理时机

`lua/plugins/example.lua` 在 `lua/config/options.lua` **之前**被处理（收集 spec），但插件的**加载**（setup 执行）发生在所有 config source **之后**。

具体顺序：

```
1. init.lua: bootstrap lazy.nvim
2. init.lua: require("lazy").setup({
     spec = {
       { "LazyVim/LazyVim", import = "lazyvim.plugins" },
       { import = "plugins" },   ← 这里收集你的 lua/plugins/*.lua（包括 example.lua）
     }
   })
3. lazy.nvim 收集所有 spec，按 URL 深度合并
4. LazyVim 自动 source lua/config/options.lua → keymaps.lua → autocmds.lua → lazy.lua
5. lazy.nvim 按懒加载策略加载插件（event/ft/cmd/keys 触发时）
```

所以 `lua/plugins/example.lua` 的 spec 定义在步骤 2-3 处理，
但 spec 里 `config = function()` 的执行在步骤 5（懒加载触发时），晚于 `lua/config/`。

**回到 [练习题](../README.md)**
