PATTERN_KEY_SOURCE = "\{\{\s*([A-Z_]+)\s*\}\}"

RULE =
  ABSOLUTE_URL: /^.*$/
  # from https://html.spec.whatwg.org/multipage/forms.html#e-mail-state-(type=email)
  EMAIL: /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
  NUMBER: /^(\-)?\d+(\.\d+)?$/

ERROR =
  UNKNOWN_INPUT_TYPE: "Unknown input type for {{LABEL}}."
  # For textual elements
  COULD_NOT_BE_EMPTY: "{{LABEL}} could not be empty."
  LENGTH_SMALLER_THAN_MINIMUM: "The length of {{LABEL}} is smaller than {{MINLENGTH}}."
  LENGTH_BIGGER_THAN_MAXIMUM: "The length of {{LABEL}} is bigger than {{MAXLENGTH}}."
  INVALID_VALUE: "{{LABEL}}'s value is invalid."
  NOT_AN_ABSOLUTE_URL: "{{LABEL}} isn't an absolute URL."
  NOT_AN_EMAIL: "{{LABEL}} isn't an E-mail."
  NOT_A_NUMBER: "{{LABEL}} isn't a number."
  UNDERFLOW: "{{LABEL}}'s value is smaller than {{MIN}}."
  OVERFLOW: "{{LABEL}}'s value is bigger than {{MAX}}."
  DIFFERENT_VALUE: "{{LABEL}}'s value is different from {{ASSOCIATE_LABEL}}."
  # For checkable elements
  AT_LEAST_CHOOSE_ONE: "At least choose an option from {{LABEL}}."
  SHOOLD_BE_CHOSEN: "{{UNIT_LABEL}} shoold be chosen."
  # For select
  SHOOLD_CHOOSE_AN_OPTION: "Must choose an option of {{LABEL}}."

EVENT =
  # 表单
  SUBMIT: "H5F:submit"
  DESTROY: "H5F:destroy"
  BEFORE_VALIDATE: "H5F:beforeValidate"
  # 字段
  VALIDATE: "H5F:validate"
  VALID: "H5F:valid"
  INVALID: "H5F:invalid"
  DISABLED: "H5F:disabled"
  ENABLED: "H5F:enabled"
