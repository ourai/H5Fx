submitButtonSelector = ":submit, :image, :reset"
validateFieldSelector = "[name]:not([type='hidden'], #{submitButtonSelector})"

# 默认设置
defaultSettings =
  # 立即验证
  immediate: false

initCount = 0

# 当前的 IE 浏览器版本是否小于指定版本
lowerThan = ( ver ) ->
  info = navigator.userAgent.toLowerCase().match /msie (\d+\.\d+)/

  return if info? then info[1] * 1 < ver else false

# 对字段进行验证
validateField = ( form, field ) ->
  field.reset()
  field.validated = true
  
  if field.validate()
    form.invalidCount-- if field.__counted is true
    field.__counted = false
  else
    form.invalidCount++ if field.__counted isnt true
    field.__counted = true

  return field

# 在提交时对没有验证过的表单元素进行验证
validateOtherFields = ( inst, immediate ) ->
  return if not inst.sequence?

  $.each inst.sequence, ( idx, name ) ->
    field = inst.fields[name]
    ele = field.element
    checkable = field.__checkable

    if not checkable
      # 因为设置了 disabled 属性而被跳过验证的表单元素
      # 在被动态移除 disabled 属性时重新启用验证
      if field.__disabled is true
        field.enableValidation() if field.isDisabled() is false
      # 有 disabled 属性的表单元素设置为不进行验证操作
      else
        field.disableValidation(true) if field.isDisabled() is true
    
    field.validated = false if (not checkable and hasAttr(ele, "data-h5f-associate")) or not immediate

    $(if checkable then ele[0] else ele).trigger(EVENT.VALIDATE) if field.isEnabled() and field.validated is false

    return true

# 绑定事件
bindEvent = ( form, inst, immediate ) ->
  form.on EVENT.VALIDATE, "[name]", ->
    f = inst.fields[$(@).prop("name")]

    validateField(inst, f) if f.isEnabled()

    return f

  if immediate is true
    form.on "change.H5F", "[name]:checkbox, [name]:radio, select[name]", ->
      $(@).trigger EVENT.VALIDATE

    form.on (if lowerThan(9) then "change.H5F" else "input.H5F"), "[name]:not(:checkbox, :radio, #{submitButtonSelector}, select, option)", ->
      $(@).trigger EVENT.VALIDATE

  form.on "submit.H5F", ( e ) ->
    $(@).trigger EVENT.BEFORE_VALIDATE, inst

    validateOtherFields inst, immediate

    # 有无效字段时阻止提交
    if inst.invalidCount > 0
      e.preventDefault()
      e.stopImmediatePropagation()
    else
      $(@).trigger EVENT.SUBMIT, [inst, e]

# 十进制转换为十六进制
toHex = ( num ) ->
  return num.toString 16

# 生成实例 ID
generateInstId = ->
  return "H5F0RM#{toHex initCount}#{toHex (new Date).getTime()}#{toHex Form.forms.length + 1}"

# 获取实例 ID
getInstId = ( form ) ->
  if $.type(form) is "object"
    id = (if form.nodeType is 1 then form else (form.get?(0) ? {}))["H5F-form"]
  else if $.type(form) is "string"
    id = form

  return id

# 对字段序列重新排序
reorderSequence = ->
  seq = []
  fields = {}

  # 获取新的字段序列
  $("#{validateFieldSelector}", $(@form)).each ( idx, el ) =>
    name = $(el).attr "name"

    if not fields[name]?
      fields[name] = @addField(new Field el)
      seq.push name

    return

  return seq

# 更新字段的引用
updateFieldsRef = ->
  seq = reorderSequence.call @

  # 新的字段序列长度为零时删除字段相关引用
  if seq.length is 0
    delete @fields
    delete @sequence
  else
    # 剔除新的字段序列中不存在的字段引用
    $.each @sequence, ( idx, name ) =>
      delete @fields[name] if $.inArray(name, seq) is -1

      return

    # 将新的字段序列保存到表单实例上
    @sequence = seq

  return @fields

class Form
  constructor: ( form ) ->
    @form = form
    @novalidate = hasAttr form, "novalidate"
    @invalidCount = 0

    initCount++

    $("#{validateFieldSelector}", $(form)).each ( idx, el ) =>
      return @addField(new Field el)

  addField: ( field ) ->
    @fields = {} if not @fields?
    @sequence = [] if not @sequence?

    name = field.name

    if not @fields[name]?
      field.__form = @
      field.validated = false

      @fields[name] = field
      @sequence.push name

    return field

  # 添加额外的验证
  addValidation: ( fieldName, opts ) ->
    return @fields[fieldName]?.addValidation opts

  # 使目标字段验证失效
  disableValidation: ( fieldName ) ->
    return @fields[fieldName]?.disableValidation()

  # 使目标字段验证有效
  enableValidation: ( fieldName, validate ) ->
    return @fields[fieldName]?.enableValidation validate

  # 更新表单的验证字段列表
  update: ->
    updateFieldsRef.call @

    $(@form).trigger EVENT.UPDATED

    return @

  ###
  # 销毁实例
  # 
  # @method  destroy
  # @return  {DOM}
  ###
  destroy: ->
    form = $ @form

    # 解绑事件
    form.off ".H5F"
    $("[name]", form).off ".H5F"

    $(".H5F-label--required", form).removeClass "H5F-label--required"

    # 恢复表单默认的 HTML5 验证属性
    if @novalidate
      form.attr "novalidate", true
    else
      form.removeAttr "novalidate"

    # 删除引用
    delete @constructor.forms[@form["H5F-form"]]
    delete @form["H5F-form"]

    @constructor.forms.length--

    form.trigger EVENT.DESTROY

    return form.get(0)

  @RULES = $.extend true, {}, RULE

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
        id = generateInstId inst

        # 将实例与 form 元素的独有 ID 关联并保存
        F.forms[id] = inst
        F.forms.length++

        @[flag] = id
        form.attr "novalidate", true

        bindEvent(form, inst, opts.immediate is true) if not form.attr("data-h5f-novalidate")?

  ###
  # 获取指定实例
  # 
  # @method  get
  # @param   form {DOM/jQuery/String}
  # @return  {Object}
  ###
  @get = ( form ) ->    
    return @forms[getInstId form]

  # 自定义出错信息
  @errors = ( msgs ) ->
    return $.extend ERROR, msgs

  # 自定义验证规则
  @rules = ( rules ) ->
    return (@RULES = $.extend(true, {}, $.extend(RULE, rules)))
