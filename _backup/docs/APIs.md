# API

##### 初始化

```js
H5F.init();
```

##### 自定义验证规则

```js
H5F.rules();
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

##### 获取指定表单的 `H5F` 实例

```javascript
// "H5F-form" 存储的是已经初始化的表单所对应的 `H5F` 实例的 ID
var h5f = H5F.get($("form").data("H5F-form"));
```

##### 添加要验证的字段

```js
h5f.addField();
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

##### 销毁制定表单的 `H5F` 实例

```js
H5F.destroy(h5f);
```
