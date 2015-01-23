$(document).on "submit", "form:not([data-novalidate])", ->
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

    form.attr "novalidate", true

    if not form.attr("data-novalidate")?
      fields = []
      
      $("[name]:not(select)", form).each ->
        fields.push new Validator @

      form.data "ValidatableFields", fields
