
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
  file004: __dirname + '/../fixture/config.004.json'
  file005: __dirname + '/../fixture/config.005.json'
  file006: __dirname + '/../fixture/config.006.json'
  file007: __dirname + '/../fixture/config.007.json'
  import001: __dirname + '/../fixture/import/import.001.json'
  import002: __dirname + '/../fixture/import/import.002.json'


# Tests
suite 'conifer module', ->
  conifer = require '../../src/conifer'

  test 'should be an object', ->
    assert.isObject conifer

  test 'should have a `Store` class', ->
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

      test 'should call the callback with a `FileNotFoundError` first argument', ->
        assert.instanceOf callback.getCall(0).args[0], FileNotFoundError

      test 'should call the callback with a `null` second argument', ->
        assert.isNull callback.getCall(0).args[1]

    suite 'call with a `filePath` argument which resolves to a valid JSON file', ->
      callback = handler = oldHandler = store = null

      setup (done) ->
        callback = spy (cbError, cbStore) ->
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

      test 'should call the callback with a `null` first argument', ->
        assert.isNull callback.getCall(0).args[0]

      test 'should call the callback with a `Store` instance second argument', ->
        assert.instanceOf callback.getCall(0).args[1], conifer.Store

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

      test 'should call the callback with a `SyntaxError` first argument', ->
        assert.instanceOf callback.getCall(0).args[0], SyntaxError

      test 'should call the callback with a `null` second argument', ->
        assert.isNull callback.getCall(0).args[1]

    suite 'call with a `filePath` argument which resolves to a file which has no handler registered', ->
      callback = null

      setup (done) ->
        callback = spy(-> done())
        conifer.parse fixtureFile.file003, callback

      test 'should call the callback', ->
        assert.isTrue callback.called

      test 'should call the callback with a `HandlerNotFoundError` error first argument', ->
        assert.instanceOf callback.getCall(0).args[0], conifer.handler.HandlerNotFoundError

      test 'should call the callback with a `null` second argument', ->
        assert.isNull callback.getCall(0).args[1]

    suite 'call with a `filePath` argument which has valid import merge properties', ->
      callback = handler = oldHandler = store = null

      setup (done) ->
        callback = spy (cbError, cbStore) ->
          store = cbStore
          done()
        oldHandler = conifer.handler.getHandler 'json'
        handler = spy(oldHandler)
        conifer.handler.setHandler 'json', handler
        conifer.parse fixtureFile.file004, callback

      teardown ->
        conifer.handler.setHandler 'json', oldHandler

      test 'should call the expected handler for each file parsed', ->
        assert.strictEqual handler.callCount, 4

      test 'should call the handler with the contents of each imported file', ->
        assert.isTrue handler.calledWith(fs.readFileSync(fixtureFile.file004, 'utf8'))
        assert.isTrue handler.calledWith(fs.readFileSync(fixtureFile.import001, 'utf8'))
        assert.isTrue handler.calledWith(fs.readFileSync(fixtureFile.import002, 'utf8'))
        assert.isTrue handler.calledWith(fs.readFileSync(fixtureFile.import001, 'utf8'))

      test 'Store in callback should not have the import merge properties defined', ->
        assert.isUndefined store.get('<<')
        assert.isUndefined store.get('nest')['<<']

      test 'Store in callback should have the expected configurations set', ->
        assert.strictEqual store.get('foo'), 'bar'
        assert.strictEqual store.get('bar'), 'baz'
        assert.strictEqual store.get('baz'), 'qux'
        assert.strictEqual store.get('nest').bar, 'baz'

    suite 'call with a `filePath` argument which has invalid import merge properties', ->
      callback = handler = oldHandler = store = null

      setup (done) ->
        callback = spy (cbError, cbStore) ->
          store = cbStore
          done()
        oldHandler = conifer.handler.getHandler 'json'
        handler = spy(oldHandler)
        conifer.handler.setHandler 'json', handler
        conifer.parse fixtureFile.file005, callback

      teardown ->
        conifer.handler.setHandler 'json', oldHandler

      test 'should call the expected handler only once', ->
        assert.strictEqual handler.callCount, 1

      test 'returned Store should have the invalid import merge properties still defined', ->
        assert.isDefined store.get('<<')
        assert.isDefined store.get('nest')['<<']
        assert.isDefined store.get('nest2')['<<']

      test 'returned Store should have the expected configurations set', ->
        assert.strictEqual store.get('foo'), 'bar'
        assert.isUndefined store.get('bar')
        assert.isUndefined store.get('baz')
        assert.isUndefined store.get('nest').bar

    suite 'call with a `filePath` argument which has valid import properties', ->
      callback = handler = oldHandler = store = null

      setup (done) ->
        callback = spy (cbError, cbStore) ->
          store = cbStore
          done()
        oldHandler = conifer.handler.getHandler 'json'
        handler = spy(oldHandler)
        conifer.handler.setHandler 'json', handler
        conifer.parse fixtureFile.file006, callback

      teardown ->
        conifer.handler.setHandler 'json', oldHandler

      test 'should call the expected handler for each file parsed', ->
        assert.strictEqual handler.callCount, 3

      test 'should call the handler with the contents of each imported file', ->
        assert.isTrue handler.calledWith(fs.readFileSync(fixtureFile.file006, 'utf8'))
        assert.isTrue handler.calledWith(fs.readFileSync(fixtureFile.import001, 'utf8'))
        assert.isTrue handler.calledWith(fs.readFileSync(fixtureFile.import002, 'utf8'))

      test 'returned Store should have the expected configurations set', ->
        assert.strictEqual store.get('foo'), 'bar'
        assert.strictEqual store.get('bar').bar, 'baz'
        assert.strictEqual store.get('nest').foo.baz, 'qux'

    suite 'call with a `filePath` argument which has invalid import properties', ->
      callback = handler = oldHandler = store = null

      setup (done) ->
        callback = spy (cbError, cbStore) ->
          store = cbStore
          done()
        oldHandler = conifer.handler.getHandler 'json'
        handler = spy(oldHandler)
        conifer.handler.setHandler 'json', handler
        conifer.parse fixtureFile.file007, callback

      teardown ->
        conifer.handler.setHandler 'json', oldHandler

      test 'should call the expected handler only once', ->
        assert.strictEqual handler.callCount, 1

      test 'returned Store should have the expected configurations set', ->
        assert.strictEqual store.get('foo'), 'bar'
        assert.strictEqual store.get('bar'), '<<./import/import.001.json'
        assert.strictEqual store.get('nest').foo, '  <<  ./import/import.002.json'


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

    suite 'call with a `filePath` argument which has valid import merge properties', ->
      handler = oldHandler = store = null

      setup ->
        oldHandler = conifer.handler.getHandler 'json'
        handler = spy(oldHandler)
        conifer.handler.setHandler 'json', handler
        store = conifer.parseSync fixtureFile.file004

      teardown ->
        conifer.handler.setHandler 'json', oldHandler

      test 'should call the expected handler for each file parsed', ->
        assert.strictEqual handler.callCount, 4

      test 'should call the handler with the contents of each imported file', ->
        assert.strictEqual handler.getCall(0).args[0], fs.readFileSync(fixtureFile.file004, 'utf8')
        assert.strictEqual handler.getCall(1).args[0], fs.readFileSync(fixtureFile.import001, 'utf8')
        assert.strictEqual handler.getCall(2).args[0], fs.readFileSync(fixtureFile.import002, 'utf8')
        assert.strictEqual handler.getCall(3).args[0], fs.readFileSync(fixtureFile.import001, 'utf8')

      test 'returned Store should not have the import merge properties defined', ->
        assert.isUndefined store.get('<<')
        assert.isUndefined store.get('nest')['<<']

      test 'returned Store should have the expected configurations set', ->
        assert.strictEqual store.get('foo'), 'bar'
        assert.strictEqual store.get('bar'), 'baz'
        assert.strictEqual store.get('baz'), 'qux'
        assert.strictEqual store.get('nest').bar, 'baz'

    suite 'call with a `filePath` argument which has invalid import merge properties', ->
      handler = oldHandler = store = null

      setup ->
        oldHandler = conifer.handler.getHandler 'json'
        handler = spy(oldHandler)
        conifer.handler.setHandler 'json', handler
        store = conifer.parseSync fixtureFile.file005

      teardown ->
        conifer.handler.setHandler 'json', oldHandler

      test 'should call the expected handler only once', ->
        assert.strictEqual handler.callCount, 1

      test 'returned Store should have the invalid import merge properties still defined', ->
        assert.isDefined store.get('<<')
        assert.isDefined store.get('nest')['<<']
        assert.isDefined store.get('nest2')['<<']

      test 'returned Store should have the expected configurations set', ->
        assert.strictEqual store.get('foo'), 'bar'
        assert.isUndefined store.get('bar')
        assert.isUndefined store.get('baz')
        assert.isUndefined store.get('nest').bar

    suite 'call with a `filePath` argument which has valid import properties', ->
      handler = oldHandler = store = null

      setup ->
        oldHandler = conifer.handler.getHandler 'json'
        handler = spy(oldHandler)
        conifer.handler.setHandler 'json', handler
        store = conifer.parseSync fixtureFile.file006

      teardown ->
        conifer.handler.setHandler 'json', oldHandler

      test 'should call the expected handler for each file parsed', ->
        assert.strictEqual handler.callCount, 3

      test 'should call the handler with the contents of each imported file', ->
        assert.strictEqual handler.getCall(0).args[0], fs.readFileSync(fixtureFile.file006, 'utf8')
        assert.strictEqual handler.getCall(1).args[0], fs.readFileSync(fixtureFile.import001, 'utf8')
        assert.strictEqual handler.getCall(2).args[0], fs.readFileSync(fixtureFile.import002, 'utf8')

      test 'returned Store should have the expected configurations set', ->
        assert.strictEqual store.get('foo'), 'bar'
        assert.strictEqual store.get('bar').bar, 'baz'
        assert.strictEqual store.get('nest').foo.baz, 'qux'

    suite 'call with a `filePath` argument which has invalid import properties', ->
      handler = oldHandler = store = null

      setup ->
        oldHandler = conifer.handler.getHandler 'json'
        handler = spy(oldHandler)
        conifer.handler.setHandler 'json', handler
        store = conifer.parseSync fixtureFile.file007

      teardown ->
        conifer.handler.setHandler 'json', oldHandler

      test 'should call the expected handler only once', ->
        assert.strictEqual handler.callCount, 1

      test 'returned Store should have the expected configurations set', ->
        assert.strictEqual store.get('foo'), 'bar'
        assert.strictEqual store.get('bar'), '<<./import/import.001.json'
        assert.strictEqual store.get('nest').foo, '  <<  ./import/import.002.json'
