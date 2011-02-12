# scaleApp
scaleApp is a tiny JavaScript framework for One-Page-Applications. 
It is inspired by the talk of Nicholas C. Zakas — "Scalable JavaScript Application Architecture".

Unlike his recommendations to abstract DOM manipulations and separating the framework from the base library, 
scaleApp explicitly ueses jQuery as base library. Therefore you can use the full power of jQuery in every layer.

scaleApp is licensed under the MIT license.

## Usage

Link scaleApp.js below the jQuery library in your HTML head section:

+-----------------------------------------------------------------------+
|									|
|  <head>								|
|   ...									|
|   <script type="text/javascript" src="jQuery.min.js"></script>	|
|   <script type="text/javascript" src="scaleApp.js"></script>		|
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

Afterwards start your module:

+-----------------------------------------------------------------------+
|	scaleApp.start( "myModuleId" );					|
+-----------------------------------------------------------------------+

You may also want to start several instances of your module:

+-----------------------------------------------------------------------+
|	scaleApp.start( "myModuleId", "myInstanceId" );			|
|	scaleApp.start( "myModuleId", "anOtherInstanceId" );		|
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

If your application should be support several languages, you can pass an objects containig the localized strings 
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

Now you can access that stings easely trough the sandbox with the '_' method. 
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

 
## Testing

scaleApp uses JsTestDriver ( https://code.google.com/p/js-test-driver/ ).
Make shure that Java is installed and the file "JsTestDriver-1.2.2.jar" is placed in the scaleApp directory.

Run the tests:
  1. start the server ( startTestServer.sh )
  2. open your browser and navigate to http://localhost:4224/
  3. click on "Capture This Browser"
  4. run the tests by executing runTests.sh
