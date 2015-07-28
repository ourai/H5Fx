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
var ERROR, EVENT, Field, Form, LIB_CONFIG, PATTERN_KEY_SOURCE, RULE, associatedElement, bindEvent, defaultSettings, elementType, fieldLabel, fieldProps, generateInstId, getExtremum, getInstId, hasAttr, initCount, labelElement, lowerThan, reorderSequence, requiredAttr, reset, resetDefaultValue, resetFieldStatus, subBtnSels, toHex, toNum, triggerValidityEvent, validateCheckableElements, validateField, validateOtherFields, validateSelectElement, validateTextualElements;

LIB_CONFIG = {
  name: "H5F",
  version: "0.1.1"
};

PATTERN_KEY_SOURCE = "\{\{\s*([A-Z_]+)\s*\}\}";

RULE = {
  ABSOLUTE_URL: {
    rule: /^.*$/,
    message: "NOT_AN_ABSOLUTE_URL"
  },
  EMAIL: {
    rule: /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/,
    message: "NOT_AN_EMAIL"
  },
  NUMBER: {
    rule: /^(\-)?\d+(\.\d+)?$/,
    message: "NOT_A_NUMBER"
  }
};

ERROR = {
  UNKNOWN_INPUT_TYPE: "Unknown input type for {{LABEL}}.",
  COULD_NOT_BE_EMPTY: "{{LABEL}} could not be empty.",
  LENGTH_SMALLER_THAN_MINIMUM: "The length of {{LABEL}} is smaller than {{MINLENGTH}}.",
  LENGTH_BIGGER_THAN_MAXIMUM: "The length of {{LABEL}} is bigger than {{MAXLENGTH}}.",
  INVALID_VALUE: "{{LABEL}}'s value is invalid.",
  NOT_AN_ABSOLUTE_URL: "{{LABEL}} isn't an absolute URL.",
  NOT_AN_EMAIL: "{{LABEL}} isn't an E-mail.",
  NOT_A_NUMBER: "{{LABEL}} isn't a number.",
  UNDERFLOW: "{{LABEL}}'s value is smaller than {{MIN}}.",
  OVERFLOW: "{{LABEL}}'s value is bigger than {{MAX}}.",
  DIFFERENT_VALUE: "{{LABEL}}'s value is different from {{ASSOCIATE_LABEL}}.",
  AT_LEAST_CHOOSE_ONE: "At least choose an option from {{LABEL}}.",
  SHOOLD_BE_CHOSEN: "{{UNIT_LABEL}} shoold be chosen.",
  SHOOLD_CHOOSE_AN_OPTION: "Must choose an option of {{LABEL}}."
};

EVENT = {
  SUBMIT: "H5F:submit",
  DESTROY: "H5F:destroy",
  BEFORE_VALIDATE: "H5F:beforeValidate",
  VALIDATE: "H5F:validate",
  VALID: "H5F:valid",
  INVALID: "H5F:invalid",
  DISABLED: "H5F:disabled",
  ENABLED: "H5F:enabled"
};

hasAttr = function(ele, attr) {
  return ele.hasAttribute(attr);
};

toNum = function(str) {
  return parseFloat(str);
};

fieldProps = function(ele) {
  var elements, form, requiredElements;
  ele = $(ele);
  form = ele.closest("form").eq(0);
  this.form = form.get(0);
  this.type = elementType(ele);
  this.name = ele.prop("name");
  this.__form = null;
  this.__counted = false;
  this.__enabled = true;
  this.__checkable = $.inArray(ele.prop("type"), ["radio", "checkbox"]) !== -1;
  this.__validations = [];
  if (this.__checkable) {
    elements = $("[name='" + this.name + "']", form);
    requiredElements = elements.closest(requiredAttr(this.type));
    this.__defaultValue = elements.closest(":checked");
    this.element = $.makeArray(elements);
    this.required = requiredElements.size() > 0;
    this.label = fieldLabel((this.required ? requiredElements.eq(0) : $(this.element[0])), form);
    this.validate = validateCheckableElements;
  } else {
    this.element = ele.get(0);
    this.required = hasAttr(this.element, "required");
    this.label = fieldLabel(ele, form);
    if (this.element.tagName.toLowerCase() === "select") {
      this.__defaultValue = $(":selected", ele);
      this.validate = validateSelectElement;
    } else {
      this.__defaultValue = ele.val();
      this.validate = validateTextualElements;
      this.pattern = ele.attr("pattern");
    }
    if (this.required) {
      labelElement(ele, form).addClass("H5F-label--required");
    }
  }
  return reset.call(this);
};

elementType = function(ele) {
  var _ref;
  if (ele.get(0).tagName.toLowerCase() === "input") {
    return (_ref = ele.attr("type")) != null ? _ref : "text";
  } else {
    return ele.prop("type");
  }
};

getExtremum = function(ele, type) {
  var val;
  if ($.isNumeric(val = $(ele).prop(type))) {
    return toNum(val);
  } else {
    return null;
  }
};

labelElement = function(ele, form) {
  var id;
  if ((id = ele.attr("id")) != null) {
    return $("label[for='" + id + "']", form);
  } else {
    return ele.closest("label");
  }
};

fieldLabel = function(ele, form, customizable) {
  var label, labelText;
  if (customizable !== false) {
    labelText = ele.attr("data-h5f-label");
  }
  if (labelText == null) {
    label = labelElement(ele, form);
    labelText = label.size() > 0 ? $.trim(label.text()) : "";
  }
  return labelText;
};

associatedElement = function(ele) {
  return $("#" + ($(ele).attr("data-h5f-associate")));
};

reset = function() {
  this.valid = true;
  this.message = "";
};

resetDefaultValue = function() {
  var elem;
  elem = $(this.element);
  if (this.__checkable) {
    elem.closest(":checked").prop("checked", false);
    $(this.__defaultValue).prop("checked", true);
  } else if (this.element.tagName.toLowerCase() === "select") {
    $(":selected", elem).prop("selected", false);
    $(this.__defaultValue).prop("selected", true);
  } else {
    elem.val(this.__defaultValue);
  }
};

resetFieldStatus = function() {
  this.__counted = false;
  this.validated = false;
  reset.call(this);
  resetDefaultValue.call(this);
};

triggerValidityEvent = function(field, ele) {
  return $(ele).trigger((field.valid ? EVENT.VALID : EVENT.INVALID), field);
};

requiredAttr = function(isCheckbox) {
  if ($.type(isCheckbox) === "string") {
    isCheckbox = isCheckbox === "checkbox";
  }
  return "[" + (isCheckbox ? "data-h5f-" : "") + "required]";
};

validateTextualElements = function() {
  var acEle, definedRule, ele, maxVal, message, minVal, rule, val, _ref, _ref1;
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
          if (val !== "") {
            if (this.type === "url") {
              this.valid = RULE.ABSOLUTE_URL.rule.test(val);
              if (!this.valid) {
                this.message = this.error(RULE.ABSOLUTE_URL.message);
              }
            } else if (this.type === "email") {
              this.valid = RULE.EMAIL.rule.test(val);
              if (!this.valid) {
                this.message = this.error(RULE.EMAIL.message);
              }
            }
          }
          if (this.valid && (this.pattern != null) && this.pattern !== "") {
            definedRule = RULE[(_ref = (_ref1 = this.pattern.match(new RegExp("^\s*" + PATTERN_KEY_SOURCE + "\s*$"))) != null ? _ref1[1] : void 0) != null ? _ref : ""];
            if (definedRule != null) {
              rule = definedRule.rule;
              if (definedRule.message != null) {
                message = this.error(definedRule.message);
              }
            } else {
              rule = new RegExp("^" + this.pattern + "$");
            }
            this.valid = rule.test(val);
            if (!this.valid) {
              this.message = message != null ? message : this.error("INVALID_VALUE");
            }
          }
        }
        break;
      case "number":
        if (val !== "") {
          this.valid = RULE.NUMBER.rule.test(val);
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
            this.message = this.error(RULE.NUMBER.message);
          }
        }
        break;
      default:
        this.message = this.error("UNKNOWN_INPUT_TYPE");
    }
    if (this.valid && hasAttr(ele, "data-h5f-associate")) {
      acEle = associatedElement(ele);
      if (acEle.size()) {
        this.valid = val === acEle.val();
        if (!this.valid) {
          this.message = this.error("DIFFERENT_VALUE");
        }
      }
    }
    if (this.valid && this.__validations.length > 0) {
      $.each(this.__validations, (function(_this) {
        return function(idx, opts) {
          var _ref2;
          _this.valid = $.isFunction(opts.handler) ? opts.handler.call(ele) === true : false;
          if (!_this.valid) {
            _this.message = (/^[A-Z_]+$/.test(opts.message) ? _this.error(opts.message) : (_ref2 = typeof opts.message === "function" ? opts.message() : void 0) != null ? _ref2 : opts.message);
          }
          return _this.valid;
        };
      })(this));
    }
  }
  triggerValidityEvent(this, ele);
  return this.valid;
};

validateSelectElement = function() {
  if (this.required && $.trim(this.value()) === "") {
    this.valid = false;
    this.message = this.error("SHOOLD_CHOOSE_AN_OPTION");
  }
  triggerValidityEvent(this, this.element);
  return this.valid;
};

validateCheckableElements = function() {
  var ele, elements, isCheckbox;
  elements = $(this.element);
  isCheckbox = this.type === "checkbox";
  if (this.required && elements.closest(":checked").size() === 0) {
    this.valid = false;
    this.message = this.error("AT_LEAST_CHOOSE_ONE");
    ele = elements.closest(requiredAttr(isCheckbox));
  } else {
    if (isCheckbox) {
      ele = elements.closest("[required]");
      if (ele.size() > 0) {
        ele.each((function(_this) {
          return function(idx, el) {
            _this.valid = $(el).is(":checked");
            if (!_this.valid) {
              _this.__element = el;
            }
            return _this.valid;
          };
        })(this));
        if (this.valid) {
          delete this.__element;
        } else {
          this.message = this.error("SHOOLD_BE_CHOSEN");
        }
      } else {
        ele = elements;
      }
    } else {
      ele = elements;
    }
  }
  triggerValidityEvent(this, ele.get(0));
  return this.valid;
};

Field = (function() {
  var _class;

  function Field() {
    return _class.apply(this, arguments);
  }

  _class = fieldProps;

  Field.prototype.value = function() {
    if (this.__checkable) {
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
        case "VALUE":
          text = f.value();
          break;
        case "ASSOCIATE_LABEL":
          text = fieldLabel(associatedElement(ele), $(f.form));
          break;
        case "UNIT_LABEL":
          text = fieldLabel($(f.__element), $(f.form), false);
          break;
        case "LENGTH":
          text = f.value().length;
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

  Field.prototype.addValidation = function(opts) {
    this.__validations.push(opts);
    return opts;
  };

  Field.prototype.disableValidation = function(isByAttr) {
    this.__enabled = false;
    if (isByAttr === true) {
      this.__disabled = true;
    }
    if (this.__counted === true) {
      this.__form.invalidCount--;
    }
    resetFieldStatus.call(this);
    $(this.element).trigger(EVENT.DISABLED);
    return this;
  };


  /*
   * 使验证有效
   * 
   * @method  enableValidation
   * @param   [validate] {Boolean}       是否立即对字段进行验证
   * @return  {Object}
   */

  Field.prototype.enableValidation = function(validate) {
    var _elem;
    this.__enabled = true;
    _elem = this.element;
    delete this.__disabled;
    $(_elem).trigger(EVENT.ENABLED);
    if (validate === true) {
      $(this.__checkable ? _elem[0] : _elem).trigger(EVENT.VALIDATE);
    }
    return this;
  };

  Field.prototype.isEnabled = function() {
    return this.__enabled === true;
  };

  Field.prototype.isValid = function() {
    return this.valid === true;
  };

  Field.prototype.isDisabled = function() {
    if (this.__checkable) {
      return false;
    } else {
      return $(this.element).prop("disabled");
    }
  };

  return Field;

})();

subBtnSels = ":submit, :image, :reset";

defaultSettings = {
  immediate: false
};

initCount = 0;

lowerThan = function(ver) {
  var info;
  info = navigator.userAgent.toLowerCase().match(/msie (\d+\.\d+)/);
  if (info != null) {
    return info[1] * 1 < ver;
  } else {
    return false;
  }
};

validateField = function(form, field) {
  field.reset();
  field.validated = true;
  if (field.validate()) {
    if (field.__counted === true) {
      form.invalidCount--;
    }
    field.__counted = false;
  } else {
    if (field.__counted !== true) {
      form.invalidCount++;
    }
    field.__counted = true;
  }
  return field;
};

validateOtherFields = function(inst, immediate) {
  if (inst.sequence == null) {
    return;
  }
  return $.each(inst.sequence, function(idx, name) {
    var checkable, ele, field;
    field = inst.fields[name];
    ele = field.element;
    checkable = field.__checkable;
    if (!checkable) {
      if (field.__disabled === true) {
        if (field.isDisabled() === false) {
          field.enableValidation();
        }
      } else {
        if (field.isDisabled() === true) {
          field.disableValidation(true);
        }
      }
    }
    if ((!checkable && hasAttr(ele, "data-h5f-associate")) || !immediate) {
      field.validated = false;
    }
    if (field.isEnabled() && field.validated === false) {
      $(checkable ? ele[0] : ele).trigger(EVENT.VALIDATE);
    }
    return true;
  });
};

bindEvent = function(form, inst, immediate) {
  $("[name]", form).on(EVENT.VALIDATE, function() {
    var f;
    f = inst.fields[$(this).prop("name")];
    if (f.isEnabled()) {
      validateField(inst, f);
    }
    return f;
  });
  if (immediate === true) {
    $("[name]:checkbox, [name]:radio, select[name]", form).on("change.H5F", function() {
      return $(this).trigger(EVENT.VALIDATE);
    });
    $("[name]:not(:checkbox, :radio, " + subBtnSels + ", select, option)", form).on((lowerThan(9) ? "change.H5F" : "input.H5F"), function() {
      return $(this).trigger(EVENT.VALIDATE);
    });
  }
  return form.on("submit.H5F", function(e) {
    $(this).trigger(EVENT.BEFORE_VALIDATE, inst);
    validateOtherFields(inst, immediate);
    if (inst.invalidCount > 0) {
      e.preventDefault();
      return e.stopImmediatePropagation();
    } else {
      return $(this).trigger(EVENT.SUBMIT, [inst, e]);
    }
  });
};

toHex = function(num) {
  return num.toString(16);
};

generateInstId = function() {
  return "H5F0RM" + (toHex(initCount)) + (toHex((new Date).getTime())) + (toHex(Form.forms.length + 1));
};

getInstId = function(form) {
  var id, _ref;
  if ($.type(form) === "object") {
    id = (form.nodeType === 1 ? form : (_ref = typeof form.get === "function" ? form.get(0) : void 0) != null ? _ref : {})["H5F-form"];
  } else if ($.type(form) === "string") {
    id = form;
  }
  return id;
};

reorderSequence = function(idx, name) {};

Form = (function() {
  function Form(form) {
    var inst;
    inst = this;
    this.form = form;
    this.novalidate = hasAttr(form, "novalidate");
    this.invalidCount = 0;
    initCount++;
    $("[name]:not([type='hidden'], " + subBtnSels + ")", $(form)).each(function() {
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
      field.__form = this;
      field.validated = false;
      this.fields[name] = field;
      this.sequence.push(name);
    }
    return field;
  };

  Form.prototype.addValidation = function(fieldName, opts) {
    var _ref;
    return (_ref = this.fields[fieldName]) != null ? _ref.addValidation(opts) : void 0;
  };

  Form.prototype.disableValidation = function(fieldName) {
    var _ref;
    return (_ref = this.fields[fieldName]) != null ? _ref.disableValidation() : void 0;
  };

  Form.prototype.enableValidation = function(fieldName, validate) {
    var _ref;
    return (_ref = this.fields[fieldName]) != null ? _ref.enableValidation(validate) : void 0;
  };

  Form.prototype.update = function() {
    return $("[name]", form).each((function(_this) {
      return function(idx, name) {
        return reorderSequence.apply(_this, [idx, name]);
      };
    })(this));
  };


  /*
   * 销毁实例
   * 
   * @method  destroy
   * @return  {DOM}
   */

  Form.prototype.destroy = function() {
    var form;
    form = $(this.form);
    form.off(".H5F");
    $("[name]", form).off(".H5F");
    $(".H5F-label--required", form).removeClass("H5F-label--required");
    if (this.novalidate) {
      form.attr("novalidate", true);
    } else {
      form.removeAttr("novalidate");
    }
    delete this.constructor.forms[this.form["H5F-form"]];
    delete this.form["H5F-form"];
    this.constructor.forms.length--;
    form.trigger(EVENT.DESTROY);
    return form.get(0);
  };

  Form.RULES = $.extend(true, {}, RULE);

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
      if (this[flag] == null) {
        inst = new F(this);
        id = generateInstId(inst);
        F.forms[id] = inst;
        F.forms.length++;
        this[flag] = id;
        form.attr("novalidate", true);
        if (form.attr("data-h5f-novalidate") == null) {
          return bindEvent(form, inst, opts.immediate === true);
        }
      }
    });
  };


  /*
   * 获取指定实例
   * 
   * @method  get
   * @param   form {DOM/jQuery/String}
   * @return  {Object}
   */

  Form.get = function(form) {
    return this.forms[getInstId(form)];
  };

  Form.errors = function(msgs) {
    return $.extend(ERROR, msgs);
  };

  Form.rules = function(rules) {
    return (this.RULES = $.extend(true, {}, $.extend(RULE, rules)));
  };

  return Form;

})();

window[LIB_CONFIG.name] = Form;

}));
