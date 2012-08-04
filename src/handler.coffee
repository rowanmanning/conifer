
# Dependencies
CSON = require 'cson'
{verifyArg} = require './util'


# File handler storage (and defaults)
handlers =

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
exports.removeHandler = (fileExtension) ->
  verifyArg.isUnemptyString 'fileExtension', fileExtension
  delete handlers[fileExtension.toLowerCase()]


# Set a file handler
exports.setHandler = (fileExtension, handlerFunction) ->
  verifyArg.isUnemptyString 'fileExtension', fileExtension
  verifyArg.isFunction 'handlerFunction', handlerFunction
  handlers[fileExtension.toLowerCase()] = handlerFunction


# Get a file handler
exports.getHandler = (fileExtension) ->
  verifyArg.isUnemptyString 'fileExtension', fileExtension
  handlers[fileExtension.toLowerCase()]


# Handler not found error
class exports.HandlerNotFoundError extends Error
  constructor: (@message = 'Handler not found') ->
