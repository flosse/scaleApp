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
clean and scaleable architecture.

## Features

+ loose coupling of modules
+ small & simple
+ no serverside dependencies
+ modules can be tested separately
+ replacing any module without affecting other modules
+ extendable with plugins
+ browser and node.js support

## Extendable

scaleApp itself is very small but it can be extended with plugins. There already
are some plugins available (e.g. `mvc`, `i18n`, `permission`, `state`, etc.) but
you can easily define your own one.

## Download latest version

- [scaleApp 0.3.8.tar.gz](https://github.com/flosse/scaleApp/tarball/v0.3.8)
- [scaleApp 0.3.8.zip](https://github.com/flosse/scaleApp/zipball/v0.3.8)

# Quick Start

Link `scaleApp.min.js` in your HTML file:

```html
<script src="scaleApp.min.js"></script>
```

If you're going to use it with node:

```shell
sudo npm -g install scaleapp
```

```javascript
var sa = require("scaleapp");
```

## Register modules

```javascript
scaleApp.register( "myModuleId", function( sb ){
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

scaleApp.register "myGreatModule", MyGreatModule
```

The `init` function is called by the framework when the module is supposed to
start. The `destroy` function is called when the module has to shut down.

### Show registered modules

```javascript
scaleApp.lsModules() // returns an array of module names
```
### Show running instances

```javascript
scaleApp.lsInstances() // returns an array of instance names
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

scaleApp.register "myGreatModule", MyGreatModule
end -> alert "now the initialization is done"
scaleApp.start "myGreatModule", callback: end
```

## Unregister modules

It's simple:

```javascript
scaleApp.unregister("myGreatModule");
```

## Start modules

After your modules are registered, start your modules:

```javascript
scaleApp.start( "myModuleId" );
scaleApp.start( "anOtherModule" );
```

### Start options

You may also want to start several instances of a module:

```javascript
scaleApp.start( "myModuleId", {instanceId: "myInstanceId" } );
scaleApp.start( "myModuleId", {instanceId: "anOtherInstanceId" });
```

If you pass a callback function it will be called after the module started:

```javascript
scaleApp.start( "myModuleId", {callback: function(){ /*...*/ } );
```

All other options you pass are available through the sandbox:

```javascript
scaleApp.register( "mod", function(s){
  sb = s
  return {
    init:    function(){ alert( sb.options.myProperty ); },
    destroy: function(){ /*...*/ }
  };
});

scaleApp.start("mod", {myProperty: "myValue"});
```

If all your modules just needs to be instanciated once, you can simply starting
them all:

```javascript
scaleApp.startAll();
```

To start some special modules at once you can pass an array with the module
names:

```javascript
scaleApp.startAll(["moduleA","moduleB"]);
```

You can also pass a callback function:

```javascript
scaleApp.startAll(function(){
  // do something when all modules were initialized
});
```

## Stopping

It's obvious:

```javascript
scaleApp.stop("moduleB");
scaleApp.stopAll();
```

## Listing modules and instances

```javascript
lsModules()   // returns an array of all registered module IDs
lsInstances() // returns an array of all running instance IDs
```

## Publish/Subscribe

If the module needs to communicate with others, you can use the `publish` and
`subscribe` methods.

### Publish

The `publish` function takes three parameters whereas the last one is optional:
- `topic` : the channel name you want to publish to
- `data`  : the data itself
- `opt`   : options or callback
    - `publishReference` : If the data should be passed as a reference to the
       other modules this parameter has to be set to `true`.
       By default the data object gets copied so that other modules can't
       influence the original object.

The publish function is accessible through the sandbox:

```javascript
sb.publish( "myEventTopic", myData );
```

You can also use the shorter method alias `emit`.

### Subscribe

A message handler could look like this:

```javascript
var messageHandler = function( data, topic ){
  switch( topic ){
    case "somethingHappend":
      sb.publish( "myEventTopic", processData(data) );
      break;
    case "aNiceTopic":
      justProcess( data );
      break;
  }
};
```

... and it can listen to one or more channels:

```javascript
sub1 = sb.subscribe( "somthingHappend", messageHandler );
sub2 = sb.subscribe( "aNiceTopic", messageHandler );
```
Or just do it at once:

```javascript
sb.subscribe({
  topicA: cbA
  topicB: cbB
  topicC: cbC
});
```

You can also subscribe to several channels at once:

```javascript
sb.subscribe(["a", "b"], cb);
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
sb.unsubscribe("a-channel", callback);
```

And you can remove a callback function from all channels

```javascript
sb.unsubscribe(callback);
```

Or remove all subscriptions from a channel:

```javascript
sb.unsubscribe("channelName");
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
scaleApp.register( "moduleId", myModule, { i18n: myLocalization } );
```

Now you can access these strings easily trough the sandbox using the `_` method.
Depending on which language is set globally it returns the corresponding
localized string.

```javascript
sb._("myStringId");
```

You can set the language globally by using the `setLanguage` method:

```javascript
scaleApp.i18n.setLanguage( "de" );
```

You can also set a global i18n object which can be used by all modules:

```javascript
scaleApp.i18n.setGlobal( myGlobalObj );
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
registerModule "myModule", (@sb) ->

  init: (opt) ->

    # You can use any template engine you like. Here it's
    # just a simple function
    template = (model) -> "<h1>Hello #{model.name}</h1>"

    @m = new MyModel
    @v = new MyView @m, @sb, @template
    @c = new MyController @m, @v

    # listen to the "changeName" event
    @sb.subscribe "changeName", @c.changeName, @c

  destroy: ->
    delete @c
    delete @v
    delete @m
    @sb.unsubscribe @
```

```coffeescript
scaleApp.publish "changeName", "Peter"
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
scaleApp.addPermission "instanceA", "subscribe"
scaleApp.addPermission "instanceB", "publish"
```

Now `instanceA` is allowed to subscribe to a channel but `instanceB` cannot
subscribe. Therefore `instanceB` can publish data and `instanceB` can not.

Of course you can remove a permission at any time:

```coffeescript
scaleApp.removePermission "moduleA", "publish"
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
```

Usage:

```coffeescript
scaleApp.myCoreFunction()   # alerts "Hello core plugin"

class MyModule
  constructor: (@sb) ->
  init: -> @sb.appendFoo()  # appends "foo" to the container
  destroy: ->
```
# Build browser bundles

Just type

```shell
cake bundle
```
that will create `scaleApp.js`, `scaleApp.min.js`, `scaleApp.full.js` and
`scaleApp.full.min.js` whithin the `build/bundles/` directory.

If you want scaleApp bundled with special plugins type

```shell
cake -p [PLUGIN_NAME] bundle
```
e.g. `cake -p dom,mvc bundle` creates the file `scaleApp.custom.js` that
contains scaleApp itself the dom plugin and the mvc plugin.

# Testing

```shell
npm test
```

# Demo

**WARNING**: the demo is out of date

You can try out the [sample application](http://www.scaleapp.org/demo/fast/)
that is build on [scaleApp](http://www.scaleapp.org).
Also have a look at the [source code](http://github.com/flosse/FAST).

# Licence

scaleApp is licensed under the MIT license.
For more information have a look at
[LICENCE.txt](https://raw.github.com/flosse/scaleApp/master/LICENCE.txt).
