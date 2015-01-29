# HTML5 Form

这是一个基于 [Forms](https://html.spec.whatwg.org/multipage/forms.html#forms) 规范的表单验证插件，即输入字段的值受标准的 HTML5 属性制约。如：

* `minlength` - 最小长度
* `pattern` - 字符串的模式
* `min` - 数字等的最小值
* `max` - 数字等的最大值

与表单相关的 HTML 标签有很多，但常用的与字段有关的是 `<input>`、`<textarea>` 和 `<select>`、`<option>`。其中 `<input>` 的行为根据 `type` 值的不同而多变，本插件目前仅支持了一部分：

* `text`
* `search`
* ~~`tel`~~
* ~~`url`~~
* `email`
* `password`
* `checkbox`
* `radio`
* `number`

**本插件只对有必要进行验证的 HTML 标签进行处理。**除了 `<input>`，还支持 `<textarea>`。

## Dependencies

* [jQuery](http://jquery.com/) 1.8.0+

## Browser support

目前只测试了 PC 端的部分浏览器：

* Internet Explorer 8 and later
* Google Chrome
* Mozilla Firefox
* Safari

## Usage

输入字段必须有 `name` 属性，并且必须包在 `<form>` 中。

程序会视拥有相同 `name` 的 `checkbox` 或 `radio` 为一组，只生成一个验证对象，所以每组只需给一个字段添加与验证相关的属性，并且要添加到同一个字段上。

### Basic

```html
<form>
  <div>
    <label><input type="text" name="form_1" value="" required="required" minlength="2" maxlength="4" pattern=".*0"> 文本</label>
  </div>
  <div>
    <label><input type="number" name="form_2" value="" required="required" min="5" max="10"> 数字</label>
  </div>
  <div>
    <label><input type="radio" name="radio_1" value="1"> 单选框1</label>
    <label><input type="radio" name="radio_1" required="required" value="2"> 单选框2</label>
    <label><input type="radio" name="radio_1" value="3"> 单选框3</label>
    <label><input type="radio" name="radio_1" value="4"> 单选框4</label>
  </div>
  <div>
    <label><input type="checkbox" name="checkbox_1" value="1"> 多选框1</label>
    <label><input type="checkbox" name="checkbox_1" required="required" value="2"> 多选框2</label>
    <label><input type="checkbox" name="checkbox_1" value="3"> 多选框3</label>
    <label><input type="checkbox" name="checkbox_1" value="4"> 多选框4</label>
  </div>
  <input type="submit" value="submit">
</form>
```

```javascript
H5F.init($("form"));
```

### 字段的验证时机

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

### Setting error messages

```javascript
H5F.errors({
  COULD_NOT_BE_EMPTY: "不能为空"
  UNKNOWN_INPUT_TYPE: "未知类型"
  LENGTH_SMALLER_THEN_MINIMUM: "长度超出最小长度"
  LENGTH_BIGGER_THEN_MAXIMUM: "长度超出最大长度"
  INVALID_VALUE: "无效值"
  NOT_A_NUMBER: "不是数字"
  UNDERFLOW: "下溢"
  OVERFLOW: "上溢"
});
```

### Events

```javascript
$("[name]").on({
  "H5F:valid": function( e, field ) {
    // 验证通过时执行
  },
  "H5F:invalid": function( e, field ) {
    // 验证未通过时执行
  }
});
```
