
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
        deferred.reject helper.newFileNotFoundError(filePath)
      else
        deferred.resolve()
    deferred.promise

  # Parse step 2: Check that the required handler is present
  .then ->
    handler = helper.getFileHandlerForPath filePath

  # Parse step 3: Read file
  .then ->
    deferred = q.defer()
    fs.readFile filePath, 'utf8', (error, content) ->
      if error?
        deferred.reject helper.newFileReadError filePath
      else
        fileContent = content
        deferred.resolve()
    deferred.promise

  # Parse step 4: parse content
  .then ->
    callback helper.createStoreFromContent(fileContent, handler), null

  # Parse failure
  .fail (error) ->
    callback null, error


# Synchronous config parser
conifer.parseSync = (filePath) ->
  verifyArg.isUnemptyString 'filePath', filePath

  # Parse step 1: Check that file exists
  try
    stats = fs.statSync filePath
    throw new Error() if not stats.isFile()
  catch error
    throw helper.newFileNotFoundError filePath

  # Parse step 2: Check that the required handler is present
  handler = helper.getFileHandlerForPath filePath

  # Parse step 3: Read file
  fileContent = null
  try
    fileContent = fs.readFileSync filePath, 'utf8'
  catch error
    throw helper.newFileReadError filePath

  # Parse step 4: parse content
  return helper.createStoreFromContent fileContent, handler


# Helper functions to reduce repetition in parse and parseSync
helper =

  # Create a new file not found error
  newFileNotFoundError: (filePath) ->
    new FileNotFoundError "Config file at #{filePath} was not found, or is not a file"

  # Create a new handler not found error
  newHandlerNotFoundError: (fileExtension) ->
    new conifer.handler.HandlerNotFoundError "Handler for '#{fileExtension}' was not found"

  # Create a new file read error
  newFileReadError: (filePath) ->
    new IOError "Config file at #{filePath} could not be read"

  # Get (and validate) the handler for a file path
  getFileHandlerForPath: (filePath) ->
    fileExtension = util.path.getFileExtension filePath
    handler = conifer.handler.getHandler fileExtension
    if not handler?
      throw helper.newHandlerNotFoundError fileExtension
    return handler

  # Create a Store from file content and a handler function
  createStoreFromContent: (fileContent, handler) ->
    parsedContent = handler fileContent
    new conifer.Store parsedContent
