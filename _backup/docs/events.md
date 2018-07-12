# Events

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
