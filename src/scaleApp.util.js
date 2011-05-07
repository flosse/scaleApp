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

		if( typeof givingClass === "function" ){
			if( typeof receivingClass === "function" ){
				$.extend( true, receivingClass.prototype, givingClass.prototype );
			} else if ( typeof receivingClass === "object" ){
				$.extend( true, receivingClass, givingClass.prototype );
			}
		}
	};

	/**
	* Function: countObjectKeys
	* Counts all available keys of an object.
	*/
	var countObjectKeys = function( obj ){
		var count = 0;
		for( var i in obj ){
			count++;
		}
		return count;
	};

	return ({
		'mixin': mixin,
		'countObjectKeys': countObjectKeys
	});

})( window );
