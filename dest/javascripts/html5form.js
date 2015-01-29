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
var ERROR, Field, Form, LIB_CONFIG, RULE, bindEvent, defaultSettings, elementType, getExtremum, hasAttr, isGroupedElement, reset, toNum, validateField;

LIB_CONFIG = {
  name: "H5F",
  version: "0.1.0"
};

RULE = {
  NUMBER: /^\d+(\.0+)?$/
};

ERROR = {
  COULD_NOT_BE_EMPTY: "COULD_NOT_BE_EMPTY",
  UNKNOWN_INPUT_TYPE: "UNKNOWN_INPUT_TYPE",
  LENGTH_SMALLER_THEN_MINIMUM: "LENGTH_SMALLER_THEN_MINIMUM",
  LENGTH_BIGGER_THEN_MAXIMUM: "LENGTH_BIGGER_THEN_MAXIMUM",
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

isGroupedElement = function(ele) {
  return $.inArray($(ele).prop("type"), ["radio", "checkbox"]) !== -1;
};

hasAttr = function(ele, attr) {
  return ele.hasAttribute(attr);
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
    this.type = elementType(ele);
    this.name = ele.prop("name");
    this.form = ele.closest("form").get(0);
    if (isGroupedElement(ele)) {
      this.element = $.makeArray($("[name='" + this.name + "']", $(this.form)));
      this.required = $("[name='" + this.name + "'][required]", $(this.form)).size() > 0;
    } else {
      this.element = ele.get(0);
      this.required = hasAttr(this.element, "required");
      this.pattern = ele.attr("pattern");
    }
    reset.call(this);
  }

  Field.prototype.value = function() {
    if (isGroupedElement(this.element)) {
      return $("[name='" + this.name + "']:checked", $(this.form)).val();
    } else {
      return $(this.element).val();
    }
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
          if (hasAttr(ele, "minlength") && val.length < $(ele).prop("minLength")) {
            this.valid = false;
            this.message = ERROR.LENGTH_SMALLER_THEN_MINIMUM;
          } else if (hasAttr(ele, "maxlength") && val.length > $(ele).prop("maxLength")) {
            this.valid = false;
            this.message = ERROR.LENGTH_BIGGER_THEN_MAXIMUM;
          } else if ((this.pattern != null) && this.pattern !== "") {
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
    $($.isArray(ele) ? ele[0] : ele).trigger("H5F:" + (this.valid ? "valid" : "invalid"), this);
    return this.valid;
  };

  return Field;

})();

validateField = function(form, field) {
  field.reset();
  field.validated = true;
  if (field.validate()) {
    if (field.counted === true) {
      form.invalidCount = --form.invalidCount;
    }
    field.counted = false;
  } else {
    if (field.counted !== true) {
      form.invalidCount = ++form.invalidCount;
    }
    field.counted = true;
  }
  return field;
};

bindEvent = function(form, inst, immediate) {
  if (immediate === true) {
    $("[name]:checkbox, [name]:radio", form).on("change", function() {
      return validateField(inst, inst.fields[$(this).prop("name")]);
    });
    $("[name]:not(:checkbox, :radio)", form).on("blur", function() {
      return validateField(inst, inst.fields[$(this).prop("name")]);
    });
  }
  return form.on("submit", function(e) {
    $.each(inst.sequence, function(idx, name) {
      var field;
      field = inst.fields[name];
      if (!immediate) {
        field.validated = false;
      }
      if (field.validated === false) {
        validateField(inst, field);
      }
      return true;
    });
    if (inst.invalidCount > 0) {
      e.preventDefault();
      return e.stopImmediatePropagation();
    }
  });
};

defaultSettings = {
  immediate: false
};

Form = (function() {
  function Form(form) {
    var inst;
    inst = this;
    this.invalidCount = 0;
    $("[name]:not(select, [type='hidden'])", $(form)).each(function() {
      var ipt, name;
      ipt = $(this);
      name = ipt.prop("name");
      return inst.addField(new Field(this));
    });
  }

  Form.prototype.addField = function(field) {
    var name;
    if (this.fields == null) {
      this.fields = {};
    }
    if (this.sequence == null) {
      this.sequence = [];
    }
    name = field.name;
    if (this.fields[name] == null) {
      field.validated = false;
      this.fields[name] = field;
      this.sequence.push(name);
    }
    return field;
  };

  Form.version = LIB_CONFIG.version;

  Form.init = function(forms, settings) {
    var F;
    F = this;
    return $(forms).each(function() {
      var flag, form;
      form = $(this);
      flag = "H5F-inited";
      settings = $.extend({}, defaultSettings, settings, {
        immediate: form.attr("data-h5f-immediate") === "true"
      });
      if (form.data(flag) !== true) {
        form.data(flag, true);
        form.attr("novalidate", true);
        if (form.attr("data-h5f-novalidate") == null) {
          return bindEvent(form, new F(this), settings.immediate);
        }
      }
    });
  };

  Form.errors = function(msgs) {
    return $.extend(ERROR, msgs);
  };

  Form.rules = function(rules) {
    return $.extend(RULE, rules);
  };

  return Form;

})();

window[LIB_CONFIG.name] = Form;

}));
