
# Dependencies
{assert} = require 'chai'
{
  ArgumentError,
  ArgumentMissingError,
  ArgumentTypeError,
  BadConstructionError,
  FileNotFoundError
} = require 'er'
fs = require 'fs'
{spy} = require 'sinon'


# Config file fixtures
fixtureFile =
  file001: __dirname + '/../fixture/config.001.json'
  file002: __dirname + '/../fixture/config.002.json'
  file003: __dirname + '/../fixture/config.003.lol'


# Tests
suite 'conifer module', ->
  conifer = require '../../src/conifer'

  test 'should be an object', ->
    assert.isObject conifer

  test 'should have an `Store` class', ->
    assert.isFunction conifer.Store

  test 'should have a `removeFileHandler` function', ->
    assert.isFunction conifer.removeFileHandler

  test 'should have a `setFileHandler` function', ->
    assert.isFunction conifer.setFileHandler

  test 'should have a `getFileHandler` function', ->
    assert.isFunction conifer.getFileHandler

  test 'should have a `HandlerNotFoundError` class', ->
    assert.isFunction conifer.HandlerNotFoundError

  test 'should have a `parse` function', ->
    assert.isFunction conifer.parse

  test 'should have a `parseSync` function', ->
    assert.isFunction conifer.parseSync


  suite '`Store` class', ->

    test 'should throw when called without the `new` keyword', ->
      assert.throws ->
        conifer.Store()
      , BadConstructionError

    test 'should not throw when constructed with valid arguments', ->
      assert.doesNotThrow ->
        new conifer.Store {}

    test 'should throw when constructed with a non-object `configObject` argument', ->
      assert.throws ->
        new conifer.Store
      , ArgumentTypeError

    suite 'instance', ->
      instance = null

      setup ->
        instance = new conifer.Store {}

      test 'should have a `set` method', ->
        assert.isFunction instance.set

      test 'should have a `get` method', ->
        assert.isFunction instance.get

      suite '`set` method', ->

        test 'should not throw when called with valid arguments', ->
          assert.doesNotThrow ->
            instance.set 'foo', 'bar'
          assert.doesNotThrow ->
            instance.set 'foo', []
          assert.doesNotThrow ->
            instance.set 'foo', {}

        test 'should throw when called with a non-string `key` argument', ->
          assert.throws ->
            instance.set {}, 'bar'
          , ArgumentTypeError

        test 'should throw when called with an empty string `key` argument', ->
          assert.throws ->
            instance.set '', 'bar'
          , ArgumentError

        test 'should throw when called with a missing `value` argument', ->
          assert.throws ->
            instance.set 'foo'
          , ArgumentMissingError

      suite '`get` method', ->

        test 'should not throw when called with valid arguments', ->
          assert.doesNotThrow ->
            instance.get 'foo'

        test 'should throw when called with a non-string `key` argument', ->
          assert.throws ->
            instance.get {}
          , ArgumentTypeError

        test 'should throw when called with an empty string `key` argument', ->
          assert.throws ->
            instance.get ''
          , ArgumentError

    suite 'instance with configurations set in the constructor', ->
      instance = null

      setup ->
        instance = new conifer.Store
          foo: 'bar'
          bar: 'baz'

      test '`get` method called with the name of a set configuration should return that configuration value', ->
        assert.strictEqual instance.get('foo'), 'bar'
        assert.strictEqual instance.get('bar'), 'baz'

      test '`get` method called with the name of a configuration which has not been set should return `undefined`', ->
        assert.isUndefined instance.get('baz')

    suite 'instance with configurations set using the `set` method', ->
      instance = null

      setup ->
        instance = new conifer.Store {}
        instance.set 'foo', 'bar'
        instance.set 'bar', 'baz'

      test '`get` method called with the name of a set configuration should return that configuration value', ->
        assert.strictEqual instance.get('foo'), 'bar'
        assert.strictEqual instance.get('bar'), 'baz'

      test '`get` method called with the name of a configuration which has not been set should return `undefined`', ->
        assert.isUndefined instance.get('baz')


  suite '`removeFileHandler` function', ->

    test 'should not throw when called with valid arguments', ->
      assert.doesNotThrow ->
        conifer.removeFileHandler 'foo'

    test 'should throw when called with a non-string `fileExtension` argument', ->
      assert.throws ->
        conifer.removeFileHandler {}
      , ArgumentTypeError

    test 'should throw when called with an empty string `fileExtension` argument', ->
      assert.throws ->
        conifer.removeFileHandler ''
      , ArgumentError


  suite '`setFileHandler` function', ->

    test 'should not throw when called with valid arguments', ->
      assert.doesNotThrow ->
        conifer.setFileHandler 'foo', ->

    test 'should throw when called with a non-string `fileExtension` argument', ->
      assert.throws ->
        conifer.setFileHandler {}, ->
      , ArgumentTypeError

    test 'should throw when called with an empty string `fileExtension` argument', ->
      assert.throws ->
        conifer.setFileHandler '', ->
      , ArgumentError

    test 'should throw when called with a non-function `callback` argument', ->
      assert.throws ->
        conifer.setFileHandler 'foo', {}
      , ArgumentTypeError


  suite '`getFileHandler` function', ->

    test 'should not throw when called with valid arguments', ->
      assert.doesNotThrow ->
        conifer.getFileHandler 'foo'

    test 'should throw when called with a non-string `fileExtension` argument', ->
      assert.throws ->
        conifer.getFileHandler {}
      , ArgumentTypeError

    test 'should throw when called with an empty string `fileExtension` argument', ->
      assert.throws ->
        conifer.getFileHandler ''
      , ArgumentError


  suite '`HandlerNotFoundError` class', ->

    suite 'instance with no message set', ->
      instance = null

      setup ->
        instance = new conifer.HandlerNotFoundError

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
        instance = new conifer.HandlerNotFoundError 'foo'

      teardown ->
        instance = null

      test 'message property should be a string', ->
        assert.isString instance.message

      test 'message property should be equal to the message argument passed into the constructor', ->
        assert.strictEqual instance.message, 'foo'


  suite 'File handlers', ->
    fileExtension = 'foo'
    fileHandler = -> 'baz'

    teardown ->
      conifer.removeFileHandler fileExtension

    suite 'File handler added', ->

      setup ->
        conifer.setFileHandler fileExtension, fileHandler

      test '`getFileHandler` should return the requested handler if present', ->
        assert.strictEqual conifer.getFileHandler(fileExtension), fileHandler

      test '`getFileHandler` should return the requested handler regardless of the case of the file extension', ->
        assert.strictEqual conifer.getFileHandler(fileExtension.toUpperCase()), fileHandler

      test '`getFileHandler` should return `undefined` if the requested handler isn\'t present', ->
        assert.isUndefined conifer.getFileHandler('bar')

    suite 'File handler added then overwritten', ->
      fileHandlerOverride = -> 'qux'

      setup ->
        conifer.setFileHandler fileExtension, fileHandler
        conifer.setFileHandler fileExtension, fileHandlerOverride

      test '`getFileHandler` should return the override handler', ->
        assert.strictEqual conifer.getFileHandler(fileExtension), fileHandlerOverride

    suite 'File handler added then removed', ->

      setup ->
        conifer.setFileHandler fileExtension, fileHandler
        conifer.removeFileHandler fileExtension

      test '`getFileHandler` should return `undefined` when the handler is requested', ->
        assert.isUndefined conifer.getFileHandler(fileExtension)


  suite 'Default file handlers', ->

    test '\'cson\' handler should be registered', ->
      assert.isFunction conifer.getFileHandler('cson')

    test '\'json\' handler should be registered', ->
      assert.isFunction conifer.getFileHandler('json')

    suite '\'cson\' handler', ->
      handler = conifer.getFileHandler 'cson'

      test 'should not throw when called with valid arguments', ->
        assert.doesNotThrow ->
          handler '{}'

      test 'should throw when called with a non-string `fileContent` argument', ->
        assert.throws ->
          handler {}
        , ArgumentTypeError

      test 'should not throw when called with an empty string `fileContent` argument', ->
        assert.doesNotThrow ->
          handler ''

      test 'should throw when called with an invalid CSON string `fileContent` argument', ->
        assert.throws ->
          handler '{hello:}'
        , SyntaxError

      test 'should return the expected parsed object when called with a valid CSON string', ->
        assert.deepEqual handler('foo: "bar", bar: true'), {foo: 'bar', bar: true}

    suite '\'json\' handler', ->
      handler = conifer.getFileHandler 'json'

      test 'should not throw when called with valid arguments', ->
        assert.doesNotThrow ->
          handler '{}'

      test 'should throw when called with a non-string `fileContent` argument', ->
        assert.throws ->
          handler {}
        , ArgumentTypeError

      test 'should not throw when called with an empty string `fileContent` argument', ->
        assert.doesNotThrow ->
          handler ''

      test 'should throw when called with an invalid JSON string `fileContent` argument', ->
        assert.throws ->
          handler '{hello:}'
        , SyntaxError

      test 'should return the expected parsed object when called with a valid JSON string', ->
        assert.deepEqual handler('{"foo": "bar", "bar": true}'), {foo: 'bar', bar: true}


  suite '`parse` function', ->

    test 'should not throw when called with valid arguments', ->
      assert.doesNotThrow ->
        conifer.parse fixtureFile.file001, ->

    test 'should throw when called with a non-string `filePath` argument', ->
      assert.throws ->
        conifer.parse {}, ->
      , ArgumentTypeError

    test 'should throw when called with an empty string `filePath` argument', ->
      assert.throws ->
        conifer.parse '', ->
      , ArgumentError

    test 'should throw when called with a non-function `callback` argument', ->
      assert.throws ->
        conifer.parse fixtureFile.file001, {}
      , ArgumentTypeError

    suite 'call with a `filePath` argument which doesn\'t resolve to a file', ->
      callback = null

      setup (done) ->
        callback = spy(-> done())
        conifer.parse 'foo', callback

      test 'should call the callback', ->
        assert.isTrue callback.called

      test 'should call the callback with a `null` first argument', ->
        assert.isNull callback.getCall(0).args[0]

      test 'should call the callback with a `FileNotFoundError` second argument', ->
        assert.instanceOf callback.getCall(0).args[1], FileNotFoundError

    suite 'call with a `filePath` argument which resolves to a valid JSON file', ->
      callback = handler = oldHandler = store = null

      setup (done) ->
        callback = spy (cbStore, cbError) ->
          store = cbStore
          done()
        oldHandler = conifer.getFileHandler 'json'
        handler = spy(oldHandler)
        conifer.setFileHandler 'json', handler
        conifer.parse fixtureFile.file001, callback

      teardown ->
        conifer.setFileHandler 'json', oldHandler

      test 'should call the callback', ->
        assert.isTrue callback.called

      test 'should call the callback with a `Store` instance first argument', ->
        assert.instanceOf callback.getCall(0).args[0], conifer.Store

      test 'should call the callback with a `null` second argument', ->
        assert.isNull callback.getCall(0).args[1]

      test 'should call the expected handler', ->
        assert.isTrue handler.called

      test 'should call the handler with the contents of the file as a first argument', ->
        assert.strictEqual handler.getCall(0).args[0], fs.readFileSync(fixtureFile.file001, 'utf8')

      test 'Store in callback should have the expected configurations set', ->
        assert.strictEqual store.get('foo'), 'bar'
        assert.isUndefined store.get('bar')

    suite 'call with a `filePath` argument which resolves to an invalid JSON file', ->
      callback = null

      setup (done) ->
        callback = spy(-> done())
        conifer.parse fixtureFile.file002, callback

      test 'should call the callback', ->
        assert.isTrue callback.called

      test 'should call the callback with a `null` first argument', ->
        assert.isNull callback.getCall(0).args[0]

      test 'should call the callback with a `SyntaxError` second argument', ->
        assert.instanceOf callback.getCall(0).args[1], SyntaxError

    suite 'call with a `filePath` argument which resolves to a file which has no handler registered', ->
      callback = null

      setup (done) ->
        callback = spy(-> done())
        conifer.parse fixtureFile.file003, callback

      test 'should call the callback', ->
        assert.isTrue callback.called

      test 'should call the callback with a `null` first argument', ->
        assert.isNull callback.getCall(0).args[0]

      test 'should call the callback with a `HandlerNotFoundError` error second argument', ->
        assert.instanceOf callback.getCall(0).args[1], conifer.HandlerNotFoundError


  suite '`parseSync` function', ->

    test 'should not throw when called with valid arguments', ->
      assert.doesNotThrow ->
        conifer.parseSync fixtureFile.file001

    test 'should throw when called with a non-string `filePath` argument', ->
      assert.throws ->
        conifer.parseSync {}
      , ArgumentTypeError

    test 'should throw when called with an empty string `filePath` argument', ->
      assert.throws ->
        conifer.parseSync ''
      , ArgumentError

    test 'should throw when called with a `filePath` argument which doesn\'t resolve to a file', ->
      assert.throws ->
        conifer.parseSync 'foo'
      , FileNotFoundError

    test 'should throw when called with a `filePath` argument which resolves to an invalid JSON file', ->
      assert.throws ->
        conifer.parseSync fixtureFile.file002
      , SyntaxError

    test 'should throw when called with a `filePath` argument which resolves to a file which has no handler registered', ->
      assert.throws ->
        conifer.parseSync fixtureFile.file003
      , conifer.HandlerNotFoundError
    
    suite 'call with a `filePath` argument which resolves to a valid JSON file', ->
      handler = oldHandler = store = null

      setup ->
        oldHandler = conifer.getFileHandler 'json'
        handler = spy(oldHandler)
        conifer.setFileHandler 'json', handler
        store = conifer.parseSync fixtureFile.file001

      teardown ->
        conifer.setFileHandler 'json', oldHandler

      test 'should call the expected handler', ->
        assert.isTrue handler.called

      test 'should call the handler with the contents of the file as a first argument', ->
        assert.strictEqual handler.getCall(0).args[0], fs.readFileSync(fixtureFile.file001, 'utf8')

      test 'returned Store should have the expected configurations set', ->
        assert.strictEqual store.get('foo'), 'bar'
        assert.isUndefined store.get('bar')
