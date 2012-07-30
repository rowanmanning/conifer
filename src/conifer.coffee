
# Dependencies
CSON = require 'cson'
{
  ArgumentError,
  ArgumentMissingError,
  ArgumentTypeError,
  BadConstructionError,
  FileNotFoundError
} = require 'er'
fs = require 'fs'
path = require 'path'


# Set up exports
module.exports = conifer = {}


# Store class
class conifer.Store

  # Class constructor
  constructor: (configObject) ->
    if not this instanceof conifer.Store
      throw new BadConstructionError
    verifyArg.configObject configObject
    @_store = configObject

  # Set a configuration
  set: (key, value) ->
    verifyArg.key key
    verifyArg.value value
    @_store[key] = value

  # Get a configuration
  get: (key) ->
    verifyArg.key key
    @_store[key]


# File handler storage (and defaults)
fileHandlers =

  # 'cson' file handler
  cson: (fileContent) ->
    verifyArg.fileContent fileContent
    result = CSON.parseSync fileContent
    if result instanceof Error
      throw new SyntaxError result.message
    result

  # 'json' file handler
  json: (fileContent) ->
    verifyArg.fileContent fileContent
    if fileContent is ''
      return undefined
    JSON.parse fileContent

# Remove a file handler
conifer.removeFileHandler = (fileExtension) ->
  verifyArg.fileExtension fileExtension
  delete fileHandlers[fileExtension.toLowerCase()]

# Set a file handler
conifer.setFileHandler = (fileExtension, fileHandler) ->
  verifyArg.fileExtension fileExtension
  verifyArg.fileHandler fileHandler
  fileHandlers[fileExtension.toLowerCase()] = fileHandler

# Get a file handler
conifer.getFileHandler = (fileExtension) ->
  verifyArg.fileExtension fileExtension
  fileHandlers[fileExtension.toLowerCase()]

# Handler not found error
class conifer.HandlerNotFoundError extends Error
  constructor: (@message = 'Handler not found') ->


# Config parser (todo: refactor this into non-spaghetti some day)
conifer.parse = (filePath, callback) ->
  verifyArg.filePath filePath
  verifyArg.callback callback
  fs.stat filePath, (err, stats) ->
    if err? or not stats.isFile()
      callback null, new FileNotFoundError "Config file at #{filePath} was not found, or is not a file"
    else
      fileExtension = util.getFileExtension filePath
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
  verifyArg.filePath filePath
  fileError = new FileNotFoundError "Config file at #{filePath} was not found, or is not a file"
  try
    stats = fs.statSync filePath
    throw new Error() if not stats.isFile()
  catch error
    throw fileError
  fileExtension = util.getFileExtension filePath
  fileHandler = conifer.getFileHandler fileExtension
  if not fileHandler?
    throw new conifer.HandlerNotFoundError "Handler for '#{fileExtension}' was not found"
    return
  data = fs.readFileSync filePath, 'utf8'
  parsedData = fileHandler data
  new conifer.Store(parsedData)


# Utilities
util =

  # Get the file extension part of a filePath
  getFileExtension: (filePath) ->
    path.extname(filePath).replace /^\./, ''


# Argument verification
verifyArg =

  configObject: (arg) ->
    if typeof arg isnt 'object'
      throw new ArgumentTypeError 'Invalid configObject argument, object expected'

  unemptyString: (arg, argName) ->
    if typeof arg isnt 'string'
      throw new ArgumentTypeError "Invalid #{argName} argument, string expected"
    if arg is ''
      throw new ArgumentError "Invalid #{argName} argument, unempty string expected"

  key: (arg) ->
    verifyArg.unemptyString arg, 'key'

  value: (arg) ->
    if arg is undefined
      throw new ArgumentMissingError 'Missing value argument'

  fileContent: (arg) ->
    if typeof arg isnt 'string'
      throw new ArgumentTypeError 'Invalid fileContent argument, string expected'

  fileExtension: (arg) ->
    verifyArg.unemptyString arg, 'fileExtension'

  fn: (arg, argName) ->
    if typeof arg isnt 'function'
      throw new ArgumentTypeError "Invalid #{argName} argument, function expected"

  fileHandler: (arg) ->
    verifyArg.fn arg, 'fileHandler'

  filePath: (arg) ->
    verifyArg.unemptyString arg, 'filePath'

  callback: (arg) ->
    verifyArg.fn arg, 'callback'
