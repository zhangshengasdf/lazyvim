# 项目 2 练习 — Python 后端配置

> 做练习前先读完 [项目 README](../README.md)。
> 练习答案先自己想，实在不会再看参考。

---

## 练习 1：添加 Django 支持

**题目**：你在开发一个 Django 项目，需要额外的 Django 开发支持。

已知：
- Django 的语言服务器是 `django-template-lsp`（Mason 包名：`htmx-lsp`）
- Django 模板文件类型是 `htmldjango`
- Django 项目需要特殊的 pyright 配置（识别 Django 的 ORM 字段类型）

**要求**：
1. 写出在 `lsp.lua` 中追加 `htmx` LSP 的配置（用于 Django 模板）
2. 写出在 `formatting.lua` 中追加 `htmldjango` 文件格式化器的配置（用 djlint）
3. 修改 pyright 的 settings，添加 Django 的 stub 包路径
4. 写出在 `dap.lua` 中追加 Django manage.py 调试的配置

**提示**：
- Django 模板 LSP 需要 `filetypes = { "htmldjango", "html" }`
- djlint 的 CLI 命令是 `djlint --reformat`
- pyright 的 `extraPaths` 可以添加 Django stub 路径
- Django 调试配置：`program = "${workspaceFolder}/manage.py"`, `args = { "runserver" }`

---

## 练习 2：配置 venv 自动激活

**题目**：你想让 Neovim 自动检测并使用项目目录下的虚拟环境。

已知：
- Python 虚拟环境通常在 `.venv/` 或 `venv/` 目录下
- pyright 会自动查找虚拟环境（如果在标准位置）
- 有时候你需要手动指定虚拟环境路径

**要求**：
1. 写出一个 `autocmd`，在进入 Python 文件时自动检测虚拟环境
2. 如果找到 `.venv/` 目录，设置 `vim.env.VIRTUAL_ENV` 环境变量
3. 如果没找到，显示一个警告消息
4. 把这个 autocmd 放在 `lua/config/autocmds.lua` 中

**提示**：
- 用 `vim.fn.getcwd()` 获取当前工作目录
- 用 `vim.fn.isdirectory()` 检查目录是否存在
- 用 `vim.env.VIRTUAL_ENV` 设置虚拟环境路径
- pyright 会自动读取 `VIRTUAL_ENV` 环境变量

```lua
-- 参考结构
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    local venv_path = vim.fn.getcwd() .. "/.venv"
    if vim.fn.isdirectory(venv_path) == 1 then
      vim.env.VIRTUAL_ENV = venv_path
      -- 提示用户
    end
  end,
})
```

---

## 练习 3：添加 Jupyter 支持

**题目**：你想在 Neovim 里运行 Jupyter Notebook（.ipynb 文件）。

已知：
- molten-nvim 插件可以在 Neovim 里运行 Jupyter 内核
- jupytext 插件可以把 .ipynb 转成 .py 文件编辑
- LazyVim 有 Jupyter Extra（`lazyvim.plugins.extras.lang.python`）

**要求**：
1. 写出在 `extra.lua` 中追加 molten-nvim 的 spec
2. 设置快捷键 `<leader>mr`（运行当前单元格）和 `<leader>mi`（初始化内核）
3. 用 `keys` 懒加载（Jupyter 支持不需要启动时加载）
4. 写出 jupytext 的 spec（把 .ipynb 转成 .py）

**提示**：
- molten-nvim 的 spec：`{ "benlubas/molten-nvim", build = ":UpdateRemotePlugins" }`
- jupytext 的 spec：{ "GCBallesteros/jupytext.nvim", opts = { extension = "py" } }
- 快捷键用 `function() require("molten").run_cell() end` 模式
- 所有快捷键必须带 `desc`

---

## 如何使用本项目代码

```bash
cd lazyvim/projects/02-python-backend

# 验证所有 Lua 文件语法
nvim --headless -u NONE -c "luafile lua/plugins/lsp.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/formatting.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/linting.lua" -c 'qa!'
nvim --headless -u NONE -c "luafile lua/plugins/dap.lua" -c 'qa!'
# 预期：全部退出码 0

# 真实环境部署：
# cp -r lua/plugins ~/.config/nvim/lua/plugins
# nvim → :Lazy sync → 打开 .py 文件 → 测试 gd / <leader>cf / 保存自动格式化
```

做完所有练习后，进入 [项目 3：Markdown 写作](../03-markdown-writing/)。

---

## 相关章节

本项目的练习涉及以下章节的知识，遇到困难时回去复习：

| 练习 | 涉及章节 | 核心知识点 |
|------|----------|-----------|
| 练习 1 | Ch12（LSP）、Ch14（格式化） | 追加 LSP 服务器、formatters_by_ft 配置 |
| 练习 2 | Ch18（自定义快捷键） | autocmd 创建、vim.env 环境变量 |
| 练习 3 | Ch16（DAP）、Ch17（插件模式） | keys 懒加载、dependencies 配置 |
