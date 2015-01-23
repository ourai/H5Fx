REGEXP =
  NUMBER: /^\d+(\.0+)?$/

ERROR =
  COULD_NOT_BE_EMPTY: "COULD_NOT_BE_EMPTY"
  UNKNOWN_INPUT_TYPE: "UNKNOWN_INPUT_TYPE"
  INVALID_VALUE: "INVALID_VALUE"
  NOT_A_NUMBER: "NOT_A_NUMBER"
  UNDERFLOW: "UNDERFLOW"
  OVERFLOW: "OVERFLOW"

elementType = ( ele ) ->
  switch ele.get(0).tagName.toLowerCase()
    when "textarea" then type = "textarea"
    when "input" then type = ele.attr("type") ? "text"

  return type

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

class Validator
  constructor: ( ele ) ->
    ele = $ ele

    @element = ele.get 0
    @form = ele.closest("form").get 0

    @pattern = ele.attr "pattern"
    @type = elementType ele
    @required = ele.prop "required"

    reset.call @

  value: ->
    return $(@element).val()

  reset: reset

  validate: ->
    ele = @element
    val = @value()

    if @required and $.trim(val) is ""
      @valid = false
      @message = ERROR.COULD_NOT_BE_EMPTY

      return false

    # checkbox 和 radio 不需要验证
    if $.inArray(@type, ["checkbox", "radio", "password", "hidden"]) is -1
      switch @type
        when "text", "textarea"
          @valid = (new RegExp "^#{@pattern}$").test val
          @message = ERROR.INVALID_VALUE if not @valid
        when "number"
          @valid = REGEXP.NUMBER.test val

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

    return @valid
