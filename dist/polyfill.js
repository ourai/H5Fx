define('dist/polyfill', function(require, exports, module) {

  var utils = require("dist/utils");
  
  // HTML5 Forms 中定义的 API
  var constraints = [
    {
      name: "validity",
      value: {
        valueMissing: false,
        typeMismatch: false,
        patternMismatch: false,
        tooLong: false,
        tooShort: false,
        rangeUnderflow: false,
        rangeOverflow: false,
        stepMismatch: false,
        badInput: false,
        customError: false,
        valid: true
      }
    },
    {
      name: "validationMessage",
      value: ""
    },
    {
      name: "setCustomValidity",
      value: function( control ) {
        return (function ( message ) {
            if (!(message === "" || message === undefined)) {
              this.validity.customError = true;
            }
    
            return this.validationMessage = utils.toString(message);
          }).call(control);
      }
    },
    {
      name: "checkValidity",
      value: function() {}
    },
    {
      name: "willValidate",
      value: function( control ) {
        // 验证控件是否为可限制的
      }
    }
  ];
  
  /**
   * 检测缺失的 API
   */
  function check() {
    var apis = [];
    var input = document.createElement("input");
  
    utils.each(constraints, function( api ) {
      if ( input[api.name] === undefined ) {
        apis.push(api);
      }
    });
  
    return apis;
  }
  
  function shim( control, apis ) {
    utils.each(apis, function( api ) {
      var v = api.value;
  
      if ( utils.type(v) === "function" ) {
        control[api.name] = v(control);
      }
      else {
        control[api.name] = v;
      }
    });
  }
  
  function checkValidity( control ) {
    var attrs = control.attributes;
    var validity = control.validity;
  
    if ( !!attrs.required ) {
      if ( control.value === "" ) {
        validity.valueMissing = true;
        validity.valid = false;
      }
      else {
      }
    }
  }
  
  module.exports = {
    init: function() {
      var apis = check();
  
      if ( apis.length ) {
        utils.each(document.getElementsByTagName("form"), function( form ) {
          utils.each(form.elements, function( control ) {
            shim(control, apis);
            checkValidity(control);
          });
        });
      }
    }
  };
  

});
