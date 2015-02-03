$(document).ready(function() {
  H5F.init($("form"));
  return $("[name]").on({
    "H5F:valid": function(e, field) {
      return $(field.element).parent(".form-group").removeClass("has-error").addClass("has-success");
    },
    "H5F:invalid": function(e, field) {
      $(field.element).parent(".form-group").removeClass("has-success").addClass("has-error");
      return console.log(field.element.id, field.message);
    }
  });
});
