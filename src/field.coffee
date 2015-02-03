PATTERN_KEY = /^\s*\{\{\s*([A-Z_]+)\s*\}\}\s*$/

RULE =
  ABSOLUTE_URL: /^.*$/
  # from https://html.spec.whatwg.org/multipage/forms.html#e-mail-state-(type=email)
  EMAIL: /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
  NUMBER: /^\d+(\.0+)?$/

ERROR =
  COULD_NOT_BE_EMPTY: "Could not be empty."
  UNKNOWN_INPUT_TYPE: "Unknown input type"
  LENGTH_SMALLER_THAN_MINIMUM: "The length is smaller than {{MINLENGTH}}."
  LENGTH_BIGGER_THAN_MAXIMUM: "The length is bigger than {{MAXLENGTH}}."
  INVALID_VALUE: "Invalid value"
  NOT_AN_ABSOLUTE_URL: "Not an absolute URL"
  NOT_AN_EMAIL: "Not an E-mail"
  NOT_A_NUMBER: "Not a number"
  UNDERFLOW: "The number is smaller than {{MIN}}."
  OVERFLOW: "The number is bigger than {{MAX}}."

# 获取错误信息
errMsg = ( MSG, val ) ->
  switch MSG
    when "LENGTH_SMALLER_THAN_MINIMUM" then key = "MINLENGTH"
    when "LENGTH_BIGGER_THAN_MAXIMUM" then key = "MAXLENGTH"
    when "UNDERFLOW" then key = "MIN"
    when "OVERFLOW" then key = "MAX"

  return if key? then ERROR[MSG].replace(new RegExp("\{\{\s*#{key}\s*\}\}", "g"), val) else ERROR[MSG]

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

class Field
  constructor: ( ele ) ->
    ele = $ ele

    @type = elementType ele
    @name = ele.prop "name"
    @form = ele.closest("form").get 0

    if isGroupedElement(ele)
      @element = $.makeArray $("[name='#{@name}']", $(@form))
      @required = $("[name='#{@name}'][required]", $(@form)).size() > 0
    else
      @element = ele.get 0
      @required = hasAttr @element, "required"
      @pattern = ele.attr "pattern"
      @label = fieldLabel ele

    reset.call @

  value: ->
    return if isGroupedElement(@element) then $("[name='#{@name}']:checked", $(@form)).val() else $(@element).val()

  reset: reset

  validate: ->
    ele = @element
    val = @value()

    if @required and $.trim(val) is ""
      @valid = false
      @message = errMsg "COULD_NOT_BE_EMPTY"
    else
      switch @type
        when "text", "search", "tel", "url", "email", "password", "textarea"
          minLen = $(ele).prop "minLength"
          maxLen = $(ele).prop "maxLength"

          # 字符串最小长度
          if hasAttr(ele, "minlength") and val.length < minLen
            @valid = false
            @message = errMsg "LENGTH_SMALLER_THAN_MINIMUM", minLen
          # 字符串最大长度
          else if hasAttr(ele, "maxlength") and val.length > maxLen
            @valid = false
            @message = errMsg "LENGTH_BIGGER_THAN_MAXIMUM", maxLen
          # 字符串模式
          else
            # URL
            if @type is "url"
              @valid = RULE.ABSOLUTE_URL.test val
              @message = errMsg("NOT_AN_ABSOLUTE_URL") if not @valid
            # E-mail
            else if @type is "email"
              @valid = RULE.EMAIL.test val
              @message = errMsg("NOT_AN_EMAIL") if not @valid

            # 自定义
            if @valid and @pattern? and @pattern isnt ""
              @valid = (RULE[@pattern.match(PATTERN_KEY)?[1] ? ""] ? new RegExp "^#{@pattern}$").test val
              @message = errMsg("INVALID_VALUE") if not @valid
        when "number"
          @valid = RULE.NUMBER.test val

          if @valid
            minVal = getExtremum ele, "min"
            maxVal = getExtremum ele, "max"

            # 低于最小值
            if minVal? and toNum(val) < minVal
              @valid = false
              @message = errMsg "UNDERFLOW", minVal
            # 高于最大值
            else if maxVal? and toNum(val) > maxVal
              @valid = false
              @message = errMsg "OVERFLOW", maxVal
          else
            @message = errMsg "NOT_A_NUMBER"
        else
          @message = errMsg "UNKNOWN_INPUT_TYPE"

    $(if $.isArray(ele) then ele[0] else ele).trigger "H5F:#{if @valid then "valid" else "invalid"}", @

    return @valid
