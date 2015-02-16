EVENT =
  BEFORE_VALIDATE: "H5F:beforeValidate"
  SUBMIT: "H5F:submit"
  VALIDATE: "H5F:validate"

subBtnSels = ":submit, :image, :reset"

# 默认设置
defaultSettings =
  # 立即验证
  immediate: false

# 当前的 IE 浏览器版本是否小于指定版本
lowerThan = ( ver ) ->
  info = navigator.userAgent.toLowerCase().match /msie (\d+\.\d+)/

  return if info? then info[1] * 1 < ver else false

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

# 在提交时对没有验证过的表单元素进行验证
validateOtherFields = ( inst, immediate ) ->
  $.each inst.sequence, ( idx, name ) ->
    field = inst.fields[name]
    field.validated = false if not immediate
    ele = field.element

    $(if $.isArray(ele) then ele[0] else ele).trigger(EVENT.VALIDATE) if field.validated is false

    return true

# 绑定事件
bindEvent = ( form, inst, immediate ) ->
  $("[name]", form).on EVENT.VALIDATE, ->
    validateField inst, inst.fields[$(@).prop("name")]

  if immediate is true
    $("[name]:checkbox, [name]:radio", form).on "change", ->
      $(@).trigger EVENT.VALIDATE

    $("[name]:not(:checkbox, :radio, #{subBtnSels}, select, option)", form).on (if lowerThan(9) then "change" else "input"), ->
      $(@).trigger EVENT.VALIDATE

  form.on "submit", ( e ) ->
    $(@).trigger EVENT.BEFORE_VALIDATE, inst

    validateOtherFields inst, immediate

    # 有无效字段时阻止提交
    if inst.invalidCount > 0
      e.preventDefault()
      e.stopImmediatePropagation()
    else
      $(@).trigger EVENT.SUBMIT, [inst, e]

generateFormId = ->
  return "H5F#{(new Date).getTime().toString(16)}F0RM#{(Form.forms.length + 1).toString(16)}"

class Form
  constructor: ( form ) ->
    inst = @
    @invalidCount = 0

    $("[name]:not(select, [type='hidden'], #{subBtnSels})", $(form)).each ->
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

  # 添加额外的验证
  addValidation: ( fieldName, opts ) ->
    return @fields[fieldName]?.addValidation opts

  @version = LIB_CONFIG.version

  # 已初始化的实例
  @forms =
    length: 0

  # 初始化
  @init = ( forms, settings ) ->
    F = @

    $(forms).each ->
      form = $(@)
      flag = "H5F-form"
      opts = $.extend {}, defaultSettings, settings, {
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

      if not @[flag]?
        inst = new F @
        id = generateFormId inst

        # 将实例与 form 元素的独有 ID 关联并保存
        F.forms[id] = inst
        F.forms.length++

        @[flag] = id
        form.attr "novalidate", true

        bindEvent(form, inst, opts.immediate is true) if not form.attr("data-h5f-novalidate")?

  # 自定义出错信息
  @errors = ( msgs ) ->
    return $.extend ERROR, msgs

  # 自定义验证规则
  @rules = ( rules ) ->
    return $.extend RULE, rules

  ###
  # 获取指定实例
  # 
  # @method  get
  # @param   form {DOM/jQuery}
  # @return  {Object}
  ###
  @get = ( form ) ->
    return if $.type(form) is "object" then @forms[(if form.nodeType is 1 then form else (form.get?(0) ? {}))["H5F-form"]] else undefined
