/**
 * Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)
 */

/**
 * File: scaleApp.util.js
 * scaleApp is a tiny framework for One-Page-Applications.
 * It is licensed under the MIT licence.
 */

/**
 * Class: util
 * A countainer for some helpfull functions
 */
scaleApp['util'] = scaleApp.util || (function( window, undefined ){

	/**
	* Function: mixin
	*/
	var mixin = function( receivingClass, givingClass ){

		var mix = function( giv, rec ){

				var empty = {};

				$.extend( empty, giv, rec );
				$.extend( rec, empty );
		};

		switch( typeof givingClass + "-" + typeof receivingClass ){
			
			case "function-function":
				mix( givingClass.prototype, receivingClass.prototype );
				break;

			case "function-object":
				mix( givingClass.prototype, receivingClass );
				break;
				
			case "object-object":
				mix( givingClass, receivingClass );
				break;

			case "object-function":
				mix( givingClass, receivingClass.prototype );
				break;
		}

	};

	/**
	* Function: countObjectKeys
	* Counts all available keys of an object.
	*/
	var countObjectKeys = function( obj ){
		var count = 0;
		if( typeof obj === "object" ){
			for( var i in obj ){
				count++;
			}                            
		}
		return count;
	};

	return ({
		'mixin': mixin,
		'countObjectKeys': countObjectKeys
	});

})( window );
