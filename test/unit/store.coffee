
# Dependencies
{assert} = require 'chai'
{ArgumentError, ArgumentMissingError, ArgumentTypeError, BadConstructionError} = require 'er'
{spy} = require 'sinon'


# Tests
suite 'store module', ->
  store = require '../../src/store'

  test 'should be an object', ->
    assert.isObject store

  test 'should have an `Store` class', ->
    assert.isFunction store.Store


  suite '`Store` class', ->
    Store = store.Store

    test 'should throw when called without the `new` keyword', ->
      assert.throws ->
        Store()
      , BadConstructionError

    test 'should not throw when constructed with valid arguments', ->
      assert.doesNotThrow ->
        new Store {}

    test 'should throw when constructed with a non-object `configObject` argument', ->
      assert.throws ->
        new Store
      , ArgumentTypeError

    suite 'instance', ->
      instance = null

      setup ->
        instance = new Store {}

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
        instance = new Store
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
        instance = new Store {}
        instance.set 'foo', 'bar'
        instance.set 'bar', 'baz'

      test '`get` method called with the name of a set configuration should return that configuration value', ->
        assert.strictEqual instance.get('foo'), 'bar'
        assert.strictEqual instance.get('bar'), 'baz'

      test '`get` method called with the name of a configuration which has not been set should return `undefined`', ->
        assert.isUndefined instance.get('baz')
