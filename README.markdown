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

Unlike Zakas recommendations to abstract DOM manipulations and separating the
framework from the base library, scaleApp does not implement any DOM methods.

Instead scaleApp can be extended by plugins. So you can just use one of your
favorite libs (e.g. jQuery) as base library or you are going to implement all
your needed DOM methods into the DOM plugin (`scaleApp.dom.coffee`) for a more
clean and scalable architecture.

## Features

+ loose coupling of modules
+ small (about 340 sloc / 10k min / 3.4k gz)
+ no dependencies
+ modules can be tested separately
+ replacing any module without affecting other modules
+ extendable with plugins
+ browser and node.js support
+ flow control

## Extendable

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

## Download latest version

- [scaleApp 0.3.9.tar.gz](https://github.com/flosse/scaleApp/tarball/v0.3.9)
- [scaleApp 0.3.9.zip](https://github.com/flosse/scaleApp/zipball/v0.3.9)

# Quick Start

Link `scaleApp.min.js` in your HTML file:

```html
<script src="scaleApp.min.js"></script>
```

If you're going to use it with node:

```shell
npm install scaleapp
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
core.register( "myModuleId", function( sb ){
  return {
    init:    function(){ /*...*/ },
    destroy: function(){ /*...*/ }
  };
});
```

As you can see the module is a function that takes the sandbox as a parameter
and returns an object that has two functions `init` and `destroy`.
Of course your module can be any usual class with those two functions.
Here an coffee-script example:

```coffeescript
class MyGreatModule

  constructor: (@sb) ->
  init: -> alert "Hello world!"
  destroy: -> alert "Bye bye!"

core.register "myGreatModule", MyGreatModule
```

The `init` function is called by the framework when the module is supposed to
start. The `destroy` function is called when the module has to shut down.

### Show registered modules

```javascript
core.lsModules() // returns an array of module names
```
### Show running instances

```javascript
core.lsInstances() // returns an array of instance names
```

### Show registered plugins

```javascript
scaleApp.lsPlugins() // returns an array of plugin names
```

## Asynchronous initialization

You can also init or destroy you module in a asynchronous way:

```coffeescript
class MyAsyncModule

  constructor: (@sb) ->

  init: (options, done) ->
    doSomethingAsync (err) ->
      done err
  destroy: (done) ->
    doSomethingAsync (err) ->
      done err

core.register "myGreatModule", MyGreatModule
end -> alert "now the initialization is done"
core.start "myGreatModule", callback: end
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
core.start( "myModuleId", {callback: function(){ /*...*/ } );
```

All you attach to `options` is accessible within your module:

```javascript
core.register( "mod", function(sb){
  return {
    init: function(opt){
      (opt === sb.options)            // true
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

## Listing modules and instances

```javascript
lsModules()   // returns an array of all registered module IDs
lsInstances() // returns an array of all running instance IDs
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
sb.emit( "myEventTopic", myData );
```

You can also use the shorter method alias `emit`.

### on

A message handler could look like this:

```javascript
var messageHandler = function( data, topic ){
  switch( topic ){
    case "somethingHappend":
      sb.emit( "myEventTopic", processData(data) );
      break;
    case "aNiceTopic":
      justProcess( data );
      break;
  }
};
```

... and it can listen to one or more channels:

```javascript
sub1 = sb.on( "somthingHappend", messageHandler );
sub2 = sb.on( "aNiceTopic", messageHandler );
```
Or just do it at once:

```javascript
sb.on({
  topicA: cbA
  topicB: cbB
  topicC: cbC
});
```

You can also subscribe to several channels at once:

```javascript
sb.on(["a", "b"], cb);
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
sb.off("a-channel", callback);
```

And you can remove a callback function from all channels

```javascript
sb.off(callback);
```

Or remove all subscriptions from a channel:

```javascript
sb.off("channelName");
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


# Plugins

## i18n - Multi language UIs

Link `scaleApp.i18n.min.js` in your HTML file:

```html
<script src="scaleApp.min.js"></script>
<script src="scaleApp.i18n.min.js"></script>
```

If your application has to support multiple languages, you can pass an objects
containing the localized strings with the options object.

```javascript
var myLocalization =
{
  en: { welcome: "Welcome", ... },
  de: { welcome: "Willkommen", ... },
  ...
}
...
core.register( "moduleId", myModule, { i18n: myLocalization } );
```

Now you can access these strings easily trough the sandbox using the `_` method.
Depending on which language is set globally it returns the corresponding
localized string.

```javascript
sb._("myStringId");
```

You can set the language globally by using the `setLanguage` method:

```javascript
core.i18n.setLanguage( "de" );
```

You can also set a global i18n object which can be used by all modules:

```javascript
core.i18n.setGlobal( myGlobalObj );
```

Within your module you can define your local texts:

```javascript
function(sb){
  init: function(){
    sb.i18n.addLocal({
      en: {hello: "Hello" },
      de: {hello: "Hallo" }
    });
  },
  destroy: function(){}
}
```

Subscribe to change event:

```javascript
sb.i18n.onChange(function(){
  // update ui
});
```

## mvc - very simple MVC

![scaleApp mvc](https://raw.github.com/flosse/scaleApp/master/mvc.png)

Here is a sample use case for using the MVC plugin (in coffeescript).

```coffeescript
class MyModel extends scaleApp.Model name: "Noname"
```

```coffeescript
class MyView extends scaleApp.View

  constructor: (@model, @sb, @template) -> super @model

  # The render method gets automatically called when the model changes
  # The 'getContainer' method is provided by the dom plugin
  render: -> @sb.getContainer.innerHTML = @template @model
```

```coffeescript
class MyController extends scaleApp.Controller

  changeName: (name) -> @model.set "name", name
```

```coffeescript
core.registerModule "myModule", (@sb) ->

  init: (opt) ->

    # You can use any template engine you like. Here it's
    # just a simple function
    template = (model) -> "<h1>Hello #{model.name}</h1>"

    @m = new MyModel
    @v = new MyView @m, @sb, @template
    @c = new MyController @m, @v

    # listen to the "changeName" event
    @sb.on "changeName", @c.changeName, @c

  destroy: ->
    delete @c
    delete @v
    delete @m
    @sb.off @
```

```coffeescript
core.emit "changeName", "Peter"
```
## state - Finite State Machine

The state plugin is an approach to implement a
[Finite State Machine](https://en.wikipedia.org/wiki/Finite_state_machine)
that can be used to keep track of your applications state.

![scaleApp fsm](https://raw.github.com/flosse/scaleApp/master/fsm.png)

```coffeescript
s = new scaleApp.StateMachine
          start: "a"
          states:
            a:      { enter: (ev) -> console.log "entering state #{ev.to}"  }
            b:      { leave: (ev) -> console.log "leaving state #{ev.from}" }
            c:      { enter: [cb1, cb2], leave: cb3                         }
            fatal:  { enter: -> console.error "something went wrong"        }
          transitions:
            x:    { from: "a"        to: "b"     }
            y:    { from: ["b","c"]  to: "c"     }
            uups: { from: "*"        to: "fatal" }

s.addState "d", { enter: -> }                 # add an additional state
s.addState { y: {}, z: { enter: cb } }        # or add multiple states

s.addTransition "t", { from: "b", to: "d" }   # add a transition
s.can "t"                                     # false because 'a' is current state
s.can "x"                                     # true

s.onLeave "a", (transition, eventName, next) ->
  # ...
  next()

s.onEnter "b", (transitioin, eventName, next) ->
  doSomething (err) -> next err

s.fire "x"
s.current                                     # b
```

## permission - controll all messages

If you include the `permission` plugin, all `Mediator` methods will be rejected
by default to enforce you to permit any message method explicitely.

```coffeescript
core.permission.add "instanceA", "on", "a"
core.permission.add "instanceB", "emit", ["b", "c"]
core.permission.add "instanceC", "emit", '*'
core.permission.add "instanceD", '*', 'd'
```

Now `instanceA` is allowed to subscribe to channel `a` but all others cannot
subscribe to it.
`InstanceB` can emit data on channels `a` and `c`.
`InstanceC` can emit to all channels.
`InstanceD` can perform all actions (`on`, `off`, `emit`)
but only on channel `d`.

Of course you can remove a permission at any time:

```coffeescript
core.permission.remove "moduleA", "emit", "x"
```

Or remove the subscribe permissions of all channels:

```coffeescript
core.permission.remove "moduleB", "on"
```

## strophe - XMPP plugin

This is an adapter plugin for [Strophe.js](http://strophe.im/strophejs/) with
some helpful features (e.g. automatically reconnect on page refresh).

```javascript
core.xmpp.login("myjid@server.tld", "myPassword");
core.xmpp.logout();
core.xmpp.jid       // the current JID
```

## submodule

```javascript

core.register("parent", function(sb){

  var childModule = function(sb){
    return({
      init: function(){
        sb.emit("x", "yeah!");
      },
      destroy: function(){}
    });
  });

  return({
    init: function(){
      sb.sub.register("child",childModule);
      sb.permission.add("child", "emit", "x");
      sb.sub.on("x",function(msg){
        console.log("a child send this: " + msg);
      });
      sb.sub.start("child");
    },
    destroy: function(){}
  });

});

core.start("parent");
// the "parent" module starts a child within the init method

core.stop("parent");
// all children of "parent" were automatically stopped
```

## util - some helper functions

 - `sb.mixin(receivingClass, givingClass, override=false)`
 - `sb.countObjectKeys(object)`

## Other plugins

- dom - basic DOM manipulations (currently only used for `getContainer`)

## Write your own plugin

```coffeescript
scaleApp.registerPlugin

  # set the ID of your plugin
  id: "myPlgin"

  # define the core extensions
  core:
    myCoreFunction: -> alert "Hello core plugin"
    myBoringProperty: "boring"

  # define the sandbox extensions
  sandbox: (@sb) ->
    appendFoo: -> @sb.getContainer.append "foo"

  # define base extensions
  base:
    globalHello: -> "Hello"

  # define methods for module changes
  on:
    instantiate: ->
    destroy: ->
```

Usage:

```coffeescript
core.myCoreFunction()   # alerts "Hello core plugin"

class MyModule
  constructor: (@sb) ->
  init: -> @sb.appendFoo()  # appends "foo" to the container
  destroy: ->
```

# Existing modules

You can find some example modules in `src/modules/`.

# Build browser bundles

If you want scaleApp bundled with special plugins type

```shell
grunt custom[:PLUGIN_NAME]
```
e.g. `cake custom:dom:mvc` creates the file `scaleApp.custom.js` that
contains scaleApp itself the dom plugin and the mvc plugin.

# Changelog

#### v0.4.0 (??-2013)

- `Mediator`: do not *clone* objects any more (do it manually instead)
- drop `subscribe`, `unsubscribe`, `publish` from Mediator API
  (use `on`, `off` and `emit` instead)
- added a `Core` class that can be instantiated
- new submodule plugin
- emit events on module state changes
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
