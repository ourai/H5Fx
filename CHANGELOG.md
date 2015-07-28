# CHANGES

## 0.1.1

### Features
  * 添加 `H5F.prototype.destroy()`
  * 添加 `H5F.prototype.disableValidation()` 和 `H5F.prototype.enableValidation()`
  * 添加 `Field.prototype.isEnabled()` 用于判断目标字段的验证是否有效
  * 表单字段元素可以绑定 `H5F:disabled` 和 `H5F:enabled` 事件以对失效、有效操作进行反馈
  * 添加 `Field.prototype.disableValidation()` 和 `Field.prototype.enableValidation()` 用于对目标字段的验证有效性进行操作
  * 将验证规则的正则表达式抛出到全局变量中——`H5F.RULES`
  * 添加 `H5F.prototype.update()`

### Deprecations
  * 移除 `H5F.destroy()`

### Bug fixes
  * 验证 `<input type="number">` 的值时不支持负数、小数等
  * 验证时遇到 `checkbox` 和 `radio` 会报错
  * 修复 `<input disabled="disabled">` 时没有跳过验证步骤

## 0.1.0

### Features
  * 增加对 `<select>` 的验证
  * 初始化时将必填字段的 `<label>` 加上 `class` 属性 `H5F-label--required`
  * 通过 `H5F.destroy()` 销毁已初始化过的表单，并触发 `H5F:destroy` 事件
  * 通过 `H5F.prototype.addValidation()` 添加额外的验证条件
  * 增加 `H5F:beforeValidate` 事件，在进行最后的字段校验前触发
  * 增加 `H5F:submit` 事件，在字段校验全部通过后触发
  * 错误信息中支持多个变量
  * 字段增加值关联判断
  * 能够获取指定 Form 实例
  * 支持 `type` 值为 `search`、`email` 的 `<input>`
  * 对 `minlength` 和 `maxlength` 属性进行验证

### Enhancements
  * 优化 `checkbox` 和 `radio` 的错误提示
  * `pattern` 属性可以通过 `{{PATTERN_KEY}}` 的形式指定已定义的正则表达式
  * 可配置是否输入后立即验证（默认为表单提交时才验证）
