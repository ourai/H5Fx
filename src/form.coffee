$(document).on "submit", "form", ->
  passed = true

  $.each $(@).data("ValidatableFields"), ->
    @reset()
    
    if not @validate()
      passed = false
      console.log @, @message

    return true

  return passed

$(document).ready ->
  $("form").each ->
    form = $(@)
    fields = []

    form.attr "novalidate", true

    $("[name]", form).each ->
      fields.push new Validator @

    form.data "ValidatableFields", fields
