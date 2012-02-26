# scaleApp
scaleApp is a tiny JavaScript framework for scalable One-Page-Applications.
The framework allows you to easily create complex web applications.

## Demo

You can try out the [sample application](http://www.scaleapp.org/demo/fast/)
that is build on [scaleApp](http://www.scaleapp.org).
Also have a look at the [source code](http://github.com/flosse/FAST).


## Plugins

- mvc - simple MVC classes
- dom - plugin for DOM manipulations (currently only used for `getContainer`)
- util - collection of helper functions
- i18n - plugin for multi language support

## Usage

see [documentation](http://www.scaleapp.org/tutorial) on
[scaleapp.org](http://www.scaleapp.org).

## Testing

[jasmine-node](https://github.com/mhevery/jasmine-node)
is required (`npm install -g jasmine-node`) for running the tests.

```shell
jasmine-node --coffee spec/
```

## Licence

scaleApp is licensed under the MIT license.
For more information have a look at LICENCE.txt.
