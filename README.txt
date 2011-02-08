# scaleApp
scaleApp is a tiny JavaScript framework for One-Page-Applications. 
It uses jQuery a base library.

scaleApp is licensed under the MIT license.

## Usage

Lnk scaleApp.js below the jQuery library in your HTML head section:

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
|  scaleApp.core.register( "myModuleId", function( sb ){		|
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
|	scaleApp.core.start("myModuleId", "myInstanceId" );		|
+-----------------------------------------------------------------------+
 
