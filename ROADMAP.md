
Conifer Roadmap
===============


Support other formats
---------------------

It'd be good to add a few more formats. Ideas
(feel free to add):

 * YAML
 * INI


Imports
-------

I'd like to allow config files to include other config files.
This is what I'm thinking right now:

```json
{
    "routes": "<< ./routes.json",
    "<<": [
        "./other-config.json",
        "./other-config.cson"
    ]
}
```

In the example above, the contents of `routes.json` would be
parsed and set as the `routes` property in the current config
file. The `other-config.*` files would be merged into the base
object of the current config file.

Idea and syntax subject to change. Thoughts?
