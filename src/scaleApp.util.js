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
scaleApp.util = scaleApp.util || (function( window, undefined ){

 /**
  * Function: mixin
  */
  var mixin = function( receivingClass, givingClass ){

    if( typeof receivingClass === "function" && typeof givingClass === "function" ){
      for( var i in givingClass.prototype ){
	if( !receivingClass.prototype[i] ){
	  receivingClass.prototype[i] = givingClass.prototype[i];
	}
      }
    } else if ( typeof receivingClass === "object" && typeof givingClass === "function" ){
      for( var j in givingClass.prototype ){
	if( !receivingClass[j] ){
	  receivingClass[j] = givingClass.prototype[j];
	}
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
    mixin: mixin,
    countObjectKeys: countObjectKeys
  });

})( window );
