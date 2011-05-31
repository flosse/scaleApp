# scaleApp
scaleApp is a tiny JavaScript framework for scalable One-Page-Applications. 
The framework allows you to easily create complex web applications.

With scaleApp you are able to write modules that focus on their own business. 
They can act independently from each other and communicate through a central event system.
Each module has its own sandbox where it can play in. Thus as developer you only need to know the API of the sandbox.

By splitting your complex application into separate parts by loose coupling, 
it is comfortable to maintain and scale.

If you like the following features, scaleApp might be the right choice for you:

+ loose coupling of modules
+ small & simple
+ no serverside dependencies
+ modules can be tested separately
+ replacing any module without affecting other modules
+ multi language UIs
+ supports the Model–View–Controller pattern

scaleApp is inspired by the talk of Nicholas C. Zakas — 
["Scalable JavaScript Application Architecture"](http://developer.yahoo.com/yui/theater/video.php?v=zakas-architecture).
Unlike his recommendations to abstract DOM manipulations and separating the framework from the base library, 
scaleApp explicitly uses jQuery as base library. Therefore you can use the full power of jQuery on every layer.

## Demo

You can try out the [sample application](http://www.scaleapp.org/demo/fast/) that is build on 
[scaleApp](http://www.scaleapp.org). Also have a look at the [source code](http://github.com/flosse/FAST).


## Dependencies

At the moment only jQuery and the jQuery.hotkeys plugin are required.
You can use scaleApp.full.min.js that already contains all required libraries.

## Usage

### Basic usage

Link scaleApp.full.min.js in your HTML head section:

    <head>
      ...
      <script type="text/javascript" src="scaleApp.full.min.js"></script>
      ...
    </head>

Now you can register your modules:

    scaleApp.register( "myModuleId", function( sb ){
	    ...
	    return {
	      init: function(){
		...
	      },
	      destroy: function(){
		...
	      }
	    };
      });

As you can see the module is a function that takes the sandbox as a parameter 
and returns an object that has two functions 'init' and 'destroy'. 
The 'init' function is called by the framework when the module is supposed to start.
The 'destroy' function is called when the module has to shut down.

After your modules are registered, start your modules:

    scaleApp.start( "myModuleId" );
    scaleApp.start( "AnOtherModule" );
    ...

You may also want to start several instances of your module at once:

    scaleApp.start( "myModuleId", "myInstanceId" );
    scaleApp.start( "myModuleId", "anOtherInstanceId" );

If all your modules just needs to be instanciated once, you can simply starting them all with:

    scaleApp.startAll();

You can also pass a callback function:

    scaleApp.startAll(function(){
      // do something when all modules were initialized
    });

### MVC

If your module is more complex, you might want to split it into models and views.
So use your current module as a controller and pass your models and views with the option object.
You can get your models and views with the sandbox method 'getModel' and 'getView' respectively.

    var myController = function( sb ){

	  var modelOne;
	  ...
	  var viewOne;
	  ...
	  var init = function(){
	    modelOne = sb.getModel( "myModelOne" );
	    ...
	    viewOne = sb.getView( "myViewOne" );
	    ...
	  }
	  ...

	  return { init: init, destroy: destroy };
    };
    ...
    var myModelOne = { ... }
    ...
    scaleApp.register( "moduleId", myController,
    {
	  models: {
	    modelIdOne: myModelOne,
	    modelIdTwo: myModelTwo
	  },
	  views: {
	    viewIdOne: myViewOne,
	    viewIdTwo: myViewTwo
	  }
    });

If you want to make use of the observer pattern, you can extend your model easily with a simple implementation:

    sb.mixin( myModel, sb.observable );

Now the methods 'subscribe', 'unsubscribe' and 'notify' are available to you. 
Your observer has to implement the update method to be notified on change.

If you defined a model on registration, your model is already extended, so you can do something like this:

    var myView = (function(){
	    ...
	    var init = function( sb ){
		    ...
		    model = sb.getModel( "myModel" );
		    model.subscribe( this );
		    ...
	    };

	    var update = function(){
	      render( model );
	    };
	    ...
	    return { init: init, destroy: destroy, update:update };		
    })();

### Publish/Subscribe

If the module needs to communicate with others, you can use the 'publish' and 'subscribe' methods.

    var eventHandlerOne = function( topic, data ){ ... };
    ...
    var messageHandler = function( topic, data ){

	  switch( topic ){

	    case "somethingHappend":
	      var result = processData( data );
	      sb.publish( "myEventTopic", result );
	      break;
	      ....
	  }
	  ...
    };

    var init = function(){
      sb.subscribe( "anInteresstingEvent", eventHandlerOne );
      sb.subscribe( "somthingHappend", messageHandler );
      sb.subscribe( "aNiceTopic", messageHandler );
    };

### i18n

If your application has to support multiple languages, you can pass an objects containing the localized strings 
with the options object.

    var myLocalization =
    {
      en: { welcome: "Welcome", ... }, 
      de: { welcome: "Willkommen", ... },
      ...
    }
    ...
    scaleApp.register( "moduleId", myModule, { i18n: myLocalization } );

Now you can access these strings easily trough the sandbox using the '_' method. 
Depending on which language is set globally it returns the corresponding localized string.

    sb._("myStringId" );

You can set the language globally by using the 'setLanguage' method:

    scaleApp.i18n.setLanguage( "de" );

### hotkeys

For handling hotkeys, you simply can register them like this:

    scaleApp.hotkeys( "alt+c", myFunction, "keydown" );
    scaleApp.hotkeys( "h", myFunction, "keypress" );

If you want to trigger an event by hotkeys, you can simply do it in that way:

    scaleApp.hotkeys( "alt+c", "myTopic", myData, "keydown" );

### templating

Create a HTML-File with placeholders on your server.

    <div>
      ...
      <li>${ Name }</li>
      ...
    </div>

Link to your template when you register your module.

    scaleApp.register( "moduleId", myModule,
    {
      models: { ... },
      views: { ... },
      templates: { myTemplate: "path/to/myTemplate.html" },
      i18n: myi18n 
    }); 

Once registered, you can use it in your module like this:

    var init = function(){
      ...
      sb.tmpl("myTemplate", myData ).appendTo( somewhere );
      ...
    }

## Testing

scaleApp uses [JsTestDriver]( https://code.google.com/p/js-test-driver/ ).
Make shure that Java is installed and the file "JsTestDriver-1.2.2.jar" is placed in the scaleApp directory.

Run the tests:

  1. start the server ( startTestServer.sh )
  2. open your browser and navigate to http://localhost:4224/
  3. click on "Capture This Browser"
  4. run the tests by executing runTests.sh


## Licence

scaleApp is licensed under the MIT license.
For more information have a look at LICENCE.txt.