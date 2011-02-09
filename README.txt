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

Afterwards start an instance of your module:

+-----------------------------------------------------------------------+
|	scaleApp.start( "myModuleId", "myInstanceId" );			|
+-----------------------------------------------------------------------+
 
