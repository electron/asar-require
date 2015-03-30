asar = require 'asar'
fs   = require 'fs'
path = require 'path'

# Separate asar package's path from full path.
splitPath = (p) ->
  return [false] if typeof p isnt 'string'
  return [true, p, ''] if p.substr(-5) is '.asar'
  index = p.lastIndexOf ".asar#{path.sep}"
  return [false] if index is -1
  [true, p.substr(0, index + 5), p.substr(index + 6)]

# Convert asar archive's Stats object to fs's Stats object.
nextInode = 0
uid = if process.getuid? then process.getuid() else 0
gid = if process.getgid? then process.getgid() else 0
fakeTime = new Date()
asarStatsToFsStats = (stats) ->
  isFile = !stats.files
  {
    dev: 1,
    ino: ++nextInode,
    mode: 33188,
    nlink: 1,
    uid: uid,
    gid: gid,
    rdev: 0,
    atime: stats.atime || fakeTime,
    birthtime: stats.birthtime || fakeTime,
    mtime: stats.mtime || fakeTime,
    ctime: stats.ctime || fakeTime,
    size: stats.size,
    isFile: -> isFile
    isDirectory: -> !isFile
    isSymbolicLink: -> false
    isBlockDevice: -> false
    isCharacterDevice: -> false
    isFIFO: -> false
    isSocket: -> false
  }

# Start overriding fs methods.
readFileSync = fs.readFileSync
fs.readFileSync = (p, options) ->
  [isAsar, asarPath, filePath] = splitPath p
  return readFileSync.apply this, arguments unless isAsar

  if not options
    options = encoding: null, flag: 'r'
  else if typeof options is 'string'
    options = encoding: options, flag: 'r'
  else if typeof options isnt 'object'
    throw new TypeError('Bad arguments')

  content = asar.extractFile asarPath, filePath
  if options.encoding
    content.toString options.encoding
  else
    content

statSync = fs.statSync
fs.statSync = (p) ->
  [isAsar, asarPath, filePath] = splitPath p
  return statSync.apply this, arguments unless isAsar
  asarStatsToFsStats asar.statFile(asarPath, filePath)

# lstatSync is not implemented yet.
fs.lstatSync = fs.statSync

realpathSync = fs.realpathSync
fs.realpathSync = (p) ->
  [isAsar, asarPath, filePath] = splitPath p
  return realpathSync.apply this, arguments unless isAsar
  stat = asar.statFile(asarPath, filePath)
  filePath = stat.link if stat.link
  path.join realpathSync(asarPath), filePath

readdirSync = fs.readdirSync
fs.readdirSync = (p) ->
  [isAsar, asarPath, filePath] = splitPath p
  return readdirSync.apply this, arguments unless isAsar
  stat = asar.statFile(asarPath, filePath, true)
  file for file,_ of stat.files
