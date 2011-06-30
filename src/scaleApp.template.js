/**
 * Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)
 */

/**
 * File: scaleApp.template.js
 * 
 * It is licensed under the MIT licence.
 */

/**
 * Class: scaleApp.template
 */
(function( window, core, undefined ){

  // container for templates
  var templates = { };

  /**
   * Function: load
   * 
   * Parameters:
   * (String) path
   */
  var load = function( path ){

    var dfd = $.Deferred();

    if( typeof path === "string" ){
 
      $.get( path )
				.done( function( html ){ 
            dfd.resolve( 
              $('<script type="text/x-jquery-tmpl">' + html + '</script>')
              .template() 
            ); 
          })
				.fail( function(){ dfd.reject("Could not load the template"); });

    }else{
      dfd.reject("function argument has to be a string");
    }
    return dfd.promise();
  };

  /**
   * Function: loadMultiple
   *
   */
  var loadMultiple = function( tmpls ){

    var dfd = $.Deferred();
    var deferreds = [];
    var templates = {};
    var onSuccess = function( key ){ 
      return function( data ){ templates[ key ] = data; }; 
    };

    for( var i in tmpls ){
      deferreds.push( load( tmpls[i] ).done( new onSuccess( i ) ));
    }

    $.when.apply( null, deferreds ).done(function(){ 
      dfd.resolve( templates );
    });

    return dfd.promise();
  };

  /**
   * Function: get
   */
  var get = function( instanceId, id ){

    var t = templates[ instanceId ];

    if( t ){

      if( !id && $(t).length === 1 ){
				for( var one in t ){ break; }
				return t[ one ];
      }

      return t[ id ];
    }
  };

  /**
   * Function: add
   */
  var add = function( instanceId, id, tmpl ){
    if( typeof instanceId === "string" &&
				typeof id === "string" &&
				typeof tmpl === "function" ){
			if( !templates[ instanceId ] ){ templates[ instanceId ] = {}; }
					templates[ instanceId ][ id ] = tmpl;
    }else{
      core['log']['error']("could not add template: invalid parameters", "template");
    }
  };

  /**
   * Function: set
   */
  var set = function( instanceId, obj ){
    if( typeof instanceId === "string" && typeof obj === "object" ){
      templates[ instanceId ] = obj;
    }else{
      core['log']['error']("could not set templates: invalid parameters", "template");
    }
  };

  // publich API
  core['template'] = core['template'] || ({
    'load': load,
    'loadMultiple': loadMultiple,
    'get': get,
    'add': add,
    'set': set
  });
}( window, window['scaleApp'] ));
