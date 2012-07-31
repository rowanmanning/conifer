
Conifer
=======

A multi-format, file-based configuration library for Node. It
stream-lines reading and parsing configurations from JSON or
CSON files, with support for adding your own file-type handlers.

This project is simple right now, but there are some fun
features planned for a [future release][roadmap].


Basic Usage
-----------

You can use Conifer with JavaScript or CoffeeScript:

```js
var conifer = require('conifer');
```

```coffeescript
conifer = require 'conifer'
```

In the examples below, it's assumed that you've required
Conifer as above.

---

### conifer.parse

This function parses a config file asynchronously. It accepts
two arguments – a file path and a callback function. The file
path must be an unempty string and the callback should accept
two arguments itself: the parsed config store, and an error
object.

```js
conifer.parse('example.json', function (store, err) {
    if (err !== null) {
        throw err;
    }
    // do something with `store`
});
```

In the callback, `store` will be either a
[`conifer.Store`](#coniferstore) instance on success or `null`.
`err` will be `null` on success, or an Error object on failure.

---

### conifer.parseSync

This function parses a config file synchronously. It accepts
a single argument – a file path. The file path must be an
unempty string. This function returns a
[`conifer.Store`](#coniferstore) instance on success, and
throws if parsing fails.

```js
store = conifer.parseSync('example.json');
```

---

### conifer.Store

This is the class which is instantiated in parsing, and holds
parsed configurations. The constructor for this class accepts a
simple object of key/value pairs.

#### get method

The get method accepts a single argument, the name of the
configuration to get, and returns the requested configuration
(or undefined if it's not set).

```js
var config = new conifer.Store({foo: 'bar'});
var foo = config.get('foo'); // bar
```

#### set method

The set method accepts a two arguments, the name of the
configuration to set and the value to set it to.

```js
var config = new conifer.Store({});
config.set('foo', 'bar');
var foo = config.get('foo'); // bar
```


Development
-----------

In order to develop Conifer, you'll need to install the
following npm modules globally like so:

    npm install -g coffee-script
    npm install -g jake

And then install development dependencies locally with:

    npm install

Once you have these dependencies, you will be able to run the
following commands:

`jake build`: Build JavaScript from the CoffeeScript source.

`jake lint`: Run CoffeeLint on the CoffeeScript source.

`jake test`: Run all unit tests.


License
-------

Dual licensed under the [MIT][mit] or [GPL Version 2][gpl]
licenses.


[gpl]: http://opensource.org/licenses/gpl-2.0.php
[mit]: http://opensource.org/licenses/mit-license.php
[roadmap]: https://github.com/rowanmanning/conifer/blob/master/ROADMAP.md
