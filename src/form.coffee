Form =
  version: LIB_CONFIG.version

  # 初始化
  init: ( forms ) ->
    $(forms).each ->
      form = $(@)
      flag = "H5F-inited"

      if form.data(flag) isnt true
        form.attr "novalidate", true

        if not form.attr("data-novalidate")?
          fields = []

          $("[name]:not(select, [type='checkbox'], [type='radio'], [type='hidden'])", form).each ->
            fields.push new Field @

          form.data "H5F-fields", fields

        form.data flag, true

  # 自定义出错信息
  errors: ( msgs ) ->
    return $.extend ERROR, msgs

  # 自定义验证规则
  rules: ( rules ) ->
    return $.extend RULE, rules

$(document).on "submit", "form:not([data-novalidate])", ->
  passed = true

  $.each $(@).data("H5F-fields") ? [], ->
    @reset()

    if not @validate()
      passed = false

    return true

  return passed
