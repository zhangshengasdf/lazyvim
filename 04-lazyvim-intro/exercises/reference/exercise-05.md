# 练习 5 参考答案 — `:Lazy sync` 幕后

## 1. `:Lazy sync` 等价于哪三个子命令？

`:Lazy sync` = `:Lazy install` + `:Lazy clean` + `:Lazy update`

| 子命令 | 干什么 |
|--------|--------|
| `install` | 安装 `lazy-lock.json` 里锁定但本地没装的插件 |
| `clean`   | 删除本地有但 spec 没引用的插件 |
| `update`  | 更新 spec 引用的插件到最新版本（更新 `lazy-lock.json`） |

## 2. 队友更新了 `lazy-lock.json`，你 pull 后该运行什么？

运行 `:Lazy sync`（或等价的 `:Lazy install`）。

- `install` 会读取更新后的 `lazy-lock.json`，把本地缺失的插件按**锁定的 commit hash** 安装
- 这样你的本地插件版本和队友**完全一致**，不会因为他升级了某插件、你没升级而出现 bug
- 注意：如果只想"还原到锁定版本"（不拉新版本），用 `:Lazy restore` 更精确

## 3. `lazy-lock.json` 应该 commit 还是 `.gitignore`？

**应该 commit 到版本控制**（不要 gitignore）。

原因：
- `lazy-lock.json` 记录了每个插件的具体 commit hash，是"可复现环境"的保证
- 你在 A 机器上跑得好好的，push 到 GitHub，B 机器 pull 后 `:Lazy sync` 就能还原一模一样的插件版本
- 如果不 commit，每次 clone 仓库都会装到最新版插件，可能引入 breaking change

**例外**：如果你维护的是"配置模板"（给别人 fork 的 starter），可能想让它始终装最新版——这时可以 gitignore `lazy-lock.json`。但**个人配置**一定要 commit。

> 💡 这和 Node 的 `package-lock.json`、Python 的 `poetry.lock`、Ruby 的 `Gemfile.lock` 是同一个道理。

**回到 [练习题](../README.md)**
