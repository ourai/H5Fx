# API

##### 获取指定表单的 `H5F` 实例

```javascript
// "H5F-form" 存储的是已经初始化的表单所对应的 `H5F` 实例的 ID
var h5f = H5F.get($("form").data("H5F-form"));
```

##### 添加额外的验证

```javascript
// `.addValidation` 的第一个参数是字段的 `name` 属性值
// 第二个参数中的 `handler` 只有返回 `true` 的时候才当作验证通过
// 第二个参数中的 `message` 除了可以是任意的字符串，还可以是 Error message 的 key 或返回字符串的函数
h5f.addValidation("field", {
  handler: function() {
    return this.value === "";
  },
  message: "The field's value must not be empty!"
});
```

##### 自定义错误信息

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
* `UNIT_LABEL` - 成组字段中每个字段的标签文本，取值方式与 `LABEL` 一样
* `LENGTH` - `value` 属性的字符串长度
* `MINLENGTH` - `minlength` 属性的值
* `MAXLENGTH` - `maxlength` 属性的值
* `MIN` - `min` 属性的值
* `MAX` - `max` 属性的值
