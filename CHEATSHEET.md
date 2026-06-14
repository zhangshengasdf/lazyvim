# LazyVim 速查表

> 本表汇总教程 20 章的核心按键和命令，打印后放在手边随时查。
> Leader 键 = `Space`（空格）。`<C-x>` = Ctrl+x，`<S-x>` = Shift+x。

---

## 模式切换

| 按键 | 模式 | 说明 |
|------|------|------|
| `i` / `a` / `o` | 插入模式 | 光标前 / 光标后 / 下方新行 |
| `I` / `A` / `O` | 插入模式 | 行首 / 行末 / 上方新行 |
| `v` | 可视模式 | 逐字符选择 |
| `V` | 可视行模式 | 整行选择 |
| `<C-v>` | 可视块模式 | 矩形选择 |
| `:` | 命令模式 | 执行 Ex 命令 |
| `Esc` | 回正常模式 | 不确定时按它，永远安全 |

---

## 移动（正常模式）

### 基础方向

| 按键 | 动作 | 记忆 |
|------|------|------|
| `h` / `j` / `k` / `l` | 左 / 下 / 上 / 右 | 手指不离主键位 |
| `w` | 下一个词开头 | **w**ord |
| `b` | 上一个词开头 | **b**ack |
| `e` | 下一个词末尾 | **e**nd |
| `W` / `B` / `E` | 大词跳（空格分隔） | 跳得更远 |

### 行与文件

| 按键 | 动作 |
|------|------|
| `0` | 行首（第 0 列） |
| `^` | 行首第一个非空字符 |
| `$` | 行尾 |
| `gg` | 文件第一行 |
| `G` | 文件最后一行 |
| `{` / `}` | 上 / 下一个段落（空行分隔） |
| `%` | 匹配括号跳转 |
| `H` / `M` / `L` | 屏幕顶 / 中 / 底（LazyVim 重映射为 buffer 切换，见下文） |

### 翻页

| 按键 | 动作 |
|------|------|
| `<C-d>` / `<C-u>` | 半页 下 / 上 |
| `<C-f>` / `<C-b>` | 整页 下 / 上 |
| `zz` / `zt` / `zb` | 当前行居中 / 顶 / 底 |

---

## 编辑（正常模式）

### 删除、复制、粘贴

| 按键 | 动作 |
|------|------|
| `x` | 删除光标下字符 |
| `dd` | 删除整行 |
| `dw` / `daw` | 删除到下一个词 / 删除整个词（含空格） |
| `D` | 删除到行尾 |
| `yy` | 复制整行 |
| `yw` / `yaw` | 复制到下一个词 / 复制整个词 |
| `p` / `P` | 粘贴到光标后 / 光标前 |
| `u` | 撤销 |
| `<C-r>` | 重做 |
| `.` | 重复上一步操作 |

### 修改

| 按键 | 动作 |
|------|------|
| `cw` / `ciw` | 改写到词尾 / 改写整个词 |
| `ci"` / `ci(` / `ci{` | 改写引号 / 括号 / 花括号内内容 |
| `cc` | 改写整行 |
| `C` | 改写到行尾 |
| `r{char}` | 替换光标下字符 |
| `R` | 进入替换模式 |
| `~` | 切换大小写 |

### 缩进与移动行

| 按键 | 动作 |
|------|------|
| `>>` / `<<` | 缩进 / 取消缩进 |
| `<C-i>` / `<C-o>` | 跳转列表：前进 / 后退 |
| `%` | 跳到匹配的括号 |

### 文本对象（`d`/`c`/`y` + 对象）

| 对象 | 含义 | 示例 |
|------|------|------|
| `iw` / `aw` | 内部词 / 含空格词 | `ciw` 改写光标所在词 |
| `i"` / `a"` | 引号内 / 含引号 | `di"` 删除引号内容 |
| `i(` / `a(` | 括号内 / 含括号 | `yi(` 复制括号内容 |
| `i{` / `a{` | 花括号内 / 含花括号 | `da{` 删除整个代码块 |
| `it` / `at` | HTML 标签内 / 含标签 | `cit` 改写标签内容 |
| `ip` / `ap` | 段落内 / 含段落 | `dap` 删除整个段落 |

---

## 搜索与替换

| 按键 / 命令 | 动作 |
|-------------|------|
| `/{pattern}` | 向下搜索 |
| `?{pattern}` | 向上搜索 |
| `n` / `N` | 下一个 / 上一个匹配 |
| `*` / `#` | 搜索光标下的词（下 / 上） |
| `:%s/old/new/g` | 全文替换 |
| `:s/old/new/g` | 选区替换（可视模式下） |
| `<leader>sw` | 搜索光标下的词（Telescope） |
| `<leader>sg` | 全局 grep（Telescope） |
| `<leader>ff` | 查找文件（Telescope） |
| `<leader>fr` | 最近文件（Telescope） |

---

## Leader 快捷键（`Space` 开头）

### 文件查找（`f` = find）

| 快捷键 | 功能 |
|--------|------|
| `<leader>ff` | 查找文件 |
| `<leader>fg` | 实时 grep（全文搜索） |
| `<leader>fb` | buffer 列表 |
| `<leader>fr` | 最近文件 |
| `<leader>fc` | Neovim 配置文件 |
| `<leader>fh` | 帮助标签 |

### 搜索（`s` = search）

| 快捷键 | 功能 |
|--------|------|
| `<leader>sw` | 搜索当前词 |
| `<leader>sg` | 全局 grep |
| `<leader>sh` | 搜索高亮 |
| `<leader>sk` | 搜索快捷键 |
| `<leader>ss` | 搜索符号（Treesitter） |

### Buffer（`b` = buffer）

| 快捷键 | 功能 |
|--------|------|
| `<leader>bb` | 切换到上一个 buffer |
| `<leader>bd` | 关闭当前 buffer |
| `<leader>bo` | 关闭其他 buffer |
| `<leader>bl` | 关闭左侧 buffer |
| `<leader>br` | 关闭右侧 buffer |

### Git（`g` = git）

| 快捷键 | 功能 |
|--------|------|
| `<leader>gg` | 打开 LazyGit |
| `<leader>gf` | 当前文件 git log |
| `<leader>gs` | git 状态 |
| `<leader>gb` | git blame 当前行 |
| `<leader>gd` | git diff |

### 代码（`c` = code）

| 快捷键 | 功能 |
|--------|------|
| `<leader>ca` | 代码操作（Code Action） |
| `<leader>cr` | 重命名符号 |
| `<leader>cf` | 格式化代码 |
| `<leader>cd` | 当前行诊断详情 |
| `<leader>cs` | 工作区符号搜索 |

### 杂项

| 快捷键 | 功能 |
|--------|------|
| `<leader>w` | 保存文件 |
| `<leader>q` | 退出 |
| `<leader>qq` | 强制退出所有 |
| `<leader>wd` | 关闭当前窗口 |
| `<leader>-` | 水平分屏 |
| `<leader>\|` | 垂直分屏 |
| `<leader>ut` | 切换主题 |
| `<leader>xx` | 所有诊断（Telescope） |

---

## 窗口与 Buffer 管理

### 窗口导航

| 按键 | 动作 |
|------|------|
| `<C-h>` | 切到左边窗口 |
| `<C-j>` | 切到下方窗口 |
| `<C-k>` | 切到上方窗口 |
| `<C-l>` | 切到右边窗口 |
| `<C-Up>` / `<C-Down>` | 增加 / 减少窗口高度 |
| `<C-Left>` / `<C-Right>` | 增加 / 减少窗口宽度 |

### Buffer 切换（LazyVim 重映射）

| 按键 | 动作 |
|------|------|
| `<S-h>` | 上一个 buffer |
| `<S-l>` | 下一个 buffer |
| `<leader>bb` | 在最近两个 buffer 间切换 |

---

## LSP（语言服务）

### 跳转

| 按键 | 动作 |
|------|------|
| `gd` | 跳转到定义 |
| `gD` | 跳转到声明 |
| `gr` | 查看所有引用 |
| `gI` | 跳转到实现 |
| `gy` | 跳转到类型定义 |

### 信息与操作

| 按键 | 动作 |
|------|------|
| `K` | 悬停查看文档 |
| `<C-k>` | 函数签名提示（插入模式） |
| `<leader>ca` | 代码操作（快速修复） |
| `<leader>cr` | 重命名符号 |
| `<leader>cf` | 格式化代码 |
| `<leader>cd` | 当前行诊断 |
| `]d` / `[d` | 下一个 / 上一个诊断 |
| `<leader>xx` | Telescope 显示所有诊断 |

---

## lazy.nvim 插件管理

### `:Lazy` 命令

| 命令 | 作用 |
|------|------|
| `:Lazy` | 打开管理面板 |
| `:Lazy sync` | 安装 + 清理 + 更新（最常用） |
| `:Lazy update` | 更新所有插件 |
| `:Lazy install` | 安装锁定的插件 |
| `:Lazy clean` | 删除未引用的插件 |
| `:Lazy restore` | 还原到 lock 文件版本 |
| `:Lazy profile` | 启动性能分析 |
| `:Lazy health` | 健康检查 |

### Mason 语言服务器

| 命令 | 作用 |
|------|------|
| `:Mason` | 打开 Mason 交互界面 |
| `:MasonInstall <pkg>` | 安装指定工具 |
| `:MasonUpdate` | 更新所有已安装工具 |
| `:LspInfo` | 查看当前 buffer 的 LSP 信息 |
| `:checkhealth lspconfig` | 检查 LSP 健康状态 |

---

## 保存与退出

| 命令 | 作用 |
|------|------|
| `:w` | 保存 |
| `:q` | 退出（无改动时） |
| `:wq` | 保存并退出 |
| `:q!` | 强制退出，丢弃改动 |
| `ZZ` | 等价于 `:x`（保存退出） |
| `ZQ` | 等价于 `:q!`（不保存退出） |
| `:e {file}` | 打开文件 |
| `:e!` | 放弃改动，重新加载 |

---

## 配置文件位置

| 路径 | 用途 |
|------|------|
| `~/.config/nvim/init.lua` | Neovim 入口文件 |
| `~/.config/nvim/lua/config/options.lua` | 选项设置 |
| `~/.config/nvim/lua/config/keymaps.lua` | 自定义快捷键 |
| `~/.config/nvim/lua/config/autocmds.lua` | 自动命令 |
| `~/.config/nvim/lua/plugins/*.lua` | 插件配置 |
| `~/.config/nvim/lazy-lock.json` | 插件版本锁定（必须提交到 Git） |
| `~/.local/share/nvim/mason/` | Mason 安装的工具 |

---

## 配置插件的黄金法则

| 场景 | 正确写法 |
|------|----------|
| 追加列表（如 `ensure_installed`） | `opts = function(_, opts) vim.list_extend(opts.X, {...}) end` |
| 合并 table 字段 | `opts = function(_, opts) opts.X = vim.tbl_deep_extend("force", opts.X, {...}) end` |
| 添加新字段 | `opts = { new_field = value }` |
| 禁用插件 | `enabled = false` |
| 注册快捷键 | `vim.keymap.set("n", "<leader>x", cmd, { desc = "说明" })` |

> **铁律**：永远用 `opts = function` 而非 `opts = table` 来扩展列表字段，否则默认值会被覆盖。

---

## 快速排查

| 问题 | 检查 |
|------|------|
| 快捷键没反应 | `<leader>` 后等 300ms，看 which-key 弹出什么 |
| LSP 不工作 | `:LspInfo` 查看是否连接，`:Mason` 确认已安装 |
| 补全不弹出 | `:LspInfo` 确认 LSP 连接，`<leader>uc` 检查补全开关 |
| 启动太慢 | `:Lazy profile` 查看哪个插件加载慢 |
| 配置报错 | `:Lazy health` + `:checkhealth` |
| 快捷键绑定到 `\` 而非空格 | `mapleader` 在 keymap 注册之前没设，检查 `options.lua` 加载顺序 |
| 插件默认配置被覆盖 | 列表字段用了 `opts = {...}` 而非 `opts = function` |
