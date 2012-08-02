
# Dependencies
colors = require 'colors'
{exec} = require 'child_process'

# Paths
paths =
  config: './config'
  lib: './lib'
  nodebin: './node_modules/.bin'
  src: './src'
  unitTest: './test/unit'

# Build JavaScript
desc 'This builds JavaScript from the CoffeeScript source'
task 'build', ['lint', 'test'], ->
  console.log 'Building JavaScript:'.cyan
  exec "#{paths.nodebin}/coffee -o #{paths.lib} #{paths.src}", (error, stdout, stderr) ->
    if error is null
      console.log 'Built!'.green
    else
      console.log stderr
      process.exit()
    complete()
, async: true

# Run CoffeeLint
desc 'This runs CoffeeLint on the CoffeeScript source'
task 'lint', ->
  console.log 'Linting:'.cyan
  exec getLintCommand(), (error, stdout, stderr) ->
    if stderr is ''
      console.log stdout
    else
      console.log stderr
      process.exit()
    complete()
, async: true

# Run unit tests
desc 'This runs all unit tests'
task 'test', ->
  console.log 'Running unit tests:'.cyan
  exec getTestCommand(), (error, stdout, stderr) ->
    if error is null
      console.log stdout
    else
      console.log stderr
      process.exit()
    complete()
, async: true

# CI
desc 'This runs all tasks required for CI'
task 'ci', ['lint', 'test']

# Default task
task 'default', ['build']

# Generate a lint command
getLintCommand = (options = {}) ->
  options.configFile ?= "#{paths.config}/coffeelint.json"
  "#{paths.nodebin}/coffeelint -f #{options.configFile} #{paths.src}/** #{paths.unitTest}/**";

# Generate a test command
getTestCommand = (options = {}) ->
  options.ui ?= 'tdd'
  options.reporter ?= 'spec'
  options.dir ?= paths.unitTest
  "#{paths.nodebin}/mocha --compilers coffee:coffee-script --ui #{options.ui} --reporter #{options.reporter} --colors #{options.dir}/**";
