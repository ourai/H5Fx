$(document).ready ->
  H5F.init $("form"), immediate: true

  H5F.errors
    COULD_NOT_BE_EMPTY: "{{LABEL}}的值不能为空"
    UNKNOWN_INPUT_TYPE: "{{LABEL}}字段为未知类型"
    LENGTH_SMALLER_THAN_MINIMUM: "{{LABEL}}的字符串长度请保持在在 {{MINLENGTH}}-{{MAXLENGTH}}"
    LENGTH_BIGGER_THAN_MAXIMUM: "{{LABEL}}的字符串长度请保持在在 {{MINLENGTH}}-{{MAXLENGTH}}"
    INVALID_VALUE: "{{LABEL}}的值{{VALUE}}为无效值"
    NOT_A_NUMBER: "{{LABEL}}不是数字"
    UNDERFLOW: "{{LABEL}}中所输入数字请在 {{MIN}}-{{MAX}} 范围内"
    OVERFLOW: "{{LABEL}}中所输入数字请在 {{MIN}}-{{MAX}} 范围内"

  $("[name]").on
    "H5F:valid": ( e, field ) ->
      $(field.element)
        .closest ".form-group"
        .removeClass "has-error"
        .children ".help-block"
        .hide()

    "H5F:invalid": ( e, field ) ->
      group = $(field.element).closest ".form-group"

      group.append("<p class=\"help-block\" />") if $(".help-block", group).size() is 0

      group
        .addClass "has-error"
        .children ".help-block"
        .show()
        .text field.message

  $("form").on "H5F:submit", ( e, inst, sub ) ->
    console.log "submit"
    # sub.preventDefault()
    # sub.stopImmediatePropagation()
    return false

  f1 = $("#form_1")

  f1.on "H5F:submit", ->
    console.log "form_1 submit"
    return "form_1"

  f1_inst = H5F.get f1.data("H5F-form")
  
  f1_inst.addValidation "form_1_1", {
      handler: ->
        return not isNaN Number(@value)
      message: "啊哈哈"
    }

  f1_inst.addValidation "form_1_1", {
      handler: ->
        return @value.length > 5
      message: ->
        return "长度不对"
    }

  $("#form_2").on "H5F:submit", ->
    console.log "form_2 submit"
    return "form_2"
