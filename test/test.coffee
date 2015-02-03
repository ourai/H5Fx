$(document).ready ->
  H5F.init $("form")
  H5F.errors
    COULD_NOT_BE_EMPTY: "不能为空"
    UNKNOWN_INPUT_TYPE: "未知类型"
    LENGTH_SMALLER_THAN_MINIMUM: "长度超出最小长度"
    LENGTH_BIGGER_THAN_MAXIMUM: "长度超出最大长度"
    INVALID_VALUE: "无效值"
    NOT_A_NUMBER: "不是数字"
    UNDERFLOW: "下溢"
    OVERFLOW: "上溢"

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
