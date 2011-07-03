(function( window, scaleApp, $ ){

  // container for all templates
  var templates = { };
  
  var onInstantiate = function( instanceId, instanceOpts, sb ){

    var dfd = $.Deferred();

    if( instanceOpts['templates'] ){

      loadMultiple( instanceOpts['templates'] )
        .done( function( res ){
            set( instanceId, res );
            dfd.resolve(); 
         })
        .fail( function( err ){ 
          dfd.reject( err );
         })
        .then( function(){ 
          delete instanceOpts['templates']; 
        });

    }else{
      dfd.resolve();
    } 

    return dfd.promise();
  };

  /**
   * PrivateFunction: load
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
   * PrivateFunction: loadMultiple
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
   * PrivateFunction: get
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
   * PrivateFunction: add
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
   * PrivateFunction: set
   */
  var set = function( instanceId, obj ){
    if( typeof instanceId === "string" && typeof obj === "object" ){
      templates[ instanceId ] = obj;
    }else{
      core['log']['error']("could not set templates: invalid parameters", "template");
    }
  };

  scaleApp.onInstantiate( onInstantiate );

  scaleApp.addPlugin('template', function( sb, instanceId ){

    /**
    * Function: getTemplate
    * Get a template by name.
    *
    * Parameters:
    * (String) id - The template ID
    *
    * Returns:
    * (Object) template - pre-rendered jQuery template
    */
    var getTemplate = function( id ){
      return get( instanceId, id );
    };

    /**
    * Function: tmpl
    * Render a specific template.
    *
    * Parameters:
    * (String) id   - The template ID
    * (Object) data - The template data object
    */
    var tmpl = function( id, data ){
      if( typeof id === "string" ){
        return $.tmpl( getTemplate( id ), data );
      }else if( typeof id === "function" ){
        return $.tmpl( id, data );
      }else{
        sb.error("type of 'id' is not valid", "sandbox of " + instanceId );
      }
    };

    // Public API
    return ({
      'getTemplate': getTemplate,
      'tmpl': tmpl
    });

  });

}( window, window['scaleApp'], jQuery ));
