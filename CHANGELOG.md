# Changelog

#### v0.5.0

- added `Mediator.send` method
- added `Mediator.pipe` method
- check Sandbox type in Core constructor

#### v0.4.4 (07-2014)

- fixed i18n plugin (not it works with the submodule plugin and a global dict)
- added i18n plugin option `global`

#### v0.4.3 (02-2014)

- added option to `Mediator.installTo` to force overriding existing properties
- added option `useGlobalMediator` to the submodule plugin
- added option `mediator` to the submodule plugin
- added submodule example
- fixed requireJS example
- fixed grunt task for custom builds
- strophe plugin
    - expose the mediator
    - fixed error emitting on failed connection
- compile with coffee-script 1.7.1

#### v0.4.2 (10-2013)

- fixed restarting modules
- speed up argument extraction
- little refactoring

#### v0.4.1 (09-2013)

- no more sandbox manipulation
- added start option to use a separate sandbox
- removed modules directory
  (building modules is your own business;
  above all they should depend on YOUR sandbox)
- available at [cdnjs.com](http://cdnjs.com/)
- improved README
- bugfixes

#### v0.4.0 (07-2013)

- added a `Core` class that can be instantiated (`var core = new scaleApp.Core();`)
- new plugin API (`scaleApp.plugins.register` moved to `core.use`)
    - support asynchronous plugins
    - added `boot` method to initialize asynchronous plugins
- changed API
    - `startAll()` is now `start()`
    - `stopAll()` is now `stop()`
    - the API is now chainable (e.g. `core.use(X).register("foo",bar).start("foo")`)
    - removed `setInstanceOptions`
    - removed `unregister` and `unregisterAll`
    - dropped `subscribe`, `unsubscribe` and `publish` from Mediator API
      (use `on`, `off` and `emit` instead)
    - the methods `lsModules`, `lsInstances`, `lsPlugins` moved to the `ls` plugin
    - the `destroy` method of a module is now optional
    - the `callback` property of the start option object was removed.
      Use the `modulestate` plugin instead
- plugins
    - new `submodule` plugin
    - improved `permission` and `i18n`
    - new `modulestate` plugin to emit events on module state changes
- cleaner code
- `Mediator`: do not *clone* objects any more (do it manually instead)
- test with mocha, chai, sinon, karma and PhantomJS instead of buster.js

#### v0.3.9 (12-2012)

- grunt as build systemt
- added waterfall flow control method
- improved permission plugin
- improved state plugin (thanks to Strathausen)
- added xmpp (stropje.js) plugin
- added a simple clock module
- added [bower](http://twitter.github.com/bower/) support
- added this changelog

#### v0.3.8 (08-2012)

- bug fixes
- added support for async. callback of the `publish` method
- added amd support

#### v0.3.7 (07-2012)

- bug fixes
- added permission plugin
- ported specs to buster.js
- support for global i18n properties

#### v0.3.6 (03-2012)

- support for async. and sync. module initialization

#### v0.3.5 (03-2012)

- simpified Mediator code

#### v0.3.4 (03-2012)

- bugfixes
- added `lsModules` and `lsInstances`
- improved README

#### v0.3.3 (02-2012)

- run tests with jasmine-node instead of JSTestDriver
- added travis testing
- improved README

#### v0.3.2 (01-2012)

- bugfixes
- improved Mediator

#### v0.3.0 (11-2011)

- ported to Coffee-Script
- removed jQuery dependency

#### v0.2.0 (07-2011)

- bugfixes
- improvements

#### v0.1.0 (02-2011)

 - first release
