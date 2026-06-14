# 第03章 · 练习 —— 分屏、缓冲区与 init.lua

> **说明**：本章练习需要真实 Neovim 环境。用本章配置启动：
> ```bash
> nvim -u lazyvim/03-neovim-basics/lua/init.lua
> ```
> 准备 2-3 个文本文件（a.txt b.txt c.txt）方便练习缓冲区切换。

---

## 练习 1：窗口分屏与导航

### 任务

用本章配置启动 Neovim 打开一个文件：

```bash
echo "File A content" > a.txt
echo "File B content" > b.txt
nvim -u lazyvim/03-neovim-basics/lua/init.lua a.txt
```

依次完成：

1. 输入 `:vsplit b.txt`——屏幕分成左右两个窗口，左是 a.txt，右是 b.txt。
2. 按 `Ctrl-l`（本章配置的窗口导航键）——光标移到右窗口。
3. 按 `Ctrl-h`——光标移回左窗口。
4. 输入 `:split`——左窗口再分成上下两个。现在一共有 3 个窗口。
5. 用 `Ctrl-h j k l` 在三个窗口间穿梭。
6. 输入 `:only`（或按本章配置的 `<leader>so`）——只留当前窗口，其他关闭。

### 思考题

- `Ctrl-w hjkl` 和本章配置的 `Ctrl-h/j/k/l` 哪个更顺手？为什么？
- 一个缓冲区能同时被多个窗口显示吗？怎么做到？

---

## 练习 2：缓冲区管理实战

### 任务

准备 3 个文件，一次打开它们：

```bash
nvim -u lazyvim/03-neovim-basics/lua/init.lua a.txt b.txt c.txt
```

（nvim 后面跟多个参数，会把它们都装入缓冲区。）

依次完成：

1. 输入 `:ls`——列出所有缓冲区，记录每个的编号（1/2/3）和标记（`%a` 表示当前 active）。
2. 按 `Shift-l`（`<S-l>`）——切到下一个缓冲区（本章配置的 `:bn`）。
3. 按 `Shift-h`（`<S-h>`）——切回上一个缓冲区（`:bp`）。
4. 输入 `:b 1`——直接跳到缓冲区 1。
5. 输入 `:b a.txt<CR>` 或 `:b a<Tab>`——按文件名跳转。
6. 修改 a.txt 不保存，直接 `:bn`——因为本章设了 `hidden=true`，不会报错，a.txt 变成隐藏缓冲区。
7. 输入 `:ls`——看 a.txt 现在标记有 `h`（hidden）和 `+`（有改动）。
8. 按 `<leader>bd` 关闭当前缓冲区。

### 思考题

- `:ls` 输出里 `%` `#` `a` `h` `+` 这些标记分别什么意思？
- 为什么设了 `hidden=true` 后，`:bn` 不再逼你先保存？没设会怎样？

---

## 练习 3：标签页组织工作集

### 任务

Vim 标签页 = 一组窗口布局。用本章配置启动：

```bash
nvim -u lazyvim/03-neovim-basics/lua/init.lua
```

依次完成：

1. 输入 `:tabnew a.txt`——新建标签页 2 打开 a.txt。
2. 在标签页 2 里 `:vsplit b.txt`——这个标签页现在是左右分屏。
3. 输入 `:tabnew`——再开一个空标签页 3。
4. 按 `gt gt`——循环到下一个标签页，最后回到标签页 1。
5. 按 `gT`——回到上一个标签页。
6. 输入 `:tabs`——列出所有标签页及其窗口。
7. 输入 `:tabc`——关闭当前标签页。

### 思考题

- Vim 标签页和浏览器标签页本质区别是什么？
- 什么时候该用标签页，什么时候该用缓冲区切换？

---

## 练习 4：自定义 init.lua 选项

### 任务

复制本章配置到临时目录，动手修改：

```bash
mkdir -p /tmp/nvim-test
cp lazyvim/03-neovim-basics/lua/init.lua /tmp/nvim-test/init.lua
nvim -u /tmp/nvim-test/init.lua
```

完成以下修改（每改一项，重启 Neovim 验证）：

1. **改缩进宽度**：把 `vim.opt.tabstop = 2` 改成 `4`，`shiftwidth` 也改成 `4`。
   验证：打开一个文件按 Tab，看是否缩进 4 列。
2. **关掉相对行号**：把 `vim.opt.relativenumber = true` 改成 `false`。
   验证：左侧行号变成连续数字，而不是相对距离。
3. **加一个新键位**：添加 `vim.keymap.set("n", "<leader>e", "<cmd>Explore<CR>", { desc = "打开文件浏览器" })`。
   （注意：裸 Neovim 没装 netrw 插件时这个命令可能不存在，但键位本身能注册。）
4. **改 Leader 键**：把 `vim.g.mapleader = " "` 改成 `vim.g.mapleader = ","`。
   验证：按 `,w` 是否能保存（原来是 `空格 w`）。

### 验证修改生效

```bash
# 改完后，用 headless 验证选项
nvim --headless -u /tmp/nvim-test/init.lua \
  -c "lua print('tabstop=' .. vim.o.tabstop)" \
  -c "lua print('relativenumber=' .. tostring(vim.o.relativenumber))" \
  -c 'qa!'
```

### 思考题

- 为什么 `vim.g.mapleader` 必须在所有 `<leader>` 键映射**之前**设置？
- `vim.opt.tabstop` 和 `vim.opt.shiftwidth` 不一致会怎样？

---

## 练习 5：配置拆分（进阶）

### 任务

参考 `lua/config/` 目录的结构，把 init.lua 拆分到模块。在 `/tmp/nvim-test/` 下创建：

```
/tmp/nvim-test/
├── init.lua              ← 只做 require
└── lua/
    └── config/
        ├── options.lua   ← 复制 init.lua 的选项部分
        └── keymaps.lua   ← 复制 init.lua 的键位部分
```

1. 创建 `/tmp/nvim-test/lua/config/options.lua`，把 `/tmp/nvim-test/init.lua` 里所有 `vim.opt` 和 `vim.g.mapleader` 复制过去。
2. 创建 `/tmp/nvim-test/lua/config/keymaps.lua`，把所有 `vim.keymap.set` 复制过去。
3. 把 `/tmp/nvim-test/init.lua` 改成：

   ```lua
   require("config.options")
   require("config.keymaps")
   print("[test] init.lua loaded from split modules")
   ```

4. 启动验证：`nvim -u /tmp/nvim-test/init.lua`——这次 `-u` 指向的目录下有 `lua/` 子目录，
   Neovim 会把 `/tmp/nvim-test/lua/` 加入 runtimepath，所以 `require("config.options")` 能找到。

### 验证

```bash
# 这次能用 -u 加载，因为 init.lua 所在目录的 lua/ 会被识别
nvim --headless -u /tmp/nvim-test/init.lua \
  -c "lua print('number=' .. tostring(vim.o.number))" \
  -c "lua verify = dofile('lazyvim/shared/verify.lua')" \
  -c "lua verify.run({ \
    {fn = verify.check_opt, args = {'number', true}}, \
  })" \
  -c 'qa!'
```

> ⚠️ 注意：本章 `lazyvim/03-neovim-basics/lua/init.lua` 是**内联**的（不能用 require），
> 因为 `-u` 加载的是单个文件而非目录，不自动加 runtimepath。
> 但你把它**复制到** `~/.config/nvim/init.lua`（连同 `lua/` 目录），就能用 require 了。

### 思考题

- 为什么 `-u 单个文件.lua` 时 require 找不到同目录的 lua/，但 `-u 目录/init.lua` 时能找到？
- 真实部署到 `~/.config/nvim/` 时，为什么 init.lua 里能直接 `require("config.options")`？

---

## 参考答案要点

### 练习 1 思考题

- 本章的 `Ctrl-h/j/k/l` 更顺手——一步到位，不用先按 `Ctrl-w` 再按方向键。手指行程更短。
- 能。在两个窗口里 `:b 同一文件`，或 `:vsplit` 后两个窗口显示同一缓冲区。
  修改一个窗口，另一个实时同步（因为是同一块内存）。

### 练习 2 思考题

- `%` = 当前窗口的缓冲区，`#` = 上一个缓冲区（`Ctrl-^` 切换），`a` = active（正显示在某窗口），
  `h` = hidden（隐藏，没显示但仍在内存），`+` = 有未保存改动。
- `hidden=true` 允许缓冲区隐藏不报错，所以 `:bn` 能切走而不强制保存。
  没设的话（Vim 默认），改了不保存就 `:bn` 会报 `E37: No write since last change`。

### 练习 3 思考题

- 浏览器标签页 = 一个文档；Vim 标签页 = **一组窗口布局**。
  一个 Vim 标签页可以包含多个窗口（分屏），是「工作区」的概念。
- 标签页用于不同的**布局场景**（如「写代码布局」「调试布局」「看文档布局」）；
  多文件切换用缓冲区（`:bn` `:bp` `:b name`），因为缓冲区才是「文件在内存的表示」。

### 练习 4 思考题

- 因为定义 `<leader>w` 时，Neovim 会把 `<leader>` 展开成当时的 `mapleader` 值。
  如果先定义 keymap 再改 leader，已定义的映射用的还是旧 leader。
- `tabstop` 控制 Tab 的**显示宽度**，`shiftwidth` 控制 `>>` `<<` 和自动缩进的**步进**。
  两者不一致时，按 Tab 看到的宽度和按 `>>` 缩进的宽度不一样，代码会乱。
  保持 `tabstop == shiftwidth` 是好习惯。

### 练习 5 思考题

- `-u 文件.lua` 只把**那个文件**当配置加载，不改变 runtimepath。
  `-u 目录/init.lua` 也是只加载文件，但如果那个目录下有 `lua/`，Neovim 会把它加入 runtimepath。
  实际上关键是：runtimepath 默认包含 `~/.config/nvim/`，所以部署到那里 require 就能用。
- 因为 `~/.config/nvim/` 是 Neovim 的标准配置目录，默认在 runtimepath 里，
  它下面的 `lua/` 自然能被 `require` 找到（遵循 Lua 模块查找规则：`lua/xxx/yyy.lua` 对应 `require("xxx.yyy")`）。
