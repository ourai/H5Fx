$(document).ready ->
  H5F.init $("form"), immediate: true

  H5F.errors
    UNKNOWN_INPUT_TYPE: "{{LABEL}}字段为未知类型"
    COULD_NOT_BE_EMPTY: "{{LABEL}}的值不能为空"
    LENGTH_SMALLER_THAN_MINIMUM: "{{LABEL}}的字符串长度请保持在在 {{MINLENGTH}}-{{MAXLENGTH}}"
    LENGTH_BIGGER_THAN_MAXIMUM: "{{LABEL}}的字符串长度请保持在在 {{MINLENGTH}}-{{MAXLENGTH}}"
    INVALID_VALUE: "{{LABEL}}的值{{VALUE}}为无效值"
    NOT_AN_EMAIL: "{{LABEL}}不符合电子邮箱的格式"
    NOT_A_NUMBER: "{{LABEL}}不是数字"
    UNDERFLOW: "{{LABEL}}中所输入数字请在 {{MIN}}-{{MAX}} 范围内"
    OVERFLOW: "{{LABEL}}中所输入数字请在 {{MIN}}-{{MAX}} 范围内"
    DIFFERENT_VALUE: "{{LABEL}}的值没有与{{ASSOCIATE_LABEL}}保持一致"
    AT_LEAST_CHOOSE_ONE: "请从{{LABEL}}中选择一项"
    SHOOLD_BE_CHOSEN: "请选中{{UNIT_LABEL}}"
    SHOOLD_CHOOSE_AN_OPTION: "必须从{{LABEL}}中选择一项"
    NOT_A_MOBILE: "{{LABEL}}不是一个手机号码"

  H5F.rules
    MOBILE:
      rule: /^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$/
      message: "NOT_A_MOBILE"

  $("form").on
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
    , "[name]"

  $("form").on
    "H5F:submit": ( e, inst, sub ) ->
      console.log "submit"
      # sub.preventDefault()
      # sub.stopImmediatePropagation()
      return false
    "H5F:destroy": ( e ) ->
      console.log "destroy"

      $(".help-block", $(@)).remove()
      $(".has-error", $(@)).removeClass "has-error"

  f1 = $("#form_1")

  f1.on "H5F:submit", ->
    console.log "form_1 submit"
    return "form_1"

  f1_inst = H5F.get f1
  
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

  window.testForm = H5F.get $("#form_0")

$(document).on
  "H5F:enabled": ->
    console.log @, "enabled"
  "H5F:disabled": ->
    console.log @, "disabled"
  , "[name]"

window.addTestInput = ( type = "text" ) ->
  form = $("#form_0")
  idx = $("[type='#{type}']", form).size()
  id = "form_0_#{type}_#{idx}"

  form.prepend  """
                <div class="form-group">
                  <label for="#{id}">#{id}</label>
                  <input id="#{id}" class="form-control" name="#{id}" type="#{type}" required="required">
                </div>
                """
