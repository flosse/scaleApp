/**
 * Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)
 */

/**
 * PrivateClass: scaleApp.util
 * A countainer for some helpfull functions
 */
(function( window, core, undefined ){

  /**
  * PrivateFunction: mixin
  */
  var mixin = function( receivingClass, givingClass, override ){

    var mix = function( giv, rec ){

        var empty = {};

        if( override === true ){
          $.extend( rec, giv );
        }else{
          $.extend( empty, giv, rec );
          $.extend( rec, empty );
        }
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
  * PrivateFunction: countObjectKeys
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

  core['util'] = core['util'] || ({
    'mixin': mixin,
    'countObjectKeys': countObjectKeys
  });

}( window, window['scaleApp'] ));
