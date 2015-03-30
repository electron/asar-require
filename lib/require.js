(function() {
  var asar, fs, path, readFileSync, splitPath, util;

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

  readFileSync = fs.readFileSync;

  fs.readFileSync = function(p) {
    var asarPath, filePath, isAsar, _ref;
    _ref = splitPath(p), isAsar = _ref[0], asarPath = _ref[1], filePath = _ref[2];
    if (isAsar) {
      return asar.extractFile(asarPath, filePath);
    } else {
      return readFileSync.apply(this, arguments);
    }
  };

}).call(this);
