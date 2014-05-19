simditor-markdown
=================

[Simditor](http://simditor.tower.im/) 的官方扩展，通过 Markdown 语法快速便捷地输入内容。

### 如何使用

在 Simditor 的基础上额外引用 simditor-markdown 的脚本。

```html
<script src="/assets/javascripts/simditor-markdown.js"></script>
```

配置

```javascript
new Simditor({
	textarea: textareaElement,
	...,
	markdown: true
})
```

如果需要禁用某些语法，可以在配置里这样写：

```javascript
new Simditor({
	textarea: textareaElement,
	...,
	markdown: {
		title: false,  // 禁用标题
		hr: false      // 禁用分割线
	}
})
```

### 语法

支持以下 Markdown 语法，在 Simditor 中输入后通过空格或回车触发：

```markdown
标题：##这里是标题

引用：>这是一行引用

代码：```这是一行代码

分割线：*** 或 ---

粗体：**粗体文字** 或 __粗体文字__

斜体：*斜体文字* 或 _斜体文字_

无序列表：*第一行内容 或 +第一行内容 或 -第一行内容

有序列表：1.第一行内容

图片：![图片]（image path）

链接：[链接文字](url) 或 <url>
```
