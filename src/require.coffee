asar = require 'asar'
fs   = require 'fs'
path = require 'path'
util = require 'util'

# Separate asar package's path from full path.
splitPath = (p) ->
  return [false] if typeof p isnt 'string'
  return [true, p, ''] if p.substr(-5) is '.asar'
  index = p.lastIndexOf ".asar#{path.sep}"
  return [false] if index is -1
  [true, p.substr(0, index + 5), p.substr(index + 6)]

readFileSync = fs.readFileSync
fs.readFileSync = (p) ->
  [isAsar, asarPath, filePath] = splitPath p
  if isAsar
    asar.extractFile asarPath, filePath
  else
    readFileSync.apply this, arguments

