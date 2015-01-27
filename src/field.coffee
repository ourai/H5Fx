RULE =
  NUMBER: /^\d+(\.0+)?$/

ERROR =
  COULD_NOT_BE_EMPTY: "COULD_NOT_BE_EMPTY"
  UNKNOWN_INPUT_TYPE: "UNKNOWN_INPUT_TYPE"
  INVALID_VALUE: "INVALID_VALUE"
  NOT_A_NUMBER: "NOT_A_NUMBER"
  UNDERFLOW: "UNDERFLOW"
  OVERFLOW: "OVERFLOW"

# 表单元素类型
elementType = ( ele ) ->
  switch ele.get(0).tagName.toLowerCase()
    when "textarea" then type = "textarea"
    when "input" then type = ele.attr("type") ? "text"

  return type

# 是否为成组的表单元素
isGroupedElement = ( ele ) ->
  return $.inArray($(ele).prop("type"), ["radio", "checkbox"]) isnt -1

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
      @required = ele.prop "required"
      @pattern = ele.attr "pattern"

    reset.call @

  value: ->
    return if isGroupedElement(@element) then $("[name='#{@name}']:checked", $(@form)).val() else $(@element).val()

  reset: reset

  validate: ->
    ele = @element
    val = @value()

    if @required and $.trim(val) is ""
      @valid = false
      @message = ERROR.COULD_NOT_BE_EMPTY
    else
      switch @type
        when "text", "password", "textarea"
          if @pattern? and @pattern isnt ""
            @valid = (new RegExp "^#{@pattern}$").test val
            @message = ERROR.INVALID_VALUE if not @valid
        when "number"
          @valid = RULE.NUMBER.test val

          if @valid
            minVal = getExtremum ele, "min"
            maxVal = getExtremum ele, "max"

            # 低于最小值
            if minVal? and toNum(val) < minVal
              @valid = false
              @message = ERROR.UNDERFLOW
            # 高于最大值
            else if maxVal? and toNum(val) > maxVal
              @valid = false
              @message = ERROR.OVERFLOW
          else
            @message = ERROR.NOT_A_NUMBER
        else
          @message = ERROR.UNKNOWN_INPUT_TYPE

    $(if $.isArray(ele) then ele[0] else ele).trigger "H5F:#{if @valid then "valid" else "invalid"}", @

    return @valid
