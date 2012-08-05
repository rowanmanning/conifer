
# Dependencies
{FileNotFoundError, IOError} = require 'er'
fs = require 'fs'
handler = require './handler'
q = require 'q'
{Store} = require './store'
util = require './util'
verifyArg = util.verifyArg


# Set up exports
module.exports = conifer = {}


# Module aliases
conifer.Store = Store
conifer.handler = handler


# Config parser
conifer.parse = (filePath, callback) ->
  verifyArg.isUnemptyString 'filePath', filePath
  verifyArg.isFunction 'callback', callback

  # Vars
  fileContent = null
  handler = null

  # Parse step 1: Check that file exists
  q.fcall ->
    deferred = q.defer()
    fs.stat filePath, (error, stats) ->
      if error? or not stats.isFile()
        deferred.reject new FileNotFoundError("Config file at #{filePath} was not found, or is not a file")
      else
        deferred.resolve()
    deferred.promise

  # Parse step 2: Check that the required handler is present
  .then ->
    fileExtension = util.path.getFileExtension filePath
    handler = conifer.handler.getHandler fileExtension
    if not handler?
      throw new conifer.handler.HandlerNotFoundError "Handler for '#{fileExtension}' was not found"

  # Parse step 3: Read file
  .then ->
    deferred = q.defer()
    fs.readFile filePath, 'utf8', (error, content) ->
      if error?
        deferred.reject new IOError("Config file at #{filePath} could not be read")
      else
        fileContent = content
        deferred.resolve()
    deferred.promise

  # Parse step 4: parse content
  .then ->
    parsedContent = handler fileContent
    callback new conifer.Store(parsedContent), null

  # Parse failure
  .fail (error) ->
    callback null, error


# Synchronous config parser
conifer.parseSync = (filePath) ->
  verifyArg.isUnemptyString 'filePath', filePath

  # Parse step 1: Check that file exists
  fileError = new FileNotFoundError "Config file at #{filePath} was not found, or is not a file"
  try
    stats = fs.statSync filePath
    throw new Error() if not stats.isFile()
  catch error
    throw fileError

  # Parse step 2: Check that the required handler is present
  fileExtension = util.path.getFileExtension filePath
  handler = conifer.handler.getHandler fileExtension
  if not handler?
    throw new conifer.handler.HandlerNotFoundError "Handler for '#{fileExtension}' was not found"

  # Parse step 3: Read file
  fileContent = null
  try
    fileContent = fs.readFileSync filePath, 'utf8'
  catch error
    throw new IOError "Config file at #{filePath} could not be read"

  # Parse step 4: parse content
  parsedContent = handler fileContent
  new conifer.Store parsedContent
