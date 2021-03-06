
# Dependencies
async = require 'async'
{FileNotFoundError, IOError} = require 'er'
fs = require 'fs'
handler = require './handler'
path = require 'path'
util = require './util'
verifyArg = util.verifyArg


# Set up exports
module.exports = conifer = {}


# Module aliases
conifer.handler = handler


# Config parser
conifer.parse = (filePath, callback) ->
  verifyArg.isUnemptyString 'filePath', filePath
  verifyArg.isFunction 'callback', callback

  # Vars
  handler = null

  # Parse
  async.waterfall [

    # Parse step 1: Check that file exists
    (done) ->
      fs.stat filePath, (error, stats) ->
        if error? or not stats.isFile()
          done newFileNotFoundError(filePath)
        else
          done()

    # Parse step 2: Check that the required handler is present
    (done) ->
      try
        handler = getFileHandlerForPath filePath
        done(null, handler)
      catch error
        done error

    # Parse step 3: Read file
    (handler, done) ->
      fs.readFile filePath, 'utf8', (error, fileContent) ->
        if error?
          done newFileReadError(filePath)
        else
          done null, handler, fileContent

    # Parse step 4: parse content
    (handler, fileContent, done) ->
      try
        done null, handler(fileContent)
      catch error
        done error

    # Parse step 5: Run imports
    (parsedContent, done) ->
      try
        queue = async.queue ((task, taskDone) -> task taskDone, done), 3
        queue.drain = ->
          done null, parsedContent
        parseObjectImports parsedContent, path.dirname(filePath), queue
        queue.push (taskDone, parseDone) ->
          taskDone()
      catch error
        done error

  ],
  # Trigger callback
  (error, config) ->
    if error
      callback error, null
    else
      callback null, config

# Parse object imports
parseObjectImports = (object, importBasePath, queue) ->
  for own property, value of object
    do (property, value) ->

      # Import merge
      if propertyIsImportMerge property, value
        for importFilePath in value
          do (importFilePath) ->
            importFilePath = path.resolve importBasePath + '/' + importFilePath
            queue.push (taskDone, parseDone) ->
              conifer.parse importFilePath, (error, importContent) ->
                if error
                  parseDone error
                else
                  util.mergeObjects object, importContent
                  taskDone()
              , false

      # Import property
      else if valueIsImportProperty value
        importFilePath = path.resolve importBasePath + '/' + cleanImportString(value)
        queue.push (taskDone, parseDone) ->
          conifer.parse importFilePath, (error, importContent) ->
            if error
              parseDone error
            else
              object[property] = importContent
              taskDone()
          , false

      # Nested object
      else if typeof value is 'object'
        parseObjectImports value, importBasePath, queue

  # Cleanup
  removeImportMergeProperties object


# Synchronous config parser
conifer.parseSync = (filePath) ->
  verifyArg.isUnemptyString 'filePath', filePath

  # Parse step 1: Check that file exists
  try
    stats = fs.statSync filePath
    throw new Error() if not stats.isFile()
  catch error
    throw newFileNotFoundError filePath

  # Parse step 2: Check that the required handler is present
  handler = getFileHandlerForPath filePath

  # Parse step 3: Read file
  fileContent = null
  try
    fileContent = fs.readFileSync filePath, 'utf8'
  catch error
    throw newFileReadError filePath

  # Parse step 4: Parse content
  config = handler fileContent

  # Parse step 5: Run imports
  parseObjectImportsSync config, path.dirname(filePath)

  # Return
  config

# Parse object imports synchronously
parseObjectImportsSync = (object, importBasePath) ->
  for own property, value of object

    # Import merge
    if propertyIsImportMerge property, value
      for importFilePath in value
        importFilePath = path.resolve importBasePath + '/' + importFilePath
        util.mergeObjects object, conifer.parseSync(importFilePath, false)

    # Import property
    else if valueIsImportProperty value
      importFilePath = path.resolve importBasePath + '/' + cleanImportString(value)
      object[property] = conifer.parseSync importFilePath, false

    # Nested object
    else if typeof value is 'object'
      parseObjectImportsSync value, importBasePath

  # Cleanup
  removeImportMergeProperties object


# Create a new file not found error
newFileNotFoundError = (filePath) ->
  new FileNotFoundError "Config file at #{filePath} was not found, or is not a file"

# Create a new handler not found error
newHandlerNotFoundError = (fileExtension) ->
  new conifer.handler.HandlerNotFoundError "Handler for '#{fileExtension}' was not found"

# Create a new file read error
newFileReadError = (filePath) ->
  new IOError "Config file at #{filePath} could not be read"

# Get (and validate) the handler for a file path
getFileHandlerForPath = (filePath) ->
  fileExtension = util.path.getFileExtension filePath
  handler = conifer.handler.getHandler fileExtension
  if not handler?
    throw newHandlerNotFoundError fileExtension
  return handler

# Import indicator
IMPORT_INDICATOR = '<<'

# Check whether a property is an 'import merge' property
propertyIsImportMerge = (property, value) ->
  if property is IMPORT_INDICATOR and Array.isArray(value)
    return false for item in value when typeof item isnt 'string'
    true
  else
    false

# Remove the 'import merge' properties of an object
removeImportMergeProperties = (object) ->
  for own property, value of object
    if propertyIsImportMerge(property, value)
      delete object[property]
    else if typeof value is 'object' and not Array.isArray value
      removeImportMergeProperties value

# Import string regular expression
importStringRegexp = new RegExp "^#{IMPORT_INDICATOR}\\s+"

# Check whether a property value is an 'import string'
valueIsImportProperty = (value) ->
  (typeof value is 'string' and importStringRegexp.test(value))

# Clean an import string value
cleanImportString = (importString) ->
  importString.replace importStringRegexp, ''
