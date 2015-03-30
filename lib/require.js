(function() {
  var asar, fs, path, splitPath, util;

  asar = require('asar');

  fs = require('fs');

  path = require('path');

  util = require('util');

  splitPath = function(p) {
    var index;
    if (typeof p !== 'string') {
      return [false];
    }
    if (p.substr(-5) === '.asar') {
      return [true, p, ''];
    }
    index = p.lastIndexOf(".asar" + path.sep);
    if (index === -1) {
      return [false];
    }
    return [true, p.substr(0, index + 5), p.substr(index + 6)];
  };

}).call(this);
