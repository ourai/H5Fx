class Validator
  constructor: ( ele ) ->
    ele = $ ele

    @element = ele.get 0
    @pattern = ele.attr "pattern"
    @type = ele.attr "type"
    @required = @element.hasAttibute "required"
    @form = ele.closest("form").get 0

  value = ->
    return $(@element).val()

  validate = ->
