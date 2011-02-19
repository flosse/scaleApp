# scaleApp
scaleApp is a tiny JavaScript framework for scalable One-Page-Applications. 
The framework allows you to easily create complex web applications.

With scaleApp you are able to write modules that concentrate on their own business. 
They can act independently from each other and communicate through a central event system.
Each module has its own sandbox where it can play in. Thus as developer you only need to know the API of the sandbox.

By splitting your complex application into separate parts using loose coupling, 
it is comfortable to maintain and scale.

If you like the following features, scaleApp might be the right choice for you:

+ loose coupling of modules
+ small & simple
+ no serverside dependencies
+ modules can be tested separately
+ replacing any module without affecting other modules
+ multi language UIs
+ supports the Model–View–Controller pattern

scaleApp is inspired by the talk of Nicholas C. Zakas — "Scalable JavaScript Application Architecture" 
(http://developer.yahoo.com/yui/theater/video.php?v=zakas-architecture).
Unlike his recommendations to abstract DOM manipulations and separating the framework from the base library, 
scaleApp explicitly uses jQuery as base library. Therefore you can use the full power of jQuery on every layer.

## Dependencies

At the moment only jQuery and the jQuery.hotkeys plugin are required.
You can use scaleApp.full.min.js that already contains all required libraries.

## Usage

Link scaleApp.full.min.js in your HTML head section:

+-----------------------------------------------------------------------+
|									|
|  <head>								|
|   ...									|
|   <script type="text/javascript" src="scaleApp.full.min.js"></script>	|
|   ...									|
|  </head>								|
|									|
+-----------------------------------------------------------------------+


Now you can register your modules:

+-----------------------------------------------------------------------+
|									|
| ...									|
|  scaleApp.register( "myModuleId", function( sb ){			|
|	...								|
|	return {							|
|	  init: function(){						|
|	    ...								|
|	  },								|
|	  destroy: function(){						|
|	    ...								|
|	  }								|
|	};								|
|  });									|
| ...									|
|									|
+-----------------------------------------------------------------------+

As you can see the module is a function that takes the sandbox as an parameter 
and returns an object that has the two functions 'init' and 'destroy'. 
The 'init' function is called by the framework when the module is supposed to start.
The 'destroy' function is called when the module has to shut down.

After your modules are registered, start your modules:

+-----------------------------------------------------------------------+
|	scaleApp.start( "myModuleId" );					|
|	scaleApp.start( "AnOtherModule" );				|
|	...								|
+-----------------------------------------------------------------------+

You may also want to start several instances of your module:

+-----------------------------------------------------------------------+
|	scaleApp.start( "myModuleId", "myInstanceId" );			|
|	scaleApp.start( "myModuleId", "anOtherInstanceId" );		|
+-----------------------------------------------------------------------+

If all your modules just needs to be instanciated once, you can simply start them all with:

+-----------------------------------------------------------------------+
|	scaleApp.startAll();						|
+-----------------------------------------------------------------------+

If your module is more complex, you might want to split it into models and views.
So use your current module as a controller and pass your models and views with the option object.
You can get your models and views with the sandbox method 'getModel' and 'getView' respectively.

+-----------------------------------------------------------------------+
| ...									|
|  var myController = function( sb ){					|
|									|
|	var modelOne;							|
|	...								|
|	var viewOne;							|
|	...								|
|	var init = function(){						|
|	  modelOne = sb.getModel( "myModelOne" );			|
|	  ...								|
|	  viewOne = sb.getView( "myViewOne" );				|
|	  ...								|
|	} 								|
|	...								|
|									|
|	return { init: init, destroy: destroy };			|
|  };									|
| ...									|
|  var myModelOne = function( sb ){ ... }				|
| ...									|
|  scaleApp.register( "moduleId", myController,				|
|  {									|
|	models: {							|
|	  modelIdOne: myModelOne,					|
|	  modelIdTwo: myModelTwo 					|
|	},								|
|	views: { 							|
|	  viewIdOne: myViewOne,						|
|	  viewIdTwo: myViewTwo						|
|	}								|
|  });									|
| ...									|
+-----------------------------------------------------------------------+

If the module needs to communicate with an other one, you can use the 'publish' and 'subscribe' commands.

+-----------------------------------------------------------------------+
| ...									|
|  var eventHandlerOne = function( topic, data ){			|
|	...								|	
|  };									|
|  ...									|
|  var messageHandler = function( topic, data ){			|
|  									|
|	switch( topic ){						|
|									|
|	  case "somthingHappend":					|
|	    var result = processData( data );				|
|	    sb.publish( "myEventTopic", result );			|
|	    break;							|
|	    ....							|
|	}...								|
|  };									|
|									|
|  var init = function(){						|
|	sb.subscribe( "anInteresstingEvent", eventHandlerOne );		|
|	sb.subscribe( "somthingHappend", messageHandler );		|
|	sb.subscribe( "aNiceTopic", messageHandler );			|
|  };									|
| ...									|
+-----------------------------------------------------------------------+

If your application should be support several languages, you can pass an objects containing the localized strings 
with the options object.

+-----------------------------------------------------------------------+
| ...									|
|  var myLocalization = 						|
|    { 									|
|	en: { welcome: "Welcome", ... }, 				|
|	de: { welcome: "Willkommen", ... }, 				|
|	...								|
|    }									|
| ...									|
|  scaleApp.register( "moduleId", myModule, { i18n: myLocalization } );	|
| ...									|
+-----------------------------------------------------------------------+

Now you can access that stings easily trough the sandbox with the '_' method. 
Depending on which language is set globally it returns the corresponding localized string.

+-----------------------------------------------------------------------+
| ...									|
|  sb._("myStringId" );							|
| ...									|
+-----------------------------------------------------------------------+

You can set the language globally by using the 'setLanguage' method:

+-----------------------------------------------------------------------+
| ...									|
|  scaleApp.i18n.setLanguage( "de" );					|
| ...									|
+-----------------------------------------------------------------------+

For handling hotkeys, you simply can register them like this:

+-----------------------------------------------------------------------+
| ...									|
|  scaleApp.hotkeys( "alt+c", myFunction, "keydown" );			|
|  scaleApp.hotkeys( "h", myFunction, "keypress" );			|
| ...									|
+-----------------------------------------------------------------------+

If you want to trigger an event by hotkeys, you can simply do it in that way:

+-----------------------------------------------------------------------+
| ...									|
|  scaleApp.hotkeys( "alt+c", "myTopic", myData, "keydown" );		|
| ...									|
+-----------------------------------------------------------------------+

 
## Testing

scaleApp uses JsTestDriver ( https://code.google.com/p/js-test-driver/ ).
Make shure that Java is installed and the file "JsTestDriver-1.2.2.jar" is placed in the scaleApp directory.

Run the tests:
  1. start the server ( startTestServer.sh )
  2. open your browser and navigate to http://localhost:4224/
  3. click on "Capture This Browser"
  4. run the tests by executing runTests.sh


## Licence

scaleApp is licensed under the MIT license.
For more information have a look at LICENCE.txt.
