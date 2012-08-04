
# Dependencies
{FileNotFoundError} = require 'er'
fs = require 'fs'
handler = require './handler'
{Store} = require './store'
util = require './util'
verifyArg = util.verifyArg


# Set up exports
module.exports = conifer = {}


# Module aliases
conifer.Store = Store
conifer.handler = handler




# Config parser (todo: refactor this into non-spaghetti some day)
conifer.parse = (filePath, callback) ->
  verifyArg.isUnemptyString 'filePath', filePath
  verifyArg.isFunction 'callback', callback
  fs.stat filePath, (err, stats) ->
    if err? or not stats.isFile()
      callback null, new FileNotFoundError "Config file at #{filePath} was not found, or is not a file"
    else
      fileExtension = util.path.getFileExtension filePath
      handler = conifer.handler.getHandler fileExtension
      if not handler?
        callback null, new conifer.handler.HandlerNotFoundError "Handler for '#{fileExtension}' was not found"
        return
      fs.readFile filePath, 'utf8', (err, data) ->
        try
          parsedData = handler data
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
  handler = conifer.handler.getHandler fileExtension
  if not handler?
    throw new conifer.handler.HandlerNotFoundError "Handler for '#{fileExtension}' was not found"
    return
  data = fs.readFileSync filePath, 'utf8'
  parsedData = handler data
  new conifer.Store(parsedData)
