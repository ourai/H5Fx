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

"use strict";
var ERROR, Field, Form, LIB_CONFIG, RULE, elementType, getExtremum, reset, toNum;

LIB_CONFIG = {
  name: "H5F",
  version: "0.0.1"
};

RULE = {
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

elementType = function(ele) {
  var type, _ref;
  switch (ele.get(0).tagName.toLowerCase()) {
    case "textarea":
      type = "textarea";
      break;
    case "input":
      type = (_ref = ele.attr("type")) != null ? _ref : "text";
  }
  return type;
};

reset = function() {
  this.valid = true;
  return this.message = "";
};

toNum = function(str) {
  return parseFloat(str);
};

getExtremum = function(ele, type) {
  var val;
  val = $(ele).prop(type);
  if ($.isNumeric(val)) {
    return toNum(val);
  } else {
    return null;
  }
};

Field = (function() {
  function Field(ele) {
    ele = $(ele);
    this.element = ele.get(0);
    this.form = ele.closest("form").get(0);
    this.pattern = ele.attr("pattern");
    this.type = elementType(ele);
    this.required = ele.prop("required");
    reset.call(this);
  }

  Field.prototype.value = function() {
    return $(this.element).val();
  };

  Field.prototype.reset = reset;

  Field.prototype.validate = function() {
    var ele, maxVal, minVal, val;
    ele = this.element;
    val = this.value();
    if (this.required && $.trim(val) === "") {
      this.valid = false;
      this.message = ERROR.COULD_NOT_BE_EMPTY;
    } else {
      switch (this.type) {
        case "text":
        case "password":
        case "textarea":
          if ((this.pattern != null) && this.pattern !== "") {
            this.valid = (new RegExp("^" + this.pattern + "$")).test(val);
            if (!this.valid) {
              this.message = ERROR.INVALID_VALUE;
            }
          }
          break;
        case "number":
          this.valid = RULE.NUMBER.test(val);
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
    $(ele).trigger("H5F:" + (this.valid ? "valid" : "invalid"), this);
    return this.valid;
  };

  return Field;

})();

Form = {
  version: LIB_CONFIG.version,
  init: function(forms) {
    return $(forms).each(function() {
      var fields, flag, form;
      form = $(this);
      flag = "H5F-inited";
      if (form.data(flag) !== true) {
        form.attr("novalidate", true);
        if (form.attr("data-novalidate") == null) {
          fields = [];
          $("[name]:not(select, [type='checkbox'], [type='radio'], [type='hidden'])", form).each(function() {
            return fields.push(new Field(this));
          });
          form.data("H5F-fields", fields);
        }
        return form.data(flag, true);
      }
    });
  },
  errors: function(msgs) {
    return $.extend(ERROR, msgs);
  },
  rules: function(rules) {
    return $.extend(RULE, rules);
  }
};

$(document).on("submit", "form:not([data-novalidate])", function() {
  var passed, _ref;
  passed = true;
  $.each((_ref = $(this).data("H5F-fields")) != null ? _ref : [], function() {
    this.reset();
    if (!this.validate()) {
      passed = false;
    }
    return true;
  });
  return passed;
});

window[LIB_CONFIG.name] = Form;

}));
