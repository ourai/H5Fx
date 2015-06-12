# 初始化字段属性
fieldProps = ( ele ) ->
  ele = $ ele
  form = ele.closest("form").eq(0)

  @form = form.get 0
  @type = elementType ele
  @name = ele.prop "name"

  @__form = null
  @__counted = false
  @__enabled = true
  @__checkable = $.inArray(ele.prop("type"), ["radio", "checkbox"]) isnt -1
  @__validations = []

  if @__checkable
    elements = $("[name='#{@name}']", form)
    requiredElements = elements.closest requiredAttr(@type)

    @__defaultValue = elements.closest ":checked"

    @element = $.makeArray elements
    @required = requiredElements.size() > 0
    @label = fieldLabel (if @required then requiredElements.eq(0) else $(@element[0])), form

    @validate = validateCheckableElements
  else
    @element = ele.get 0
    @required = hasAttr @element, "required"
    @label = fieldLabel ele, form

    if @element.tagName.toLowerCase() is "select"
      @__defaultValue = $(":selected", ele)

      @validate = validateSelectElement
    else
      @__defaultValue = ele.val()

      @validate = validateTextualElements
      @pattern = ele.attr "pattern"

    labelElement(ele, form).addClass("H5F-label--required") if @required

  reset.call @

# 表单元素类型
# 在不支持 HTML5 中所定义的 type 值的浏览器中只能通过 $.fn.attr 来获取到真正的字符串
# 否则，通过 $.fn.prop 获取到的都是 "text"
elementType = ( ele ) ->
  return if ele.get(0).tagName.toLowerCase() is "input" then ele.attr("type") ? "text" else ele.prop "type"

# 获取极值
getExtremum = ( ele, type ) ->
  return if $.isNumeric(val = $(ele).prop type) then toNum(val) else null

# 获取标签元素
labelElement = ( ele, form ) ->
  return if (id = ele.attr "id")? then $("label[for='#{id}']", form) else ele.closest("label")

# 获取字段文本标签
fieldLabel = ( ele, form, customizable ) ->
  labelText = ele.attr("data-h5f-label") if customizable isnt false

  if not labelText?
    label = labelElement ele, form
    labelText = if label.size() > 0 then $.trim(label.text()) else ""

  return labelText

# 获取关联的字段元素
associatedElement = ( ele ) ->
  return $ "##{$(ele).attr "data-h5f-associate"}"

# 重置验证结果相关属性
reset = ->
  @valid = true
  @message = ""

  return

# 将字段恢复到初始值
resetDefaultValue = ->
  elem = $ @element

  if @__checkable
    elem.closest(":checked").prop "checked", false
    $(@__defaultValue).prop "checked", true
  else if @element.tagName.toLowerCase() is "select"
    $(":selected", elem).prop "selected", false
    $(@__defaultValue).prop "selected", true
  else
    elem.val @__defaultValue

  return

# 清除字段状态
resetFieldStatus = ->
  @__counted = false
  @validated = false

  reset.call @
  resetDefaultValue.call @

  return

# 触发有效性事件
triggerValidityEvent = ( field, ele ) ->  
  return $(ele).trigger (if field.valid then EVENT.VALID else EVENT.INVALID), field

# 获取必填可选择字段的属性选择器
requiredAttr = ( isCheckbox ) ->
  isCheckbox = isCheckbox is "checkbox" if $.type(isCheckbox) is "string"

  return "[#{if isCheckbox then "data-h5f-" else ""}required]"

# 验证文本类字段的有效性
validateTextualElements = ->
  ele = @element
  val = @value()

  if @required and $.trim(val) is ""
    @valid = false
    @message = @error "COULD_NOT_BE_EMPTY"
  else
    # 根据 HTML5 属性进行常规验证
    switch @type
      when "text", "search", "tel", "url", "email", "password", "textarea"
        # 字符串最小长度
        if hasAttr(ele, "minlength") and val.length < $(ele).attr("minlength") * 1
          @valid = false
          @message = @error "LENGTH_SMALLER_THAN_MINIMUM"
        # 字符串最大长度
        else if hasAttr(ele, "maxlength") and val.length > $(ele).attr("maxlength") * 1
          @valid = false
          @message = @error "LENGTH_BIGGER_THAN_MAXIMUM"
        # 字符串模式
        else
          if val isnt ""
            # URL
            if @type is "url"
              @valid = RULE.ABSOLUTE_URL.test val
              @message = @error("NOT_AN_ABSOLUTE_URL") if not @valid
            # E-mail
            else if @type is "email"
              @valid = RULE.EMAIL.test val
              @message = @error("NOT_AN_EMAIL") if not @valid

          # 自定义
          if @valid and @pattern? and @pattern isnt ""
            @valid = (RULE[@pattern.match(new RegExp "^\s*#{PATTERN_KEY_SOURCE}\s*$")?[1] ? ""] ? new RegExp "^#{@pattern}$").test val
            @message = @error("INVALID_VALUE") if not @valid
      when "number"
        if val isnt ""
          @valid = RULE.NUMBER.test val

          if @valid
            minVal = getExtremum ele, "min"
            maxVal = getExtremum ele, "max"

            # 低于最小值
            if minVal? and toNum(val) < minVal
              @valid = false
              @message = @error "UNDERFLOW"
            # 高于最大值
            else if maxVal? and toNum(val) > maxVal
              @valid = false
              @message = @error "OVERFLOW"
          else
            @message = @error "NOT_A_NUMBER"
      else
        @message = @error "UNKNOWN_INPUT_TYPE"

    # 对有关联字段的字段进行验证
    if @valid and hasAttr(ele, "data-h5f-associate")
      acEle = associatedElement ele

      if acEle.size()
        @valid = val is acEle.val()
        @message = @error("DIFFERENT_VALUE") if not @valid

    # 进行额外的验证
    if @valid and @__validations.length > 0
      $.each @__validations, ( idx, opts ) =>
        @valid = if $.isFunction(opts.handler) then opts.handler.call(ele) is true else false
        @message = (if /^[A-Z_]+$/.test(opts.message) then @error(opts.message) else opts.message?() ? opts.message) if not @valid

        return @valid

  triggerValidityEvent @, ele

  return @valid

# 验证 <select> 的有效性
validateSelectElement = ->
  if @required and $.trim(@value()) is ""
    @valid = false
    @message = @error "SHOOLD_CHOOSE_AN_OPTION"

  triggerValidityEvent @, @element

  return @valid

# 验证可选择字段的有效性
validateCheckableElements = ->
  elements = $ @element
  isCheckbox = @type is "checkbox"

  if @required and elements.closest(":checked").size() is 0
    @valid = false
    @message = @error "AT_LEAST_CHOOSE_ONE"

    ele = elements.closest requiredAttr(isCheckbox)
  else
    if isCheckbox
      ele = elements.closest "[required]"
      
      if ele.size() > 0
        ele.each ( idx, el ) =>
          @valid = $(el).is ":checked"
          @__element = el if not @valid

          return @valid

        if @valid
          delete @__element
        else
          @message = @error "SHOOLD_BE_CHOSEN"
      else
        ele = elements
    else
      ele = elements

  triggerValidityEvent @, ele.get(0)

  return @valid

class Field
  constructor: fieldProps

  # 获取字段的值
  # 如果是 radio 或 checkbox 等则值为被选中的对象的
  value: ->
    return if @__checkable then $("[name='#{@name}']:checked", $(@form)).val() else $(@element).val()

  reset: reset

  # 获取错误信息
  error: ( MSG ) ->
    f = @
    ele = $ f.element

    return ERROR[MSG].replace new RegExp(PATTERN_KEY_SOURCE, "g"), ( match, key ) ->
      switch key
        when "LABEL" then text = f.label
        when "VALUE" then text = f.value()
        when "ASSOCIATE_LABEL" then text = fieldLabel associatedElement(ele), $(f.form)
        when "UNIT_LABEL" then text = fieldLabel $(f.__element), $(f.form), false
        when "LENGTH" then text = f.value().length
        when "MINLENGTH" then text = ele.attr "minlength"
        when "MAXLENGTH" then text = ele.attr "maxlength"
        when "MIN" then text = getExtremum ele, "min"
        when "MAX" then text = getExtremum ele, "max"

      return text

  # 添加额外的验证
  # opts 为 {handler: function() {}, message: ""} 的形式
  # 其中 message 可以为 Error Message 的 key、自定义的字符串或返回字符串的函数
  addValidation: ( opts ) ->
    @__validations.push opts

    return opts

  # 使验证失效
  disableValidation: ->
    @__enabled = false
    @__form.invalidCount-- if @__counted is true

    resetFieldStatus.call @

    $(@element).trigger EVENT.DISABLED

    return @

  ###
  # 使验证有效
  # 
  # @method  enableValidation
  # @param   [validate] {Boolean}       是否立即对字段进行验证
  # @return  {Object}
  ###
  enableValidation: ( validate ) ->
    @__enabled = true
    _elem = @element

    $(_elem).trigger EVENT.ENABLED
    $(if @__checkable then _elem[0] else _elem).trigger(EVENT.VALIDATE) if validate is true

    return @

  # 获取验证的有效状态
  isEnabled: ->
    return @__enabled is true

  # 获取字段的有效状态
  isValid: ->
    return @valid is true
