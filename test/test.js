$(document).ready(function() {
  var f1, f1_inst;
  H5F.init($("form"), {
    immediate: true
  });
  H5F.errors({
    COULD_NOT_BE_EMPTY: "{{LABEL}}的值不能为空",
    UNKNOWN_INPUT_TYPE: "{{LABEL}}字段为未知类型",
    LENGTH_SMALLER_THAN_MINIMUM: "{{LABEL}}的字符串长度请保持在在 {{MINLENGTH}}-{{MAXLENGTH}}",
    LENGTH_BIGGER_THAN_MAXIMUM: "{{LABEL}}的字符串长度请保持在在 {{MINLENGTH}}-{{MAXLENGTH}}",
    INVALID_VALUE: "{{LABEL}}的值{{VALUE}}为无效值",
    NOT_A_NUMBER: "{{LABEL}}不是数字",
    UNDERFLOW: "{{LABEL}}中所输入数字请在 {{MIN}}-{{MAX}} 范围内",
    OVERFLOW: "{{LABEL}}中所输入数字请在 {{MIN}}-{{MAX}} 范围内"
  });
  $("[name]").on({
    "H5F:valid": function(e, field) {
      return $(field.element).closest(".form-group").removeClass("has-error").children(".help-block").hide();
    },
    "H5F:invalid": function(e, field) {
      var group;
      group = $(field.element).closest(".form-group");
      if ($(".help-block", group).size() === 0) {
        group.append("<p class=\"help-block\" />");
      }
      return group.addClass("has-error").children(".help-block").show().text(field.message);
    }
  });
  $("form").on({
    "H5F:submit": function(e, inst, sub) {
      console.log("submit");
      return false;
    },
    "H5F:destroy": function(e) {
      console.log("destroy");
      $(".help-block", $(this)).remove();
      return $(".has-error", $(this)).removeClass("has-error");
    }
  });
  f1 = $("#form_1");
  f1.on("H5F:submit", function() {
    console.log("form_1 submit");
    return "form_1";
  });
  f1_inst = H5F.get(f1);
  f1_inst.addValidation("form_1_1", {
    handler: function() {
      return !isNaN(Number(this.value));
    },
    message: "啊哈哈"
  });
  f1_inst.addValidation("form_1_1", {
    handler: function() {
      return this.value.length > 5;
    },
    message: function() {
      return "长度不对";
    }
  });
  return $("#form_2").on("H5F:submit", function() {
    console.log("form_2 submit");
    return "form_2";
  });
});
