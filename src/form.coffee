bindEvent = ( form ) ->
  form.on "submit", ( e ) ->
    inst = $(@).data "H5F"

    if inst?
      submittable = true

      $.each inst.fields, ->
        @reset()

        submittable = false if not @validate()

        return true

      if not submittable
        e.preventDefault()
        e.stopImmediatePropagation()

class Form
  constructor: ( form ) ->
    inst = @
    initedFields = {}

    $("[name]:not(select, [type='hidden'])", $(form)).each ->
      ipt = $ @
      name = ipt.prop "name"

      if not initedFields[name]?
        inst.addField new Field @
        initedFields[name] = true

  addField: ( field ) ->
    @fields = [] if not @fields?

    @fields.push field

    return field

  @version = LIB_CONFIG.version

  # 初始化
  @init = ( forms ) ->
    F = @

    $(forms).each ->
      form = $(@)
      flag = "H5F-inited"

      if form.data(flag) isnt true
        form.data flag, true
        form.attr "novalidate", true
        bindEvent(form.data("H5F", new F @)) if not form.attr("data-novalidate")?

  # 自定义出错信息
  @errors = ( msgs ) ->
    return $.extend ERROR, msgs

  # 自定义验证规则
  @rules = ( rules ) ->
    return $.extend RULE, rules
