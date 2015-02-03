# 对字段进行验证
validateField = ( form, field ) ->
  field.reset()
  field.validated = true
  
  if field.validate()
    form.invalidCount = --form.invalidCount if field.counted is true
    field.counted = false
  else
    form.invalidCount = ++form.invalidCount if field.counted isnt true
    field.counted = true

  return field

# 绑定事件
bindEvent = ( form, inst, immediate ) ->
  if immediate is true
    $("[name]:checkbox, [name]:radio", form).on "change", ->
      validateField inst, inst.fields[$(@).prop("name")]

    $("[name]:not(:checkbox, :radio)", form).on "blur", ->
      validateField inst, inst.fields[$(@).prop("name")]

  form.on "submit", ( e ) ->
    # 在提交时对没有验证过的表单元素进行验证
    $.each inst.sequence, ( idx, name ) ->
      field = inst.fields[name]
      field.validated = false if not immediate
      validateField(inst, field) if field.validated is false

      return true

    # 有无效字段时阻止提交
    if inst.invalidCount > 0
      e.preventDefault()
      e.stopImmediatePropagation()

# 默认设置
defaultSettings =
  # 立即验证
  immediate: false

class Form
  constructor: ( form ) ->
    inst = @
    @invalidCount = 0

    $("[name]:not(select, [type='hidden'])", $(form)).each ->
      ipt = $ @
      name = ipt.prop "name"

      inst.addField new Field @

  addField: ( field ) ->
    @fields = {} if not @fields?
    @sequence = [] if not @sequence?

    name = field.name

    if not @fields[name]?
      field.validated = false

      @fields[name] = field
      @sequence.push name

    return field

  @version = LIB_CONFIG.version

  # 初始化
  @init = ( forms, settings ) ->
    F = @

    $(forms).each ->
      form = $(@)
      flag = "H5F-inited"
      settings = $.extend {}, defaultSettings, settings, {
          immediate: do ->
            attr = form.attr "data-h5f-immediate"

            if attr is "true"
              attr = true
            else if attr is "false"
              attr = false
            else
              attr = undefined

            return attr
        }

      if form.data(flag) isnt true
        form.data flag, true
        form.attr "novalidate", true
        bindEvent(form, new F(@), settings.immediate) if not form.attr("data-h5f-novalidate")?

  # 自定义出错信息
  @errors = ( msgs ) ->
    return $.extend ERROR, msgs

  # 自定义验证规则
  @rules = ( rules ) ->
    return $.extend RULE, rules
