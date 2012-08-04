
# Dependencies
{assert} = require 'chai'
{ArgumentError, ArgumentTypeError} = require 'er'
{spy} = require 'sinon'


# Tests
suite 'handler module', ->
  handler = require '../../src/handler'

  test 'should be an object', ->
    assert.isObject handler

  test 'should have a `removeHandler` function', ->
    assert.isFunction handler.removeHandler

  test 'should have a `setHandler` function', ->
    assert.isFunction handler.setHandler

  test 'should have a `getHandler` function', ->
    assert.isFunction handler.getHandler

  test 'should have a `HandlerNotFoundError` class', ->
    assert.isFunction handler.HandlerNotFoundError


  suite '`removeHandler` function', ->

    test 'should not throw when called with valid arguments', ->
      assert.doesNotThrow ->
        handler.removeHandler 'foo'

    test 'should throw when called with a non-string `fileExtension` argument', ->
      assert.throws ->
        handler.removeHandler {}
      , ArgumentTypeError

    test 'should throw when called with an empty string `fileExtension` argument', ->
      assert.throws ->
        handler.removeHandler ''
      , ArgumentError


  suite '`setHandler` function', ->

    test 'should not throw when called with valid arguments', ->
      assert.doesNotThrow ->
        handler.setHandler 'foo', ->

    test 'should throw when called with a non-string `fileExtension` argument', ->
      assert.throws ->
        handler.setHandler {}, ->
      , ArgumentTypeError

    test 'should throw when called with an empty string `fileExtension` argument', ->
      assert.throws ->
        handler.setHandler '', ->
      , ArgumentError

    test 'should throw when called with a non-function `handlerFunction` argument', ->
      assert.throws ->
        handler.setHandler 'foo', {}
      , ArgumentTypeError


  suite '`getHandler` function', ->

    test 'should not throw when called with valid arguments', ->
      assert.doesNotThrow ->
        handler.getHandler 'foo'

    test 'should throw when called with a non-string `fileExtension` argument', ->
      assert.throws ->
        handler.getHandler {}
      , ArgumentTypeError

    test 'should throw when called with an empty string `fileExtension` argument', ->
      assert.throws ->
        handler.getHandler ''
      , ArgumentError


  suite '`HandlerNotFoundError` class', ->

    suite 'instance with no message set', ->
      instance = null

      setup ->
        instance = new handler.HandlerNotFoundError

      teardown ->
        instance = null

      test "should extend Error", ->
        assert.instanceOf instance, Error

      test 'message property should be a string', ->
        assert.isString instance.message

      test 'message property should be an unempty string', ->
        assert.notStrictEqual instance.message, ''

    suite 'instance with a message set', ->
      instance = null

      setup ->
        instance = new handler.HandlerNotFoundError 'foo'

      teardown ->
        instance = null

      test 'message property should be a string', ->
        assert.isString instance.message

      test 'message property should be equal to the message argument passed into the constructor', ->
        assert.strictEqual instance.message, 'foo'


  suite 'Handlers', ->
    fileExtension = 'foo'
    handlerFunction = -> 'baz'

    teardown ->
      handler.removeHandler fileExtension

    suite 'Handler added', ->

      setup ->
        handler.setHandler fileExtension, handlerFunction

      test '`getHandler` should return the requested handler if present', ->
        assert.strictEqual handler.getHandler(fileExtension), handlerFunction

      test '`getHandler` should return the requested handler regardless of the case of the file extension', ->
        assert.strictEqual handler.getHandler(fileExtension.toUpperCase()), handlerFunction

      test '`getHandler` should return `undefined` if the requested handler isn\'t present', ->
        assert.isUndefined handler.getHandler('bar')

    suite 'Handler added then overwritten', ->
      handlerFunctionOverride = -> 'qux'

      setup ->
        handler.setHandler fileExtension, handlerFunction
        handler.setHandler fileExtension, handlerFunctionOverride

      test '`getHandler` should return the override handler', ->
        assert.strictEqual handler.getHandler(fileExtension), handlerFunctionOverride

    suite 'Handler added then removed', ->

      setup ->
        handler.setHandler fileExtension, handlerFunction
        handler.removeHandler fileExtension

      test '`getHandler` should return `undefined` when the handler is requested', ->
        assert.isUndefined handler.getHandler(fileExtension)


  suite 'Default handlers', ->

    test '\'cson\' handler should be registered', ->
      assert.isFunction handler.getHandler('cson')

    test '\'json\' handler should be registered', ->
      assert.isFunction handler.getHandler('json')


    suite '\'cson\' handler', ->
      csonHandler = handler.getHandler 'cson'

      test 'should not throw when called with valid arguments', ->
        assert.doesNotThrow ->
          csonHandler '{}'

      test 'should throw when called with a non-string `fileContent` argument', ->
        assert.throws ->
          csonHandler {}
        , ArgumentTypeError

      test 'should not throw when called with an empty string `fileContent` argument', ->
        assert.doesNotThrow ->
          csonHandler ''

      test 'should throw when called with an invalid CSON string `fileContent` argument', ->
        assert.throws ->
          csonHandler '{hello:}'
        , SyntaxError

      test 'should return the expected parsed object when called with a valid CSON string', ->
        assert.deepEqual csonHandler('foo: "bar", bar: true'), {foo: 'bar', bar: true}


    suite '\'json\' handler', ->
      jsonHandler = handler.getHandler 'json'

      test 'should not throw when called with valid arguments', ->
        assert.doesNotThrow ->
          jsonHandler '{}'

      test 'should throw when called with a non-string `fileContent` argument', ->
        assert.throws ->
          jsonHandler {}
        , ArgumentTypeError

      test 'should not throw when called with an empty string `fileContent` argument', ->
        assert.doesNotThrow ->
          jsonHandler ''

      test 'should throw when called with an invalid JSON string `fileContent` argument', ->
        assert.throws ->
          jsonHandler '{hello:}'
        , SyntaxError

      test 'should return the expected parsed object when called with a valid JSON string', ->
        assert.deepEqual jsonHandler('{"foo": "bar", "bar": true}'), {foo: 'bar', bar: true}
