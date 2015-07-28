# 是否拥有某个 HTML 属性
hasAttr = ( ele, attr ) ->
  return ele.hasAttribute attr

# 转换为数字
toNum = ( str ) ->
  return parseFloat str
