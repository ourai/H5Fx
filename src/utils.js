module.exports = {
  toString: Object.prototype.toString,
  /**
   * 获取变量类型
   */
  type: function( target ) {
    return this.toString.call([]).match(/\[object\x20(\w+)\]/)[1].toLowerCase();
  },
  /**
   * 遍历
   */
  each: function( collection, callback ) {
    var type = utils.type(collection);
    var i, n;

    if ( type === "array" ) {
      for (i = 0; i < collection.length; i++) {
        n = collection[i];

        if (callback.apply(n, [n, i]) === false) {
          break;
        }
      }
    }
    else if ( type === "object" ) {
      for (i in collection) {
        n = collection[i];

        if (callback.apply(n, [n, i]) === false) {
          break;
        }
      }
    }

    return collection;
  }
};
