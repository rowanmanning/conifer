
# Dependencies
{assert} = require 'chai'
{ArgumentError, ArgumentMissingError, ArgumentTypeError, FileNotFoundError} = require 'er'
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

  test 'should have a `handler` namespace', ->
    assert.isObject conifer.handler

  test 'should have a `parse` function', ->
    assert.isFunction conifer.parse

  test 'should have a `parseSync` function', ->
    assert.isFunction conifer.parseSync


  suite '`Store` class', ->

    test 'should alias the `Store` class in the `store` module', ->
      assert.strictEqual conifer.Store, require('../../src/store').Store


  suite '`handler` namespace', ->
    
    test 'should alias the `handler` module', ->
      assert.strictEqual conifer.handler, require('../../src/handler')


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
        oldHandler = conifer.handler.getHandler 'json'
        handler = spy(oldHandler)
        conifer.handler.setHandler 'json', handler
        conifer.parse fixtureFile.file001, callback

      teardown ->
        conifer.handler.setHandler 'json', oldHandler

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
        assert.instanceOf callback.getCall(0).args[1], conifer.handler.HandlerNotFoundError


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
      , conifer.handler.HandlerNotFoundError
    
    suite 'call with a `filePath` argument which resolves to a valid JSON file', ->
      handler = oldHandler = store = null

      setup ->
        oldHandler = conifer.handler.getHandler 'json'
        handler = spy(oldHandler)
        conifer.handler.setHandler 'json', handler
        store = conifer.parseSync fixtureFile.file001

      teardown ->
        conifer.handler.setHandler 'json', oldHandler

      test 'should call the expected handler', ->
        assert.isTrue handler.called

      test 'should call the handler with the contents of the file as a first argument', ->
        assert.strictEqual handler.getCall(0).args[0], fs.readFileSync(fixtureFile.file001, 'utf8')

      test 'returned Store should have the expected configurations set', ->
        assert.strictEqual store.get('foo'), 'bar'
        assert.isUndefined store.get('bar')
