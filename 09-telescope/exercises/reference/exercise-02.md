# 练习 2 参考答案 — keys 懒加载 vs event 懒加载

**1. 为什么 Telescope 用 `keys` 懒加载而不是 `event = "BufReadPost"`？**

Telescope 是"命令式工具"——你不搜东西时它完全没用。用 `event = "BufReadPost"` 会让每次打开文件都加载 Telescope，浪费启动时间。用 `keys` 更精确：只有按下 `<leader>ff` 等键时才加载。

**2. 如果用 `event = "BufReadPost"`，对启动时间有什么影响？**

每次打开文件都会触发 Telescope 加载（约 15-30ms）。如果你一天打开 100 个文件，就是 1500-3000ms 的额外加载时间。虽然单次不明显，但累积起来很可观。

**3. `desc` 有什么用？不写 `desc` 会怎样？**

`desc` 是 which-key 显示的描述文本。不写 `desc`，按 `<leader>f` 等 0.5 秒时，which-key 只显示 `ff` 按键，不显示"查找文件"的功能说明。用户不知道这个键是干什么的。

**4. 按下 `<leader>ff` 后，lazy.nvim 做了哪三件事？**

1. 检测到 Telescope 还没加载
2. 加载 Telescope（执行 setup、load_extension）
3. 执行 `<cmd>Telescope find_files<CR>`（打开 find_files picker）

**回到 [练习题](../README.md)**
