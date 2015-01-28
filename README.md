# HTML5 Form

这是一个基于 HTML5 Form 规范的表单验证插件，也就是输入字段的值是受 HTML5 规范中定义的属性制约，如：`pattern`、`min`、`max`、`minlength` 等等。

## 依赖

* [jQuery](http://jquery.com/) 1.8.0+

## 兼容性

目前只测试了 PC 端的部分浏览器：

* Internet Explorer 8 and later
* Google Chrome
* Mozilla Firefox
* Safari

## 使用方法

输入字段必须有 `name` 属性，并且必须包在 `<form>` 中。

程序会视拥有相同 `name` 的 `checkbox` 或 `radio` 为一组，只生成一个验证对象，所以每组只需给一个字段添加与验证相关的属性，并且要添加到同一个字段上。

### 基本用法

```html
<form id="form" action="/" method="get">
  <div class="form-group">
    <label class="control-label" for="form_1">文本</label>
    <input id="form_1" class="form-control" type="text" name="form_1" value="" pattern=".*0" required="required" minlength="2" maxlength="4">
  </div>
  <div class="form-group">
    <label class="control-label" for="form_2">数字</label>
    <input id="form_2" class="form-control" type="number" name="form_2" value="" required="required" min="5" max="10" pattern=".*0">
  </div>
  <div class="form-group">
    <label class="control-label" for="radio_1_1">单选框1</label>
    <input type="radio" id="radio_1_1" name="radio_1" value="1">
    <label class="control-label" for="radio_1_2">单选框2</label>
    <input type="radio" id="radio_1_2" name="radio_1" required="required" value="2">
    <label class="control-label" for="radio_1_3">单选框3</label>
    <input type="radio" id="radio_1_3" name="radio_1" value="3">
    <label class="control-label" for="radio_1_4">单选框4</label>
    <input type="radio" id="radio_1_4" name="radio_1" value="4">
  </div>
  <div class="form-group">
    <label class="control-label" for="checkbox_1_1">多选框1</label>
    <input type="checkbox" id="checkbox_1_1" name="checkbox_1" value="1">
    <label class="control-label" for="checkbox_1_2">多选框2</label>
    <input type="checkbox" id="checkbox_1_2" name="checkbox_1" required="required" value="2">
    <label class="control-label" for="checkbox_1_3">多选框3</label>
    <input type="checkbox" id="checkbox_1_3" name="checkbox_1" value="3">
    <label class="control-label" for="checkbox_1_4">多选框4</label>
    <input type="checkbox" id="checkbox_1_4" name="checkbox_1" value="4">
  </div>
  <input class="btn btn-primary btn-block" type="submit">
</form>
```

```javascript
H5F.init($("form"));
```

### 输入文本后立即验证

程序默认在表单提交时对输入字段进行验证，也可以指定在输入文本后立即对其进行验证。

#### 方式一

```javascript
H5F.init($("form"), {immediate: true});
```

#### 方式二

```html
<form data-h5f-immediate="true"></form>
```

**其中，第二种方式比第一种优先级高。**

### 阻止验证

```html
<form data-h5f-novalidate="true"></form>
```

### 设置验证的提示信息

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

### 事件绑定

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
