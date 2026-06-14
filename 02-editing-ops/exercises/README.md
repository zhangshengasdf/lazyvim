# 第02章 · 练习 —— 文本对象与搜索替换

> **说明**：准备一个 JavaScript 或 Python 文件练习，文本对象在带标点/括号/引号的代码里最有感觉。
> 每道题先自己做，做不出来再看参考答案。

---

## 练习 1：文本对象 `ci"` 实战

### 任务

准备这样一段代码（保存为 `sample.js`）：

```javascript
const greeting = "hello world";
const name = "old name";
function say(message) {
  console.log(message);
}
```

依次完成：

1. 光标移到 `"hello world"` 的任意位置（引号内），按 `ci"`，输入 `hi vim`，按 `Esc`。
   - 结果：`const greeting = "hi vim";`
2. 光标移到 `"old name"`，按 `ci"`，输入 `new name`，按 `Esc`。
3. 光标移到 `(message)` 的括号内，按 `ci(`，输入 `msg`，按 `Esc`。
   - 结果：`function say(msg) {`
4. 用 `u` 撤销，观察效果。

### 思考题

- 如果不用 `ci"`，你会怎么改字符串内容？（对比按键数量）
- `ci"` 和 `da"` 的区别，什么时候用哪个？

---

## 练习 2：词级文本对象 `ciw` `daw`

### 任务

准备文本：

```
function calculateTotal(price, tax) {
  return price + tax;
}
```

依次完成：

1. 光标移到 `calculateTotal` 这个词的任意字母上，按 `ciw`，输入 `calc`，按 `Esc`。
   - 结果：`function calc(price, tax) {`
2. 光标移到 `tax` 这个词上，按 `daw`（delete around word，删词含空格），观察。
   - 结果：`function calc(price) {`（tax 和后面的逗号空格被删了？还是只删 tax？实际只删 `tax`，逗号保留）
3. 撤销，再用 `diw`（delete inside word，只删词本身）对比。
4. 光标移到 `price`，按 `yiw`（复制词），移到别处按 `p`，观察。

### 思考题

- `daw` 和 `diw` 的区别？（提示：`a` 含周围的空格，`i` 不含）
- 为什么改变量名用 `ciw` 而不是 `dw`？

---

## 练习 3：搜索 `*` 与 `n N` 导航

### 任务

准备一段有重复单词的文本：

```
function foo() {
  const foo = 1;
  return foo + bar;
}
```

依次完成：

1. 光标移到第一个 `foo` 上，按 `*`——立刻跳到下一个 `foo`。
2. 连续按 `n n n`，光标在所有 `foo` 之间循环。
3. 按 `N`，反向跳。
4. 按 `:noh` 清除黄色高亮（但仍在搜索 `foo` 的状态，按 `n` 还能继续）。
5. 试试 `/foo<CR>` 和 `/bar<CR>`，观察高亮变化。

### 思考题

- `*` 搜索时是否区分大小写？（提示：取决于 ignorecase + smartcase 设置）
- `:noh` 和 `:nohlsearch` 的关系？

---

## 练习 4：替换命令 `:s` 全家桶

### 任务

准备文本：

```
foo bar foo
baz foo qux
foo foo foo
```

依次完成（每步后用 `u` 撤销再试下一步）：

1. 光标在第一行，输入 `:s/foo/XXX/`——只替换该行第一个 foo。
   - 结果：`XXX bar foo`
2. 输入 `:s/foo/XXX/g`——替换该行所有 foo。
   - 结果：`XXX bar XXX`
3. 输入 `:%s/foo/XXX/g`——替换整个文件所有 foo。
4. 输入 `:%s/foo/XXX/gc`——每个替换前确认（y/n/a/q）。
5. 输入 `:%s/foo/XXX/i`——`i` 标志表示忽略大小写（即使没开 ignorecase）。

### 进阶：用不同分隔符

输入 `:%s#foo#XXX#g`——效果和 `/` 分隔符一样，但当 pattern 里有 `/` 时更清晰：

```vim
" 丑: 大量转义
:%s/\/usr\/local\/bin/\/opt\/bin/g

" 美: 换分隔符
:%s#/usr/local/bin#/opt/bin#g
```

### 思考题

- `:%s/foo/bar/g` 和 `:%s/foo/bar/gc` 各自适合什么场景？
- 怎么只替换第 5 到 10 行的 foo？（提示：`:5,10s/foo/bar/g`）

---

## 练习 5：综合实战 —— 重构一段代码

### 任务

准备这段 Python 代码：

```python
def calculate_total(items):
    total = 0
    for item in items:
        total = total + item.price
    return total
```

用本章学到的操作完成以下重构（**每个动作用最少的按键**）：

1. 把 `calculate_total` 重命名为 `sum_total`：光标移到 `calculate_total`，按 `ciw`，输入 `sum_total`。
2. 把文件里所有 `total` 替换为 `acc`（累加器）：`:%s/total/acc/gc`（逐个确认）。
3. 把 `item.price` 改成 `item.cost`：光标移到 `price`，按 `ciw`，输入 `cost`。
4. 把 `for item in items:` 的 `item` 改成 `it`：`ciw`。
5. 删除整个 for 循环体那一行：光标移到那行，按 `dd`。

### 思考题

- 这 5 步如果用普通编辑器（鼠标+方向键+退格），大概要多少次按键？
- 哪些步骤用了文本对象？哪些用了搜索替换？

---

## 参考答案要点

### 练习 1 思考题

- 不用 `ci"`：要先 `f"` 跳到引号，`df"` 或 `dt"` 删到下一个引号，再 `i` 进插入——至少 5-6 步，还要数字符。
  `ci"` 两步搞定，且光标在引号内任何位置都行。
- `ci"` 改引号**内**内容（保留引号）；`da"` 连引号一起删（用于删掉整个字符串字面量）。

### 练习 2 思考题

- `daw` 删词**和词后的空格**（如果词后有逗号/分号，标点会保留在原位）；`diw` 只删词本身，空格不动。
- 改变量名用 `ciw` 因为它把删词和进插入合二为一；`dw` 会连后面的字符一起删（取决于词后是什么），且删完还要 `i` 才能输入。

### 练习 3 思考题

- `*` 搜索遵守当前 `ignorecase`/`smartcase` 设置。本章配置下，`foo`（全小写）会匹配 `Foo`/`FOO`。
- `:noh` 是 `:nohlsearch` 的简写，效果完全相同：清除当前高亮，但不影响后续 `n/N` 跳转。

### 练习 4 思考题

- `:%s/foo/bar/g` 批量替换，适合确定全部要改的场景（如重命名全局变量）。
  `:%s/foo/bar/gc` 逐个确认，适合可能误匹配的场景（如 `foo` 可能是其他词的一部分）。
- 行范围替换：`:5,10s/foo/bar/g` 只替换第 5-10 行。可视模式选中后按 `:` 会自动填 `'<,'>`，只替换选中区域。

### 练习 5 思考题

- 普通编辑器约 30-50 次按键（鼠标定位、选中、删除、输入，重复多次）；Vim 用本章技巧约 15-20 次。
- 第 1、3、4 步用了文本对象（`ciw`）；第 2 步用了搜索替换（`:%s`）；第 5 步用了行删除（`dd`）。
  这就是 Vim 的编辑效率：文本对象 + 搜索替换覆盖大部分日常编辑。

---

## 如何使用本章代码

本章的 `lua/init.lua` 配置了搜索相关选项（incsearch、hlsearch、smartcase、ignorecase），
让搜索体验更好。建议加载它再做练习：

```bash
# 用本章配置启动 Neovim 练习文本对象和搜索替换
nvim -u lazyvim/02-editing-ops/lua/init.lua sample.js

# 验证搜索选项已生效
cd lazyvim/02-editing-ops
nvim --headless -u lua/init.lua \
  -c "lua print('incsearch=' .. vim.o.incsearch)" \
  -c "lua print('smartcase=' .. vim.o.smartcase)" \
  -c 'qa!'
# 预期：incsearch=true  smartcase=true
```

做完所有练习后，进入 [第03章 Neovim 基础与 init.lua](../03-neovim-basics/)。
