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
* `number`
* `checkbox`
* `radio`

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

### Error messages

现在内部提供的几个错误信息及触发条件如下：

* `COULD_NOT_BE_EMPTY` - 必填字段为空
* `UNKNOWN_INPUT_TYPE` - 未知 `type` 类型
* `LENGTH_SMALLER_THAN_MINIMUM` - 长度小于 `minlength` 属性所指定的值
* `LENGTH_BIGGER_THAN_MAXIMUM` - 长度大于 `maxlength` 属性所指定的值
* `INVALID_VALUE` - 不符合 `pattern` 属性所定义的模式
* ~~`NOT_AN_ABSOLUTE_URL` - 不符合 URL 格式~~
* `NOT_AN_EMAIL` - 不符合 E-mail 格式
* `NOT_A_NUMBER` - 不是数字
* `UNDERFLOW` - 小于 `min` 属性所指定的值
* `OVERFLOW` - 大于 `max` 属性所指定的值
* `DIFFERENT_VALUE` - 与被关联的字段值不同

错误信息可以通过 `H5F.error()` 来自定义。

```javascript
H5F.errors({
  LENGTH_SMALLER_THAN_MINIMUM: "{{LABEL}}不能少于{{MINLENGTH}}个字"
  LENGTH_BIGGER_THAN_MAXIMUM: "{{LABEL}}不能多于{{MAXLENGTH}}个字"
  UNDERFLOW: "{{LABEL}}不能小于{{MIN}}"
  OVERFLOW: "{{LABEL}}不能大于{{MAX}}"
});
```

上面的代码中出现了 `{{KEY}}` 形式的字符串，这是错误信息中的「变量」，以便丰富信息内容。除了所示的方式外，还可以用 `"{{LABEL}}中所输入数字请在{{MIN}}～{{MAX}}范围内"` 这种包含多种限制条件的形式。

目前所支持的变量及其获取值的来源如下：

* `LABEL` - 默认为字段所对应的 `<label>` 标签的文本，也可通过 `<input data-h5f-label="自定义标签">` 的形式设置
* `VALUE` - 字段的值
* `ASSOCIATE_LABEL` - 关联字段的标签文本，取值方式与 `LABEL` 一样
* `MINLENGTH` - `minlength` 属性的值
* `MAXLENGTH` - `maxlength` 属性的值
* `MIN` - `min` 属性的值
* `MAX` - `max` 属性的值

### Events

```javascript
// 表单的事件
$("form").on({
  "H5F:beforeValidate": function( event, formInst ) {
    // 在进行最后的字段校验前触发
  ,
  "H5F:submit": function( event, formInst, submitEvent ) {
    // 在字段校验全部通过后触发
    // 阻止表单的提交行为
    submitEvent.preventDefault();
  }
});

// 字段的事件
$("[name]").on({
  "H5F:valid": function( event, fieldInst ) {
    // 验证通过时执行
  },
  "H5F:invalid": function( event, fieldInst ) {
    // 验证未通过时执行
  }
});
```
