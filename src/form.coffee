bindEvent = ( form ) ->
  form.on "submit", ( e ) ->
    passed = true

    $.each $(@).data("H5F-fields") ? [], ->
      @reset()

      if not @validate()
        passed = false

      return true

    if not passed
      e.preventDefault()
      e.stopImmediatePropagation()

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
          groupName = {}

          $("[name]:not(select, [type='hidden'])", form).each ->
            ipt = $ @
            name = ipt.prop "name"

            if ipt.prop("type") in ["radio", "checkbox"]
              if not groupName[name]?
                groupName[name] = true

                fields.push new Field @
            else
              fields.push new Field @

          bindEvent form.data "H5F-fields", fields

        form.data flag, true

  # 自定义出错信息
  errors: ( msgs ) ->
    return $.extend ERROR, msgs

  # 自定义验证规则
  rules: ( rules ) ->
    return $.extend RULE, rules
