# CHANGES

## 0.1.0

#### 2015.01.28

* 对 `minlength` 和 `maxlength` 属性进行验证
* 可配置是否输入后立即验证（默认为表单提交时才验证）

#### 2015.01.29

* 支持 `type` 值为 `search`、`email` 的 `<input>`
* `pattern` 属性可以通过 `{{PATTERN_KEY}}` 的形式指定已定义的正则表达式

#### 2015.02.04

* 错误信息中支持多个变量
* 字段增加值关联判断
* 能够获取指定 Form 实例

#### 2015.02.08

* 增加 `H5F:beforeValidate` 事件，在进行最后的字段校验前触发
* 增加 `H5F:submit` 事件，在字段校验全部通过后触发

#### 2015.02.12

* 通过 `inst.addValidation(fieldName, options)` 添加额外的验证条件

#### 2015.02.21

* 初始化时将必填字段的 `<label>` 加上 `class` 属性 `H5F-label--required`
* 通过 `H5F.destroy(form)` 销毁已初始化过的表单，并触发 `H5F:destroy` 事件
