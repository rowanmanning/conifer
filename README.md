
Conifer
=======

A multi-format, file-based configuration library for Node. It
streamlines reading and parsing configurations from
[JSON][json], [CSON][cson] and [YAML][yaml] files, with support
for adding your own file-type handlers.

This project is simple right now, but there are some fun
features planned for a [future release][roadmap].

[![Build Status][travis-status]][travis]


Installing
----------

Install Conifer through `npm`. Either with the command:

```sh
npm install conifer
```

or by adding `conifer` to the dependencies in your project
`package.json`.


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
two arguments itself: an error object and the parsed config store.

```js
conifer.parse('example.json', function (err, store) {
    if (err !== null) {
        throw err;
    }
    // do something with `store`
});
```

In the callback, `err` will be `null` on success, or an Error
object on failure. `store` will be either a
[`conifer.Store`](#coniferstore) instance on success or `null`.

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
config.get('foo'); // bar
```

#### set method

The set method accepts a two arguments, the name of the
configuration to set and the value to set it to.

```js
var config = new conifer.Store({});
config.set('foo', 'bar');
config.get('foo'); // bar
```


Configuration Importing
-----------------------

Your config files are able to import other configurations as
properties, or by merging them into the current object. This
allows for a single entry-point for your configuration, as well
as a more managable and reusable set of config files.

Examples below are mostly in JSON but this will work for all
supported file types, as well as allowing for cross-file-type
importing.

### Import Properties

Import properties allow you to import the contents of another
config file into a property. They work on a property whose
(string) value begins with `<< `. So if we have the following
files:

config/main.json:
```json
{
    "name": "Hello World",
    "routes": "<< ./routes.json"
}
```

config/routes.json:
```json
{
    "/": "controller/index",
    "/about": "controller/about",
}
```

Parsing `config/main.json` will result in the following
structure:
```json
{
    "name": "Hello World",
    "routes": {
        "/": "controller/index",
        "/about": "controller/about",
    }
}
```

### Import Merges

Import merges allow you to merge the contents of another config
file into the current object. Merges are indicated by the `<<`
property of an object, which should be set to an array of file
names. If we have the following files:

config/main.json:
```json
{
    "name": "Hello World",
    "outputErrors": true,
    "<<": [
        "./production.json"
    ]
}
```

config/production.json:
```json
{
    "outputErrors": false,
    "logErrors": true
}
```

Parsing `config/main.json` will result in the following
structure:
```json
{
    "name": "Hello World",
    "outputErrors": false,
    "logErrors": true
}
```


Extending With File Handlers
----------------------------

Conifer can be extended to work with almost any configuration
format. It's just a case of writing a handler for that file
type. The handler API is extremely simple:

### conifer.handler.setHandler

This function adds a new handler. It accepts two arguments – a
file extension and a handler function. The handler function
should accept a content string and return a successfully parsed
object or throw an error.

```js
conifer.handler.setHandler('xml', function (fileContent) {
    try {
        return myMagicXmlLib.parse(fileContent);
    } catch (error) {
        throw error;
    }
});
```

With the above code, any call to
[`conifer.parse`](#coniferparse) or
[`conifer.parseSync`](#coniferparsesync) with a file path that
has a `.xml` extension will use the specified handler function
to parse the file content.

---

### conifer.handler.getHandler

This function gets a handler that's been set already. This
function accepts a single argument – the file extension to get
the handler for, and returns the requested function.

```js
conifer.handler.getHandler('json'); // [Function]
```

---

### conifer.handler.removeHandler

This function removes a handler that's been set already. This
function accepts a single argument – the file extension to get
the handler for.

```js
conifer.handler.removeHandler('json');
conifer.handler.getHandler('json'); // undefined
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


[cson]: https://github.com/bevry/cson
[gpl]: http://opensource.org/licenses/gpl-2.0.php
[json]: http://www.json.org/
[mit]: http://opensource.org/licenses/mit-license.php
[roadmap]: https://github.com/rowanmanning/conifer/blob/master/ROADMAP.md
[travis]: https://secure.travis-ci.org/rowanmanning/conifer
[travis-status]: https://secure.travis-ci.org/rowanmanning/conifer.png?branch=master
[yaml]: http://www.yaml.org/
