# What is scaleApp?

scaleApp is a tiny JavaScript framework for scalable and maintainable
[One-Page-Applications / Single-Page-Applications](http://en.wikipedia.org/wiki/Single-page_application).
The framework allows you to easily create complex web applications.

[![Build Status](https://secure.travis-ci.org/flosse/scaleApp.png?branch=master)](http://travis-ci.org/flosse/scaleApp)
[![Dependency Status](https://gemnasium.com/flosse/scaleApp.png?branch=master)](https://gemnasium.com/flosse/scaleApp)
[![NPM version](https://badge.fury.io/js/scaleapp.png)](http://badge.fury.io/js/scaleapp)
[![Coverage Status](https://coveralls.io/repos/flosse/scaleApp/badge.png?branch=master)](https://coveralls.io/r/flosse/scaleApp?branch=master)

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
The only thing the module knows is your sandbox.
The sandbox is used to communicate with other parts of the application.

### Sandbox

The main purpose of the sandbox is to use the
[facade pattern](https://en.wikipedia.org/wiki/Facade_pattern).
In that way you can hide the features provided by the core and only show
a well defined custom static long term API to your modules.
This is actually one of the most important concept for creating
mainainable apps. Change plugins, implementations etc.
but keep your API stable for your modules.
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
+ small (about 300 sloc / 8,7k min / 3.3k gz)
+ no dependencies
+ modules can be tested separately
+ replacing any module without affecting other modules
+ extendable with plugins
+ browser and [Node.js](http://nodejs.org/) support
+ flow control
+ [AMD](https://en.wikipedia.org/wiki/Asynchronous_module_definition) & [CommonJS](http://www.commonjs.org/) support
+ framework-agnostic

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
- `modulestate` - event emitter for `init` and `destroy`
- `util` - helper methods like `mixin`, `uniqueId` etc.
- `ls` - list modules, instances & plugins

You can easily define your own plugin (see plugin section).

# Download

## Latest stable 0.4.x version

- [scaleApp 0.4.3.tar.gz](https://github.com/flosse/scaleApp/tarball/v0.4.3)
- [scaleApp 0.4.3.zip](https://github.com/flosse/scaleApp/zipball/v0.4.3)

or use the [CDN](http://en.wikipedia.org/wiki/Content_delivery_network):

```html
<script src="//cdnjs.cloudflare.com/ajax/libs/scaleapp/0.4.3/scaleapp.min.js" ></script>
```

## Old stable 0.3.x version

- [scaleApp 0.3.9.tar.gz](https://github.com/flosse/scaleApp/tarball/v0.3.9)
- [scaleApp 0.3.9.zip](https://github.com/flosse/scaleApp/zipball/v0.3.9)

### Note

There are some API changes in version 0.4.x (see Changelog).
Docs for v0.3.9 can be found within the tar/zip file.

## Unstable version

- [scaleApp-master.zip](https://github.com/flosse/scaleApp/archive/master.zip)

```shell
git clone git://github.com/flosse/scaleApp.git
```

# Quick Start

Link `scaleApp.min.js` in your HTML file:

```html
<script src="scaleApp.min.js"></script>
```

or use the [CDN](http://en.wikipedia.org/wiki/Content_delivery_network):

```html
<script src="//cdnjs.cloudflare.com/ajax/libs/scaleapp/0.4.0/scaleapp.min.js" ></script>
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

## Create your own Sandbox

First of all create your own sandbox.
By doing that you're able to guarantee a
stable maintainable API for your modules.

```javascript
var MySandbox = function(core, instanceId, options, moduleId) {

  // define your API
  this.myFooProperty = "bar";

  // e.g. provide the Mediator methods 'on', 'emit', etc.
  core._mediator.installTo(this);

  // ... or define your custom communication methods
  this.myEmit = function(channel, data){
    core.emit(channel + '/' + instanceId, data);
  };

  // maybe you'd like to expose the instance ID
  this.id = instanceId;

  return this;
};

// ... and of course you can define shared methods etc.
MySandbox.prototype.foo = function() { /*...*/ };
```

## Create a core

Now create a new core instance with your sandbox:

```javascript
var core = new scaleApp.Core(MySandbox);
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
and returns an object that has two functions `init` and `destroy` (the latter is
optional).
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
core.start("myGreatModule", { done:function(){
  alert("now the initialization is done");
}});
```

## Start modules

After your modules are registered, start your modules:

```javascript
core
  .start( "myModuleId" )
  .start( "anOtherModule", function(err){
    // 'anOtherModule' is running now
  });
```

### Start options

You may also want to start several instances of a module:

```javascript
core.start( "myModuleId", {instanceId: "myInstanceId" } );
core.start( "myModuleId", {instanceId: "anOtherInstanceId" });
```

All you attach to `options` is accessible within your module:

```javascript
core.register( "mod", function(sandbox){
  return {
    init: function(opt){
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
core.start();
```

To start some special modules at once you can pass an array with the module
names:

```javascript
core.start(["moduleA","moduleB"]);
```

You can also pass a callback function:

```javascript
core.start(function(){
  // do something when all modules were initialized
});
```

Moreover you can use a separate sandbox for each instance:

```javascript
var MySandbox = function(){/*...*/};
core.start("module", { sandbox: MySandbox });
```

## Stopping

It's obvious:

```javascript
core.stop("moduleB");
core.stop(); // stops all running instances
```

## Publish/Subscribe

If the module needs to communicate with others, you can use the `emit` and
`on` methods.

### emit

The `emit` function takes three parameters whereas the last one is optional:
- `topic` : the channel name you want to emit to
- `data`  : the data itself
- `cb`    : callback method

The emit function is accessible through the sandbox
(as long as you exposed the Mediator methods of course):

```javascript
sandbox.emit( "myEventTopic", myData );
```

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
  setTimeout(function(){
    console.log("task1");
    next(null, "one");
  },0);
};

var task2 = function(next){
  console.log("task2");
  next(null, "two");
};

scaleApp.util.runSeries([task1, task2], function(err, result){
  // result is ["one", "two"]
});

// console output is:
// "task1"
// "task2"
```

### Parallel

```javascript
var task1 = function(next){
  setTimeout(function(){
    console.log("task1");
    next(null, "a");
  },0);
};

var task2 = function(next){
  console.log("task2");
  next(null, "b");
};

scaleApp.util.runParallel([task1, task2],function(err,result){
  // result is ["a", "b"]
});

// console output is:
// "task2"
// "task1"
```

There is also a little helper tool to run the same async task
again and again in parallel for different values:

```javascript
var vals = ["a","b", "c"];
var worker = function(val, next){
  console.log(val);
  doSomeAsyncValueProcessing(val,function(err,result){
    next(err, result);
  });
};

scaleApp.util.doForAll(args, worker, function(err, res){
  // fini
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

## Plugins

There are some plugins available within the `plugins` folder.
For more information look at the
[plugin README](https://github.com/flosse/scaleApp/blob/master/plugins/README.md).

### Register plugins

A single plugin can be registered with it option object in that way:

```javascript
core.use(plugin,options);
```
If you want to register multiple plugins at once:

```javascript
core.use([
  plugin1,
  plugin2,
  { plugin: plugin3, options: options3 }
]);
```

### Write your own plugin

It's easy:

```javascript
core.use(function(core){
  core.helloWorld = function(){ alert("helloWorld"); };
};
```

Here a more complex example:

```javascript
core.use(function(core, options, done){

  // extend the core
  core.myCoreFunction = function(){ alert("Hello core plugin") };
  core.myBoringProperty = "boring";

  // extend the sandbox class
  core.Sandbox.prototype.myMethod = function(){/*...*/};

  // define a method that gets called when a module starts
  var onModuleInit = function(instanceSandbox, options, done){

    // e.g. define sandbox methods dynamically
    if (options.mySwitch){
      instanceSandbox.appendFoo = function(){
       core.getContainer.append("foo");
      };
    }

    // or load a something asynchronously
    core.myAsyncMethod(function(data){

      // do something...
      // now tell scaleApp that you're done
      done();
    });
  };

  // define a method that gets called when a module stops
  var onModuleDestroy = function(done){
    myCleanUpMethod(function(){
      done()
    });
  };

  // don't forget to return your methods
  return {
    init: onModuleInit,
    destroy: onModuleDestroy
  };

});
```

Usage:

```javascript
core.myCoreFunction() // alerts "Hello core plugin"

var MyModule = function(sandbox){
  init: function(){ sandbox.appendFoo(); },  // appends "foo" to the container
};
```

# Build browser bundles

If you want scaleApp bundled with special plugins type

```shell
grunt custom[:PLUGIN_NAME]
```
e.g. `cake custom:dom:mvc` creates the file `scaleApp.custom.js` that
contains scaleApp itself the dom plugin and the mvc plugin.

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
var core = new scaleApp.Core(yourSandboxClass);
```

- `core.register(moduleName, module, options)` - register a module
- `core.use(plugin, options)` - register a plugin
- `core.use(pluginArray)` - registers an array of plugins
- `core.boot(callback)` - initialize plugins
   (will be executed automatically on ´start´)
- `core.start(moduleId, options, callback)` - start a module
- `core.stop(instanceId, callback)` - stop a module

## Mediator

```javascript
// create a mediator
var mediator = new scaleApp.Mediator();

// create a mediator with a custom context object
var mediator = new scaleApp.Mediator(context);

// create a mediator with cascaded channels
var mediator = new scaleApp.Mediator(null, true);
```

- `mediator.emit(channel, data, callback)`
- `mediator.on(channel, callback, context)`
- `mediator.off(channel, callback)`
- `mediator.installTo(context, force)`

```javascript
// subscribe
var subscription = mediator.on(channel, callback, context);
```
- `subscription.detach` - stop listening
- `subscription.attach` - resume listening

```javascript
var fn  = function(){ /*...*/ };
var obj = { emit: fn };

// the installTo method prevents existing properties by default
mediator.installTo(obj);
obj.emit === fn // true

// set the second paramater to 'true'
// to force the mediator to override existing propeties
mediator.installTo(obj, true);
obj.emit === mediator.emit // true
```

## Sandbox

This is the default sandbox of scaleApp.
It's a better idea to use your own one.

```javascript
var sandbox =  new scaleApp.Sandbox(core, instanceId, options, moduleId)` - create a Sandbox
```
- `sandbox.emit` is `mediator.emit`
- `sandbox.on` is `mediator.on`
- `sandbox.off` is `mediator.off`

# Changelog

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
