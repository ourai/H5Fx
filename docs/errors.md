# Error messages

现在内部提供的几个错误信息及触发条件如下：

* `UNKNOWN_INPUT_TYPE` - 未知 `type` 类型
* `COULD_NOT_BE_EMPTY` - 必填字段为空
* `LENGTH_SMALLER_THAN_MINIMUM` - 长度小于 `minlength` 属性所指定的值
* `LENGTH_BIGGER_THAN_MAXIMUM` - 长度大于 `maxlength` 属性所指定的值
* `INVALID_VALUE` - 不符合 `pattern` 属性所定义的模式
* ~~`NOT_AN_ABSOLUTE_URL` - 不符合 URL 格式~~
* `NOT_AN_EMAIL` - 不符合 E-mail 格式
* `NOT_A_NUMBER` - 不是数字
* `UNDERFLOW` - 小于 `min` 属性所指定的值
* `OVERFLOW` - 大于 `max` 属性所指定的值
* `DIFFERENT_VALUE` - 与被关联的字段值不同
* `AT_LEAST_CHOOSE_ONE` - `checkbox` 拥有 `data-h5f-required` 属性或 `radio` 拥有 `required` 属性并且没有 `checked` 状态
* `SHOOLD_BE_CHOSEN` - 拥有 `required` 属性的 `checkbox` 不是 `checked` 状态

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
* `UNIT_LABEL` - 成组字段中每个字段的标签文本，取值方式与 `LABEL` 一样
* `LENGTH` - `value` 属性的字符串长度
* `MINLENGTH` - `minlength` 属性的值
* `MAXLENGTH` - `maxlength` 属性的值
* `MIN` - `min` 属性的值
* `MAX` - `max` 属性的值
