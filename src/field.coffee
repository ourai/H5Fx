PATTERN_KEY_SOURCE = "\{\{\s*([A-Z_]+)\s*\}\}"

RULE =
  ABSOLUTE_URL: /^.*$/
  # from https://html.spec.whatwg.org/multipage/forms.html#e-mail-state-(type=email)
  EMAIL: /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
  NUMBER: /^\d+(\.0+)?$/

ERROR =
  COULD_NOT_BE_EMPTY: "{{LABEL}} could not be empty."
  UNKNOWN_INPUT_TYPE: "Unknown input type for {{LABEL}}."
  LENGTH_SMALLER_THAN_MINIMUM: "The length of {{LABEL}} is smaller than {{MINLENGTH}}."
  LENGTH_BIGGER_THAN_MAXIMUM: "The length of {{LABEL}} is bigger than {{MAXLENGTH}}."
  INVALID_VALUE: "{{LABEL}}'s value is invalid."
  NOT_AN_ABSOLUTE_URL: "{{LABEL}} isn't an absolute URL."
  NOT_AN_EMAIL: "{{LABEL}} isn't an E-mail."
  NOT_A_NUMBER: "{{LABEL}} isn't a number."
  UNDERFLOW: "{{LABEL}}'s value is smaller than {{MIN}}."
  OVERFLOW: "{{LABEL}}'s value is bigger than {{MAX}}."
  DIFFERENT_VALUE: "{{LABEL}}'s value is different from {{ASSOCIATE_LABEL}}."

# 表单元素类型
elementType = ( ele ) ->
  switch ele.get(0).tagName.toLowerCase()
    when "textarea" then type = "textarea"
    when "input" then type = ele.attr("type") ? "text"

  return type

# 是否为成组的表单元素
isGroupedElement = ( ele ) ->
  return $.inArray($(ele).prop("type"), ["radio", "checkbox"]) isnt -1

# 是否拥有某个 HTML 属性
hasAttr = ( ele, attr ) ->
  return ele.hasAttribute attr

# 重置验证结果相关属性
reset = ->
  @valid = true
  @message = ""

# 转换为数字
toNum = ( str ) ->
  return parseFloat str

# 获取极值
getExtremum = ( ele, type ) ->
  val = $(ele).prop type

  return if $.isNumeric(val) then toNum(val) else null

# 获取字段文本标签
fieldLabel = ( ele ) ->
  id = ele.attr "id"
  labelText = ele.attr "data-h5f-label"

  if not labelText?
    label = if id? then $("label[for='#{id}']") else ele.closest("label")
    labelText = if label.size() > 0 then $.trim(label.text()) else ""

  return labelText

# 获取关联的字段元素
associatedElement = ( ele ) ->
  return $ "##{$(ele).attr "data-h5f-associate"}"

class Field
  constructor: ( ele ) ->
    ele = $ ele

    @label = fieldLabel ele
    @type = elementType ele
    @name = ele.prop "name"
    @form = ele.closest("form").get 0

    @__validations = []

    if isGroupedElement(ele)
      @element = $.makeArray $("[name='#{@name}']", $(@form))
      @required = $("[name='#{@name}'][required]", $(@form)).size() > 0
    else
      @element = ele.get 0
      @required = hasAttr @element, "required"
      @pattern = ele.attr "pattern"

    reset.call @

  # 获取字段的值
  # 如果是 radio 或 checkbox 等则值为被选中的对象的
  value: ->
    return if isGroupedElement(@element) then $("[name='#{@name}']:checked", $(@form)).val() else $(@element).val()

  reset: reset

  # 获取错误信息
  error: ( MSG ) ->
    f = @
    ele = $ f.element

    return ERROR[MSG].replace new RegExp(PATTERN_KEY_SOURCE, "g"), ( match, key ) ->
      switch key
        when "LABEL" then text = f.label
        when "VALUE" then text = f.value()
        when "ASSOCIATE_LABEL" then text = fieldLabel associatedElement ele
        when "MINLENGTH" then text = ele.attr "minlength"
        when "MAXLENGTH" then text = ele.attr "maxlength"
        when "MIN" then text = getExtremum ele, "min"
        when "MAX" then text = getExtremum ele, "max"

      return text

  # 验证字段有效性
  validate: ->
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
      if @valid and not isGroupedElement(ele) and hasAttr(ele, "data-h5f-associate")
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

    $(if $.isArray(ele) then ele[0] else ele).trigger "H5F:#{if @valid then "valid" else "invalid"}", @

    return @valid

  # 添加额外的验证
  # opts 为 {handler: function() {}, message: ""} 的形式
  # 其中 message 可以为 Error Message 的 key、自定义的字符串或返回字符串的函数
  addValidation: ( opts ) ->
    @__validations.push opts

    return opts
