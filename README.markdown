# What is scaleApp?

scaleApp is a tiny JavaScript framework for scalable
[One-Page-Applications / Single-Page-Applications](http://en.wikipedia.org/wiki/Single-page_application).
The framework allows you to easily create complex web applications.

[![Build Status](https://secure.travis-ci.org/flosse/scaleApp.png)](http://travis-ci.org/flosse/scaleApp)

You can dynamically start and stop/destroy modules that acts as small parts of
your whole application.

## Architecture overview

scaleApp is based on a decoupled, event-driven architecture that is inspired by
the talk of Nicholas C. Zakas -
["Scalable JavaScript Application Architecture"](https://www.youtube.com/watch?v=vXjVFPosQHw)
([Slides](http://www.slideshare.net/nzakas/scalable-javascript-application-architecture)).
There also is a little [Article](http://www.ubelly.com/2011/11/scalablejs/) that
describes the basic ideas.

![scaleApp architecture](https://raw.github.com/flosse/scaleApp/master/architecture.png)

### Module

A module is a completely independent part of your application.
It has absolutely no reference to another piece of the app.
The only thing the module knows is the sandbox.
The sandbox is used to communicate with other parts of the application.

### Sandbox

The main purpose of the sandbox is to use the
[facade pattern](https://en.wikipedia.org/wiki/Facade_pattern).
In that way you can hide the features provided by the core and only show
a well defined (static) API to your modules.
For each module a separate sandbox will be created.

### Core

The core is responsible for starting and stopping your modules.
It also handles the messages by using the
[Publish/Subscribe (Mediator) pattern](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern)

### Plugin

Plugins can extend the core or the sandbox with additional features.
For example you could extend the core with basic functionalities
(like DOM manipulation) or just aliases the features of a base library (e.g. jQuery).

## Features

+ loose coupling of modules
+ small (about 300 sloc / 9k min / 3.5k gz)
+ no dependencies
+ modules can be tested separately
+ replacing any module without affecting other modules
+ extendable with plugins
+ browser and node.js support
+ flow control

### Extendable

scaleApp itself is very small but it can be extended with plugins. There already
are some plugins available:

- `mvc` - simple MVC
- `i18n` - multi language UIs
- `permission` - take care of method access
- `state` - Finite State Machine
- `submodule` - cascade modules
- `dom` - DOM manipulation
- `strophe` - XMPP communication

You can easily define your own plugin (see plugin section).

# Download

## Latest stable 0.4.x version

- not available yet

## Latest stable 0.3.x version

- [scaleApp 0.3.9.tar.gz](https://github.com/flosse/scaleApp/tarball/v0.3.9)
- [scaleApp 0.3.9.zip](https://github.com/flosse/scaleApp/zipball/v0.3.9)

## Unstable version

- [scaleApp-master.zip](https://github.com/flosse/scaleApp/archive/master.zip)

```shell
git clone git://github.com/flosse/scaleApp.git
```

# Changes in 0.4.x

There are some little API changes in version 0.4.x.
Therefore the Github docs (master branch) are not compatible to v0.3.9.

# Quick Start

Link `scaleApp.min.js` in your HTML file:

```html
<script src="scaleApp.min.js"></script>
```

If you're going to use it with node:

```shell
npm install scaleapp --save
```

```javascript
var sa = require("scaleapp");
```

or use [bower](http://twitter.github.com/bower/):

    bower install scaleapp

## Create a core

First of all create a new core instance:

```javascript
var core = new scaleApp.Core();
```

## Register modules

```javascript
core.register( "myModuleId", function( sandbox ){
  return {
    init:    function(){ /*...*/ },
    destroy: function(){ /*...*/ }
  };
});
```

As you can see the module is a function that takes the sandbox as a parameter
and returns an object that has two functions `init` and `destroy`.
Of course your module can be any usual class with those two functions.

```javascript
var MyGreatModule = function(sandbox){
  return {
    init:    function(){ alert("Hello world!"); }
    destroy: function(){ alert("Bye bye!");     }
  };
};

core.register("myGreatModule", MyGreatModule);
```

The `init` function is called by the framework when the module is supposed to
start. The `destroy` function is called when the module has to shut down.


## Asynchronous initialization

You can also init or destroy you module in a asynchronous way:

```javascript
var MyAsyncModule = function(sandbox){
  return {
    init: function(options, done){
      doSomethingAsync(function(err){
        // ...
        done(err);
      });
    },
    destroy: function(done){
      doSomethingElseAsync(done);
    }
  };
};

core.register("myGreatModule", MyGreatModule);
core.start("myGreatModule", { callback:function(){
  alert("now the initialization is done");
}});
```

## Unregister modules

It's simple:

```javascript
core.unregister("myGreatModule");
```

## Start modules

After your modules are registered, start your modules:

```javascript
core.start( "myModuleId" );
core.start( "anOtherModule" );
```

### Start options

You may also want to start several instances of a module:

```javascript
core.start( "myModuleId", {instanceId: "myInstanceId" } );
core.start( "myModuleId", {instanceId: "anOtherInstanceId" });
```

If you pass a callback function it will be called after the module started:

```javascript
core.start( "myModuleId", {
  callback:   function(){ /*...*/ },
  instanceId: "foo"
);
```

or if the callback is your only parameter:

```javascript
core.start( "myModuleId",function(){ /*...*/ });
```

All you attach to `options` is accessible within your module:

```javascript
core.register( "mod", function(sandbox){
  return {
    init: function(opt){
      (opt === sandbox.options)            // true
      (opt.myProperty === "myValue")  // true
    },
    destroy: function(){ /*...*/ }
  };
});

core.start("mod", {
  instanceId: "test",
  options: { myProperty: "myValue" }
});
```

If all your modules just needs to be instanciated once, you can simply starting
them all:

```javascript
core.startAll();
```

To start some special modules at once you can pass an array with the module
names:

```javascript
core.startAll(["moduleA","moduleB"]);
```

You can also pass a callback function:

```javascript
core.startAll(function(){
  // do something when all modules were initialized
});
```

## Stopping

It's obvious:

```javascript
core.stop("moduleB");
core.stopAll();
```

## Publish/Subscribe

If the module needs to communicate with others, you can use the `emit` and
`on` methods.

### emit

The `emit` function takes three parameters whereas the last one is optional:
- `topic` : the channel name you want to emit to
- `data`  : the data itself
- `cb`    : callback method

The emit function is accessible through the sandbox:

```javascript
sandbox.emit( "myEventTopic", myData );
```

You can also use the shorter method alias `emit`.

### on

A message handler could look like this:

```javascript
var messageHandler = function( data, topic ){
  switch( topic ){
    case "somethingHappend":
      sandbox.emit( "myEventTopic", processData(data) );
      break;
    case "aNiceTopic":
      justProcess( data );
      break;
  }
};
```

... and it can listen to one or more channels:

```javascript
sub1 = sandbox.on( "somthingHappend", messageHandler );
sub2 = sandbox.on( "aNiceTopic", messageHandler );
```
Or just do it at once:

```javascript
sandbox.on({
  topicA: cbA,
  topicB: cbB,
  topicC: cbC
});
```

You can also subscribe to several channels at once:

```javascript
sandbox.on(["a", "b"], cb);
```

If you prefer a shorter method name you can use the alias `on`.

#### attache and detache

A subscription can be detached and attached again:

```javascript
sub.detach(); // don't listen any more
sub.attach(); // receive upcoming messages
```

#### Unsubscribe

You can unsubscribe a function from a channel

```javascript
sandbox.off("a-channel", callback);
```

And you can remove a callback function from all channels

```javascript
sandbox.off(callback);
```

Or remove all subscriptions from a channel:

```javascript
sandbox.off("channelName");
```

## Flow control

### Series
```javascript
var task1 = function(next){
  setTimeout(function(){next(null, "one");},0);
};

var task2 = function(next){
  next(null, "two");
};

scaleApp.util.runSeries([task1, task2], function(err, results){
  // result is ["one", "two"]
});
```

### Waterfall

```javascript
var task1 = function(next){
  setTimeout(function(){
    next(null, "one", "two");
  },0);
};

var task2 = function(res1, res2, next){
  // res1 is "one"
  // res2 is "two"
  next(null, "yeah!");
};

scaleApp.util.runWaterfall([task1, task2], function(err, result){
  // result is "yeah!"
});

```

# API

## scaleApp

- `scaleApp.VERSION` - the current version of scaleApp
- `scaleApp.Mediator` - the Mediator class
- `scaleApp.Sandbox` - the Sandbox class
- `scaleApp.Core` - the Core class

## Core

```javascript
// use default sandbox
var core = new scaleApp.Core();

// use your own sandbox
var core = new scaleApp.Core(yourSandbox);
```

- `core.register(moduleName, module, options)` - register a module
- `core.use(plugin, options)` - register a plugin
- `core.boot(callback)` - initialize plugins
   (will be executed automatically on ´start´)
- `core.start(moduleId, options, callback)` - start a module
- `core.stop(instanceId, callback)` - stop a module

## Mediator

```javascript
// create a mediator
var mediator = scaleApp.Mediator();

// create a mediator with a custom context object
var mediator = scaleApp.Mediator(context);
```

- `mediator.emit(channel, data, callback)`
- `mediator.on(channel, callback, context)`
- `mediator.off(channel, callback)`
- `mediator.installTo(context)`

```javascript
// subscribe
var subscription = mediator.on(channel, callback, context);
```
- `subscription.detach` - stop listening
- `subscription.attach` - resume listening

## Sandbox

```javascript
var sandbox =  new scaleApp.Sandbox(core, instanceId, options)` - create a Sandbox
```
- `sandbox.emit` is `mediator.emit`
- `sandbox.on` is `mediator.on`
- `sandbox.off` is `mediator.off`

# Changelog

#### v0.4.0 (??-2013)

- added a `Core` class that can be instantiated (`var core = new scaleApp.Core();`)
- cleaner code
- changed API
- new plugin API (`scaleApp.plugins.register` moved to `core.use`)
- the API is now chainable
- support asynchronous plugins
- added `boot` method to initialize asynchronous plugins
- removed `setInstanceOptions`
- removed `unregister` and `unregisterAll`
- the methods `lsModules`, `lsInstances`, `lsPlugins` moved to the `ls` plugin
- `Mediator`: do not *clone* objects any more (do it manually instead)
- drop `subscribe`, `unsubscribe`, `publish` from Mediator API
  (use `on`, `off` and `emit` instead)
- new `submodule` plugin
- new `modulestate` plugin to emit events on module state changes
- improved permission and i18n plugins

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

# Testing

```shell
npm test
```

# Demo

**WARNING**: the demo is totally out of date!

You can try out the [sample application](http://www.scaleapp.org/demo/fast/)
that is build on [scaleApp](http://www.scaleapp.org).
Also have a look at the [source code](http://github.com/flosse/FAST).

# Licence

scaleApp is licensed under the MIT license.
For more information have a look at
[LICENCE.txt](https://raw.github.com/flosse/scaleApp/master/LICENCE.txt).
