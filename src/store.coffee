
# Dependencies
{BadConstructionError} = require 'er'
{verifyArg, verifyConstruction} = require './util'


# Store class
class exports.Store

  # Class constructor
  constructor: (configObject) ->
    verifyConstruction this, exports.Store
    verifyArg.isObject 'configObject', configObject
    @_store = configObject

  # Set a configuration
  set: (key, value) ->
    verifyArg.isUnemptyString 'key', key
    verifyArg.isDefined 'value', value
    @_store[key] = value

  # Get a configuration
  get: (key) ->
    verifyArg.isUnemptyString 'key', key
    @_store[key]
