
Conifer Roadmap
===============


Support other formats
---------------------

It'd be good to maybe add a few more formats, potentially as
plugins. Ideas (feel free to add):

 * INI

Also, I may split everything except JSON out of the core and
into plugins.


Property Replacement
--------------------

I may consider at some point adding the ability to insert the
values of configurations in other configurations. Something like
this:

```json
{
    "name": "Hello World!",
    "version": "1.2.3",
    "author": {
        "name": "Foo Bar",
        "email": "foo@bar.com"
    },
    "description": "{{name}} is an app which is currently at version {{version}}. It was written by {{author.name}}."
}
```

which would turn into this:

```json
{
    "name": "Hello World!",
    "version": "1.2.3",
    "author": {
        "name": "Foo Bar",
        "email": "foo@bar.com"
    },
    "description": "Hello World! is an app which is currently at version 1.2.3. It was written by Foo Bar."
}
```
