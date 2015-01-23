(function( global, factory ) {

  if ( typeof module === "object" && typeof module.exports === "object" ) {
    module.exports = global.document ?
      factory(global, true) :
      function( w ) {
        if ( !w.document ) {
          throw new Error("Requires a window with a document");
        }
        return factory(w);
      };
  } else {
    factory(global);
  }

}(typeof window !== "undefined" ? window : this, function( window, noGlobal ) {

var ERROR, REGEXP, Validator, getExtremum, reset, toNum;

REGEXP = {
  NUMBER: /^\d+(\.0+)?$/
};

ERROR = {
  COULD_NOT_BE_EMPTY: "COULD_NOT_BE_EMPTY",
  UNKNOWN_INPUT_TYPE: "UNKNOWN_INPUT_TYPE",
  INVALID_VALUE: "INVALID_VALUE",
  NOT_A_NUMBER: "NOT_A_NUMBER",
  UNDERFLOW: "UNDERFLOW",
  OVERFLOW: "OVERFLOW"
};

toNum = function(str) {
  return parseFloat(str);
};

getExtremum = function(ele, type) {
  var val;
  val = ele.prop(type);
  if ($.isNumeric(val)) {
    return toNum(val);
  } else {
    return null;
  }
};

reset = function() {
  this.valid = true;
  return this.message = "";
};

Validator = (function() {
  function Validator(ele) {
    var _ref;
    ele = $(ele);
    this.element = ele.get(0);
    this.form = ele.closest("form").get(0);
    this.pattern = ele.attr("pattern");
    this.type = (_ref = ele.attr("type")) != null ? _ref : "text";
    this.required = ele.prop("required");
    reset.call(this);
  }

  Validator.prototype.value = function() {
    return $(this.element).val();
  };

  Validator.prototype.reset = reset;

  Validator.prototype.validate = function() {
    var ele, maxVal, minVal, val;
    ele = $(this.element);
    val = ele.val();
    if (this.required && $.trim(val) === "") {
      this.valid = false;
      this.message = ERROR.COULD_NOT_BE_EMPTY;
      return false;
    }
    if ($.inArray(this.type, ["checkbox", "radio", "password", "hidden"]) === -1) {
      switch (this.type) {
        case "text":
          this.valid = (new RegExp("^" + this.pattern + "$")).test(val);
          if (!this.valid) {
            this.message = ERROR.INVALID_VALUE;
          }
          break;
        case "number":
          this.valid = REGEXP.NUMBER.test(val);
          if (this.valid) {
            minVal = getExtremum(ele, "min");
            maxVal = getExtremum(ele, "max");
            if ((minVal != null) && toNum(val) < minVal) {
              this.valid = false;
              this.message = ERROR.UNDERFLOW;
            } else if ((maxVal != null) && toNum(val) > maxVal) {
              this.valid = false;
              this.message = ERROR.OVERFLOW;
            }
          } else {
            this.message = ERROR.NOT_A_NUMBER;
          }
          break;
        default:
          this.message = ERROR.UNKNOWN_INPUT_TYPE;
      }
    }
    return this.valid;
  };

  return Validator;

})();

$(document).on("submit", "form", function() {
  var passed;
  passed = true;
  $.each($(this).data("ValidatableFields"), function() {
    this.reset();
    if (!this.validate()) {
      passed = false;
      console.log(this, this.message);
    }
    return true;
  });
  return passed;
});

$(document).ready(function() {
  return $("form").each(function() {
    var fields, form;
    form = $(this);
    fields = [];
    form.attr("novalidate", true);
    $("[name]", form).each(function() {
      return fields.push(new Validator(this));
    });
    return form.data("ValidatableFields", fields);
  });
});

}));
