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
var ERROR, Field, Form, LIB_CONFIG, PATTERN_KEY_SOURCE, RULE, associatedElement, bindEvent, defaultSettings, elementType, fieldLabel, generateFormId, getExtremum, hasAttr, isGroupedElement, reset, subBtnSels, toNum, validateField;

LIB_CONFIG = {
  name: "H5F",
  version: "0.1.0"
};

PATTERN_KEY_SOURCE = "\{\{\s*([A-Z_]+)\s*\}\}";

RULE = {
  ABSOLUTE_URL: /^.*$/,
  EMAIL: /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/,
  NUMBER: /^\d+(\.0+)?$/
};

ERROR = {
  COULD_NOT_BE_EMPTY: "{{LABEL}} could not be empty.",
  UNKNOWN_INPUT_TYPE: "Unknown input type for {{LABEL}}.",
  LENGTH_SMALLER_THAN_MINIMUM: "The length of {{LABEL}} is smaller than {{MINLENGTH}}.",
  LENGTH_BIGGER_THAN_MAXIMUM: "The length of {{LABEL}} is bigger than {{MAXLENGTH}}.",
  INVALID_VALUE: "{{LABEL}}'s value is invalid.",
  NOT_AN_ABSOLUTE_URL: "{{LABEL}} isn't an absolute URL.",
  NOT_AN_EMAIL: "{{LABEL}} isn't an E-mail.",
  NOT_A_NUMBER: "{{LABEL}} isn't a number.",
  UNDERFLOW: "{{LABEL}}'s value is smaller than {{MIN}}.",
  OVERFLOW: "{{LABEL}}'s value is bigger than {{MAX}}.",
  DIFFERENT_VALUE: "{{LABEL}}'s value is different from {{ASSOCIATE_LABEL}}."
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

fieldLabel = function(ele) {
  var id, label, labelText;
  id = ele.attr("id");
  labelText = ele.attr("data-h5f-label");
  if (labelText == null) {
    label = id != null ? $("label[for='" + id + "']") : ele.closest("label");
    labelText = label.size() > 0 ? $.trim(label.text()) : "";
  }
  return labelText;
};

associatedElement = function(ele) {
  return $("#" + ($(ele).attr("data-h5f-associate")));
};

Field = (function() {
  function Field(ele) {
    ele = $(ele);
    this.label = fieldLabel(ele);
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

  Field.prototype.error = function(MSG) {
    var ele, f;
    f = this;
    ele = $(f.element);
    return ERROR[MSG].replace(new RegExp(PATTERN_KEY_SOURCE, "g"), function(match, key) {
      var text;
      switch (key) {
        case "LABEL":
          text = f.label;
          break;
        case "ASSOCIATE_LABEL":
          text = fieldLabel(associatedElement(ele));
          break;
        case "MINLENGTH":
          text = ele.attr("minlength");
          break;
        case "MAXLENGTH":
          text = ele.attr("maxlength");
          break;
        case "MIN":
          text = getExtremum(ele, "min");
          break;
        case "MAX":
          text = getExtremum(ele, "max");
      }
      return text;
    });
  };

  Field.prototype.validate = function() {
    var acEle, ele, maxVal, minVal, val, _ref, _ref1, _ref2;
    ele = this.element;
    val = this.value();
    if (this.required && $.trim(val) === "") {
      this.valid = false;
      this.message = this.error("COULD_NOT_BE_EMPTY");
    } else {
      switch (this.type) {
        case "text":
        case "search":
        case "tel":
        case "url":
        case "email":
        case "password":
        case "textarea":
          if (hasAttr(ele, "minlength") && val.length < $(ele).attr("minlength") * 1) {
            this.valid = false;
            this.message = this.error("LENGTH_SMALLER_THAN_MINIMUM");
          } else if (hasAttr(ele, "maxlength") && val.length > $(ele).attr("maxlength") * 1) {
            this.valid = false;
            this.message = this.error("LENGTH_BIGGER_THAN_MAXIMUM");
          } else {
            if (this.type === "url") {
              this.valid = RULE.ABSOLUTE_URL.test(val);
              if (!this.valid) {
                this.message = this.error("NOT_AN_ABSOLUTE_URL");
              }
            } else if (this.type === "email") {
              this.valid = RULE.EMAIL.test(val);
              if (!this.valid) {
                this.message = this.error("NOT_AN_EMAIL");
              }
            }
            if (this.valid && (this.pattern != null) && this.pattern !== "") {
              this.valid = ((_ref = RULE[(_ref1 = (_ref2 = this.pattern.match(new RegExp("^\s*" + PATTERN_KEY_SOURCE + "\s*$"))) != null ? _ref2[1] : void 0) != null ? _ref1 : ""]) != null ? _ref : new RegExp("^" + this.pattern + "$")).test(val);
              if (!this.valid) {
                this.message = this.error("INVALID_VALUE");
              }
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
              this.message = this.error("UNDERFLOW");
            } else if ((maxVal != null) && toNum(val) > maxVal) {
              this.valid = false;
              this.message = this.error("OVERFLOW");
            }
          } else {
            this.message = this.error("NOT_A_NUMBER");
          }
          break;
        default:
          this.message = this.error("UNKNOWN_INPUT_TYPE");
      }
      if (this.valid && !isGroupedElement(ele) && hasAttr(ele, "data-h5f-associate")) {
        acEle = associatedElement(ele);
        if (acEle.size()) {
          this.valid = val === acEle.val();
          if (!this.valid) {
            this.message = this.error("DIFFERENT_VALUE");
          }
        }
      }
    }
    $($.isArray(ele) ? ele[0] : ele).triggerHandler("H5F:" + (this.valid ? "valid" : "invalid"), this);
    return this.valid;
  };

  return Field;

})();

subBtnSels = ":submit, :image, :reset";

defaultSettings = {
  immediate: false
};

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
    $("[name]:not(:checkbox, :radio, " + subBtnSels + ", select, option)", form).on("blur", function() {
      return validateField(inst, inst.fields[$(this).prop("name")]);
    });
  }
  return form.on("submit", function(e) {
    $(this).triggerHandler("H5F:beforeValidate", inst);
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
    } else {
      return $(this).triggerHandler("H5F:submit", [inst, e]);
    }
  });
};

generateFormId = function() {
  return "H5F" + ((new Date).getTime().toString(16)) + "F0RM" + ((Form.forms.length + 1).toString(16));
};

Form = (function() {
  function Form(form) {
    var inst;
    inst = this;
    this.invalidCount = 0;
    $("[name]:not(select, [type='hidden'], " + subBtnSels + ")", $(form)).each(function() {
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

  Form.forms = {
    length: 0
  };

  Form.init = function(forms, settings) {
    var F;
    F = this;
    return $(forms).each(function() {
      var flag, form, id, inst, opts;
      form = $(this);
      flag = "H5F-form";
      opts = $.extend({}, defaultSettings, settings, {
        immediate: (function() {
          var attr;
          attr = form.attr("data-h5f-immediate");
          if (attr === "true") {
            attr = true;
          } else if (attr === "false") {
            attr = false;
          } else {
            attr = void 0;
          }
          return attr;
        })()
      });
      if (form.data(flag) == null) {
        inst = new F(this);
        id = generateFormId(inst);
        F.forms[id] = inst;
        F.forms.length++;
        form.data(flag, id);
        form.attr("novalidate", true);
        if (form.attr("data-h5f-novalidate") == null) {
          return bindEvent(form, inst, opts.immediate === true);
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


  /*
   * 获取指定实例
   * 
   * @method  get
   * @param   formId {String}   $(form).data("H5F-form")
   * @return  {Object}
   */

  Form.get = function(formId) {
    return this.forms[formId];
  };

  return Form;

})();

window[LIB_CONFIG.name] = Form;

}));
