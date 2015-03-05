# H5F

这是一个基于 [HTML5 Forms](http://www.w3.org/TR/html5/forms.html) 规范的表单验证插件，即输入字段的值受标准的 HTML5 属性制约，如：

* `required` - 必填
* `pattern` - 字符串的模式
* `minlength` - 最小长度
* `maxlength` - 最大长度
* `min` - 数字等的最小值
* `max` - 数字等的最大值

与表单相关的 HTML 标签有很多，但常用的与构造表单数据有关的是 `<input>`、`<textarea>` 和 `<select>`，本插件只对它们进行处理。其中 `<input>` 的行为根据 `type` 值的不同而多变，本插件目前仅支持了一部分：

* `text`
* `search`
* ~~`tel`~~
* ~~`url`~~
* `email`
* `password`
* `number`
* `checkbox`
* `radio`

## 使用方法

按照以下步骤进行操作，就能简单地使用本插件的基本功能：

1. 引入 [1.8.0](https://github.com/jquery/jquery/releases) 以上版本的 [jQuery](http://jquery.com/)；
2. 使用 IE 8 及以上或其他现代浏览器；
3. 在 `<form>` 被加载后运行 JS 代码 `H5F.init(forms)`。

## 限制条件

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

## 参数设置

本插件能够通过在运行 JS 代码 `H5F.init()` 时传入参数，或者在 HTML 标签上加上 `data-h5f-*` 属性来控制字段的验证行为。

### JS 参数

`H5F.init()` 方法接受两个参数：

1. 初始化的目标，即表单，可以是一个也可以是个集合；
2. 额外设置，目前仅能用来指定表单的验证方式（默认为提交时验证，可以改为字段的值改变后立即验证）。

通常只需运行 `H5F.init(forms)` 就可以了，然而想要改变一些行为时就需要传入第二个参数，如下：

```javascript
// 将验证方式改为字段的值改变后立即验证
H5F.init($("form"), {immediate: true});
```

### HTML 属性

##### 表单

`data-h5f-immediate` 同样是用来改变验证方式，但是优先级比 JS 参数传递的高。

```html
<form data-h5f-immediate="true"></form>
```

`data-h5f-novalidate` 用来忽略表单验证。

```html
<form data-h5f-novalidate="true"></form>
```

##### 字段

`data-h5f-required` 用于指定一组 `checkbox` 是否至少得选择一个，只需在一个 `checkbox` 上添加。

```html
<label><input type="checkbox" name="favorite_fruit" value="melon" required> 瓜</label>
<label><input type="checkbox" name="favorite_fruit" value="pear" data-h5f-required="true"> 梨</label>
```

`data-h5f-label` 用于设置在错误信息中显示的标签文本，默认为对应 `<label>` 的文本。

```html
<label for="name">姓名</label>
<input id="name" type="text" name="name" required data-h5f-label="真实姓名">
```

`data-h5f-associate` 用于与其他字段元素进行关联，使其值必须与被关联的字段元素相同。

```html
<div>
  <label for="password">密码</label>
  <input id="password" type="password" name="password" required>
</div>
<div>
  <label for="password_confirmation">确认密码</label>
  <input id="password_confirmation" type="password" name="password_confirmation" data-h5f-associate="password">
</div>
```

## 了解更多

* [APIs](/docs/APIs.md)
* [Error messages](/docs/errors.md)
* [Events](/docs/events.md)
