$(document).ready ->
  H5F.init $("form")
  H5F.errors
    COULD_NOT_BE_EMPTY: "{{LABEL}}的值不能为空"
    UNKNOWN_INPUT_TYPE: "{{LABEL}}字段为未知类型"
    LENGTH_SMALLER_THAN_MINIMUM: "{{LABEL}}的字符串长度请保持在在 {{MINLENGTH}}-{{MAXLENGTH}}"
    LENGTH_BIGGER_THAN_MAXIMUM: "{{LABEL}}的字符串长度请保持在在 {{MINLENGTH}}-{{MAXLENGTH}}"
    INVALID_VALUE: "{{LABEL}}为无效值"
    NOT_A_NUMBER: "{{LABEL}}不是数字"
    UNDERFLOW: "{{LABEL}}中所输入数字请在 {{MIN}}-{{MAX}} 范围内"
    OVERFLOW: "{{LABEL}}中所输入数字请在 {{MIN}}-{{MAX}} 范围内"

  $("[name]").on
    "H5F:valid": ( e, field ) ->
      $(field.element)
        .parent ".form-group"
        .removeClass "has-error"
        .addClass "has-success"
    "H5F:invalid": ( e, field ) ->
      $(field.element)
        .parent ".form-group"
        .removeClass "has-success"
        .addClass "has-error"

      console.log field.element.id, field.message
