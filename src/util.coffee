
# Dependencies
{ArgumentError, ArgumentMissingError, ArgumentTypeError, BadConstructionError} = require 'er'
path = require 'path'


# Argument verification
exports.verifyArg =

  isDefined: (name, value) ->
    if typeof value is 'undefined'
      throw new ArgumentMissingError 'Missing #{name} argument'

  isFunction: (name, value) ->
    if typeof value isnt 'function'
      throw new ArgumentTypeError "Invalid #{name} argument, function expected"

  isObject: (name, value) ->
    if typeof value isnt 'object'
      throw new ArgumentTypeError "Invalid #{name} argument, object expected"

  isString: (name, value) ->
    if typeof value isnt 'string'
      throw new ArgumentTypeError "Invalid #{name} argument, string expected"

  isUnemptyString: (name, value) ->
    exports.verifyArg.isString name, value
    if value is ''
      throw new ArgumentError "Invalid #{name} argument, unempty string expected"


# Construction verification
exports.verifyConstruction = (instance, constructor) ->
  if instance not instanceof constructor
    throw new BadConstructionError


# Path utilities
exports.path =

  getFileExtension: (filePath) ->
    exports.verifyArg.isString 'filePath', filePath
    path.extname(filePath).replace /^\./, ''
