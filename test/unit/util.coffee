
# Dependencies
{assert} = require 'chai'
{ArgumentError, ArgumentMissingError, ArgumentTypeError, BadConstructionError} = require 'er'
{spy} = require 'sinon'


# Tests
suite 'util module', ->
  util = require '../../src/util'

  test 'should be an object', ->
    assert.isObject util

  test 'should have a `verifyArg` namespace', ->
    assert.isObject util.verifyArg

  test 'should have a `verifyConstruction` function', ->
    assert.isFunction util.verifyConstruction

  test 'should have a `path` namespace', ->
    assert.isObject util.path
  

  suite '`verifyArg` namespace', ->
    verifyArg = util.verifyArg

    test 'should have an `isDefined` function', ->
      assert.isFunction verifyArg.isDefined

    test 'should have a `isFunction` function', ->
      assert.isFunction verifyArg.isFunction

    test 'should have a `isObject` function', ->
      assert.isFunction verifyArg.isObject

    test 'should have an `isString` function', ->
      assert.isFunction verifyArg.isString

    test 'should have an `isUnemptyString` function', ->
      assert.isFunction verifyArg.isUnemptyString


    suite '`isDefined` function', ->

      test 'should not throw when called with a defined value argument', ->
        assert.doesNotThrow ->
          verifyArg.isDefined 'name', 'foo'
        assert.doesNotThrow ->
          verifyArg.isDefined 'name', 123
        assert.doesNotThrow ->
          verifyArg.isDefined 'name', {}

      test 'should throw when called with an undefined value argument', ->
        assert.throws ->
          verifyArg.isDefined 'name'
        , ArgumentMissingError


    suite '`isFunction` function', ->

      test 'should not throw when called with a function value argument', ->
        assert.doesNotThrow ->
          verifyArg.isFunction 'name', ->

      test 'should throw when called with a non-function value argument', ->
        assert.throws ->
          verifyArg.isFunction 'name', {}
        , ArgumentTypeError


    suite '`isObject` function', ->

      test 'should not throw when called with an object value argument', ->
        assert.doesNotThrow ->
          verifyArg.isObject 'name', {}

      test 'should throw when called with a non-object value argument', ->
        assert.throws ->
          verifyArg.isObject 'name', 'foo'
        , ArgumentTypeError


    suite '`isString` function', ->

      test 'should not throw when called with a string value argument', ->
        assert.doesNotThrow ->
          verifyArg.isString 'name', 'foo'
        assert.doesNotThrow ->
          verifyArg.isString 'name', ''

      test 'should throw when called with a non-string value argument', ->
        assert.throws ->
          verifyArg.isString 'name', {}
        , ArgumentTypeError


    suite '`isUnemptyString` function', ->

      test 'should not throw when called with an unempty string value argument', ->
        assert.doesNotThrow ->
          verifyArg.isUnemptyString 'name', 'foo'

      test 'should throw when called with an empty string value argument', ->
        assert.throws ->
          verifyArg.isUnemptyString 'name', ''
        , ArgumentError

      test 'should throw when called with a non-string value argument', ->
        assert.throws ->
          verifyArg.isUnemptyString 'name', {}
        , ArgumentTypeError


  suite '`verifyConstruction` function', ->

    test 'should not throw when called with an object and the class it is instantiated from', ->
      assert.doesNotThrow ->
        util.verifyConstruction new Date(), Date

    test 'should throw when called with an object and a class it is not instantiated from', ->
      assert.throws ->
        util.verifyConstruction {}, Date
      , BadConstructionError


  suite '`path` namespace', ->
    path = util.path

    test 'should have a `getFileExtension` function', ->
      assert.isFunction path.getFileExtension


    suite '`getFileExtension` function', ->

      test 'should not throw when called with a string filePath argument', ->
        assert.doesNotThrow ->
          path.getFileExtension 'foo'

      test 'should throw when called with a non-string filePath argument', ->
        assert.throws ->
          path.getFileExtension {}
        , ArgumentTypeError

      test 'should return a string', ->
        assert.isString path.getFileExtension('foo')

      test 'should return the expected file extension with no leading period', ->
        assert.strictEqual path.getFileExtension('foo'), ''
        assert.strictEqual path.getFileExtension('hello.html'), 'html'
        assert.strictEqual path.getFileExtension('hello..html'), 'html'
        assert.strictEqual path.getFileExtension('hello.html.mustache'), 'mustache'
        assert.strictEqual path.getFileExtension('path/to/hello.html'), 'html'
