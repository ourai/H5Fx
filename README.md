# H5F

这是一个基于 [HTML5 Forms](https://html.spec.whatwg.org/multipage/forms.html) 规范的表单验证插件，即输入字段的值受标准的 HTML5 属性制约，如：

* `required` - 必填
* `pattern` - 字符串的模式
* `minlength` - 最小长度
* `maxlength` - 最大长度
* `min` - 数字等的最小值
* `max` - 数字等的最大值

与表单相关的 HTML 标签有很多，但常用的与构造表单数据有关的是 `<input>`、`<textarea>` 和 `<select>`。其中 `<input>` 的行为根据 `type` 值的不同而多变，本插件目前仅支持了一部分：

* `text`
* `search`
* ~~`tel`~~
* ~~`url`~~
* `email`
* `password`
* `number`
* `checkbox`
* `radio`

**本插件只对有必要进行验证的 HTML 标签进行处理。**除了 `<input>`，还支持 `<textarea>` 和 `<select>`。

## Usage

按照以下步骤进行操作，就能简单地使用本插件的基本功能：

1. 引入 [1.8.0](https://github.com/jquery/jquery/releases) 以上版本的 [jQuery](http://jquery.com/)；
2. 使用 IE 8 及以上或其他现代浏览器；
3. 在 `<form>` 被加载后运行 JS 代码 `H5F.init(form);`。

## Limitation

在使用本插件时需要遵守几个条件：

* 需要验证的字段要有 `name` 属性，并且要被包在 `<form>` 中；
* 同一组的 `checkbox` 或 `radio` 的 `name` 值要相同。

```html
<form action="/" method="get">
  <div>
    <label for="name">姓名</label>
    <input id="name" type="text" name="name" required>
  </div>
  <div>
    <label><input type="radio" name="gender" value="1" required> 男</label>
    <label><input type="radio" name="gender" value="0"> 女</label>
  </div>
  <div>
    <label for="country">国籍</label>
    <select id="country" name="country" required>
      <option value="China">中国</option>
      <option value="Japan">日本</option>
      <option value="Korea">韩国</option>
    </select>
  </div>
  <div>
    <label for="description">简介</label>
    <textarea id="description" name="description" required></textarea>
  </div>
  <div>
    <label><input type="checkbox" name="favorite_fruit" value="melon" required> 瓜</label>
    <label><input type="checkbox" name="favorite_fruit" value="pear"> 梨</label>
  </div>
  <button type="submit">提交</button>
</form>
```

## Settings

### 验证方式

程序默认在表单提交时对输入字段进行验证，也可以指定在输入文本后立即对其进行验证。

##### 方式一

```javascript
H5F.init($("form"), {immediate: true});
```

##### 方式二

```html
<form data-h5f-immediate="true"></form>
```

**其中，第二种方式比第一种优先级高。**

### 阻止验证

```html
<form data-h5f-novalidate="true"></form>
```

### Associate with other field

利用 `data-h5f-associate` 属性与其他字段元素进行关联，使其值必须与被关联的字段元素相同。

```html
<div>
  <label for="password">密码</label>
  <input id="password" type="password" value="" name="password" required="required">
</div>
<div>
  <label for="password_confirmation">确认密码</label>
  <input id="password_confirmation" type="password" value="" name="password_confirmation" data-h5f-associate="password">
</div>
```

## More

* [APIs](/docs/APIs.md)
* [Error messages](/docs/errors.md)
* [Events](/docs/events.md)
