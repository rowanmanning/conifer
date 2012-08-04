
# Dependencies
CSON = require 'cson'
{ArgumentError, ArgumentMissingError, ArgumentTypeError, FileNotFoundError} = require 'er'
fs = require 'fs'
{Store} = require './store'
util = require './util'
verifyArg = util.verifyArg


# Set up exports
module.exports = conifer = {}


# Store class alias
conifer.Store = Store


# File handler storage (and defaults)
fileHandlers =

  # 'cson' file handler
  cson: (fileContent) ->
    verifyArg.isString 'fileContent', fileContent
    result = CSON.parseSync fileContent
    if result instanceof Error
      throw new SyntaxError result.message
    result

  # 'json' file handler
  json: (fileContent) ->
    verifyArg.isString 'fileContent', fileContent
    if fileContent is ''
      return undefined
    JSON.parse fileContent

# Remove a file handler
conifer.removeFileHandler = (fileExtension) ->
  verifyArg.isUnemptyString 'fileExtension', fileExtension
  delete fileHandlers[fileExtension.toLowerCase()]

# Set a file handler
conifer.setFileHandler = (fileExtension, fileHandler) ->
  verifyArg.isUnemptyString 'fileExtension', fileExtension
  verifyArg.isFunction 'fileHandler', fileHandler
  fileHandlers[fileExtension.toLowerCase()] = fileHandler

# Get a file handler
conifer.getFileHandler = (fileExtension) ->
  verifyArg.isUnemptyString 'fileExtension', fileExtension
  fileHandlers[fileExtension.toLowerCase()]

# Handler not found error
class conifer.HandlerNotFoundError extends Error
  constructor: (@message = 'Handler not found') ->


# Config parser (todo: refactor this into non-spaghetti some day)
conifer.parse = (filePath, callback) ->
  verifyArg.isUnemptyString 'filePath', filePath
  verifyArg.isFunction 'callback', callback
  fs.stat filePath, (err, stats) ->
    if err? or not stats.isFile()
      callback null, new FileNotFoundError "Config file at #{filePath} was not found, or is not a file"
    else
      fileExtension = util.path.getFileExtension filePath
      fileHandler = conifer.getFileHandler fileExtension
      if not fileHandler?
        callback null, new conifer.HandlerNotFoundError "Handler for '#{fileExtension}' was not found"
        return
      fs.readFile filePath, 'utf8', (err, data) ->
        try
          parsedData = fileHandler data
          callback new conifer.Store(parsedData), null
        catch error
          callback null, error


# Synchronous config parser (todo: refactor this into non-spaghetti some day)
conifer.parseSync = (filePath) ->
  verifyArg.isUnemptyString 'filePath', filePath
  fileError = new FileNotFoundError "Config file at #{filePath} was not found, or is not a file"
  try
    stats = fs.statSync filePath
    throw new Error() if not stats.isFile()
  catch error
    throw fileError
  fileExtension = util.path.getFileExtension filePath
  fileHandler = conifer.getFileHandler fileExtension
  if not fileHandler?
    throw new conifer.HandlerNotFoundError "Handler for '#{fileExtension}' was not found"
    return
  data = fs.readFileSync filePath, 'utf8'
  parsedData = fileHandler data
  new conifer.Store(parsedData)
