/**
 * Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)
 */

/**
 * scaleApp is a tiny framework for One-Page-Applications.
 * It is licensed under the MIT licence.
 */

/**
 * Class: scaleApp
 * The core holds and manages all data that is used globally.
 */
(function( window, name, undefined ){

  // reference to the core object itself
  var that = this;

  // container for all registered modules
  var modules = { };

  // container for all module instances
  var instances = { };

  // container for lists of submodules
  var subInstances = { };

  // container for all plugins
  var plugins = { };

  // container for all functions that gets called when an instance gets created
  var onInstantiateFunctions = {
    '_always': []
  };

  // local log functions
  var log = function( msg, mod, level ){

    if( that['log'] && typeof that['log'][ level ] === "function" ){
      that['log'][ level ]( msg, mod );
    }
  };

  var debug = function( msg, mod ){ log( msg, mod, "debug" ); };
  var info  = function( msg, mod ){ log( msg, mod, "info"  ); };
  var warn  = function( msg, mod ){ log( msg, mod, "warn"  ); };
  var error = function( msg, mod ){ log( msg, mod, "error" ); };
  var fatal = function( msg, mod ){ log( msg, mod, "fatal" ); };

  /**
   * Function: onInstantiate
   * Registers a function that gets executed when a module gets instantiated.
   *
   * Parameters:
   * (Function) fn      - Callback function
   * (String) moduleId  - Only call if specified module ID gets instantiated
   */
  var onInstantiate = function( fn, moduleId ){

    if( typeof fn === "function" ){

      if( moduleId && typeof moduleId === "string" ){

        if( !onInstantiateFunctions[ moduleId ] ){
          onInstantiateFunctions[ moduleId ] = [];
        }
        onInstantiateFunctions[ moduleId ].push( fn );

      }else{
        onInstantiateFunctions['_always'].push( fn );
      }
    }else{
      error( "onInstantiate expect a function as parameter", name );
    }
  };

  /**
   * PrivateFunction: createInstance
   * Creates a new instance of a module.
   *
   * Parameters:
   * (String) moduleId    - The ID of a registered module.
   * (String) instanceId  - The ID of the instance that will be created.
   * (Object) opt         - An object that holds specific options for the module.
   * (Function) opt       - Callback function.
   */
  var createInstance = function( moduleId, instanceId, opt, success, error ){

    var mod = modules[ moduleId ];

    var instance;

    var callSuccess = function(){
      if( typeof success === "function" ){
        success( instance );
      }else{
        warn(" callback function is not a function", name );
      }
    };

    var callError = function(){
      if( typeof error === "function" ){ error( instance ); }
    };

    if( mod ){

      // Merge default options and instance options,
      // without modifying the defaults.
      var instanceOpts = { };
      $.extend( true, instanceOpts, mod['opt'], opt );

      var sb = new that['sandbox']( instanceId, instanceOpts );

      // add plugins
      $.each( plugins, function( id, plugin ){
        var p = new plugin( sb, instanceId );
        $.extend( true, sb, p );
      });

      instance = mod['creator']( sb );

      // store opt
      instance['opt'] = instanceOpts;

      callInstantiateFunctions( moduleId, instanceId, instanceOpts, sb )
        .done( function(){ callSuccess(); })
        .fail( function( err ){ callError( err ); });

    } else {
       error( "could not start module '" + moduleId +
        "' - module does not exist.", name );
    }
  };

  /**
   * PrivateFunction: callInstantiateFunctions
   *
   * Parameters:
   * (String) id  - The instance ID
   * (Object) opt - The instance option object
   * (Object) sb  - The sandbox
   */
  var callInstantiateFunctions = function( moduleId, instanceId, opt, sb ){

    var dfd = $.Deferred();
    var deferreds = [];

    var addToDeferreds = function( functions ){
      $.each( functions, function( i, fn ){
        deferreds.push( fn( instanceId, opt, sb ) );
      });
    };

    addToDeferreds( onInstantiateFunctions['_always'] );

    if( onInstantiateFunctions[ moduleId ] ){
      addToDeferreds( onInstantiateFunctions[ moduleId ] );
    }

    $.when.apply( null, deferreds ).done(function(){ dfd.resolve(); });

    return dfd.promise();
  };

  /**
   * PrivateFunction: checkOptionObject
   * Checks whether the passed option object is valid or not.
   *
   * Parameters:
   * (Object) opt - The option object
   *
   * Returns:
   * (Boolean) valid - False if it is not valid, true if everything is ok.
   */
  var checkOptionObject = function( opt ){

    if( typeof opt !== "object" ){
      error( "could not register module - " +
        "option has to be an object", name );
      return false;
    }
    if( opt['views'] ){
      if( typeof opt['views'] !== "object" ){ return false; }
    }

    if( opt['models'] ){
      if( typeof opt['models'] !== "object" ){ return false; }
    }

    return true;
  };

  /**
   * PrivateFunction: checkRegisterParameters
   *
   * Parameters:
   * (String) moduleId  - The module ID
   * (Function) creator - The creator function
   * (Object) opt       - The option object
   *
   * Returns:
   * (Boolean) ok - True if everything is ok.
   */
  var checkRegisterParameters = function( moduleId, creator, opt  ){

    var errString = "could not register module";

    if( typeof moduleId !== "string" ){
      error( errString + "- mouduleId has to be a string", name );
      return false;
    }
    if( typeof creator !== "function" ){
      error( errString + " - creator has to be a constructor function", name );
      return false;
    }

    var modObj = creator();

    if( typeof modObj             !== "object"   ||
        typeof modObj['init']     !== "function" ||
        typeof modObj['destroy']  !== "function" ){
      error( errString + " - creator has to return an object with the functions 'init' and 'destroy'", name );
      return false;
    }

    if( opt ){
      if( !checkOptionObject( opt ) ){ return false; }
    }

    return true;

  };

  /**
   * Function: register
   * Registers a new module.
   *
   * Parameters:
   * (String) moduleId  - The module id
   * (Function) creator - The module creator function
   * (Object) ops       - The default options for this module
   *
   * Returns:
   * (Boolean) success  - True if registration was successfull.
   */
  var register = function( moduleId, creator, opt ){

    if( !checkRegisterParameters( moduleId, creator, opt  ) ){ return false; }

    if( !opt ){ opt = {}; }

    modules[ moduleId ] = {
      'creator': creator,
      'opt': opt
    };

    return true;
  };

  /**
   * PrivateFunction: hasValidStartParameter
   *
   * Parameters:
   * (String) moduleId
   * (String) instanceId
   * (Object) opt
   *
   * Returns:
   * True, if parameters are valid.
   */
  var hasValidStartParameter = function( moduleId, instanceId, opt ){

    return ( ( typeof moduleId === "string" ) &&
        (
          ( typeof instanceId === "string" && !opt )      ||
          ( typeof instanceId === "object" && !opt )      ||
          ( typeof instanceId === "string" && typeof opt === "object" ) ||
          ( !instanceId  &&  !opt )
        )
      ) || ( $.isArray( moduleId ) && !instanceId && !opt ) ;
  };

  /**
   * PrivateFunction: getSuitedParamaters
   *
   * Parameters:
   * (String) moduleId
   * (String) instanceId
   * (Object) opt
   *
   * Returns:
   * Object with parameters
   */
  var getSuitedParamaters = function( moduleId, instanceId, opt ){

    if( typeof instanceId === "object" && !opt ){
      // no instance id was specified, so use module id instead
      opt = instanceId;
      instanceId = moduleId;
    }
    if( !instanceId && !opt ){
      instanceId = moduleId;
      opt = {};
    }
    return { 'moduleId': moduleId, 'instanceId': instanceId, 'opt': opt };
  };

  /**
   * PrivateFunction: regularStart
   *
   * Parameters:
   * (String) moduleId    -
   * (String) instanceId  -
   * (Object) opt         -
   * (Function) callback  -
   */
  var regularStart = function( moduleId, instanceId, opt, callback ){

    var p = getSuitedParamaters( moduleId, instanceId, opt );

    if( p ){

      debug( "start '" + p['moduleId'] + "'", name );

      var onSuccess = function( instance ){
        instances[ p['instanceId'] ] = instance;
        instance['init']( instance['opt'] );
        if( typeof callback === "function" ){
          callback();
        }
      };
      createInstance( p['moduleId'], p['instanceId'], p['opt'], onSuccess );
      return true;
    }
    return false;
  };

  /**
   * Function: start
   * Starts a module.
   *
   * Parameters:
   * (String) moduleId    - The module ID
   * (String) instanceId  - The instance ID
   * (Object) opt         - The option object
   */
  var start = function( moduleId, instanceId, opt, callback ){

    if( hasValidStartParameter( moduleId, instanceId, opt ) ){

      return regularStart( moduleId, instanceId, opt, callback );

    }else{
      error( "could not start module '" + moduleId + "' - illegal arguments.", name );
      return false;
    }
  };


  /**
   * PrivateFunction: startSubModule
   *
   * Parameters:
   * (String) moduleId
   * (String) parentInstanceId
   * (String) instanceId
   * (Object) opt
   * (Function) callback
   */
  var startSubModule = function( moduleId, instanceId, opt, parentInstanceId, callback ){

    var p = getSuitedParamaters( moduleId, instanceId, opt );

    if( start( p['moduleId'], p['instanceId'], p['opt'], callback ) &&
      typeof parentInstanceId === "string" ){

      var sub = subInstances[ parentInstanceId ];
      if( !sub ){
        sub = [ ];
      }
      sub.push( p['instanceId'] );
    }
  };

  /**
   * Function: stop
   * Stops a module.
   *
   * Parameters:
   * (String) instanceId  - The instance ID
   */
  var stop = function( instanceId ){

    var instance = instances[ instanceId ];

    if( instance ){
      instance['destroy']();
      delete instances[ instanceId ];

      $.each( subInstances[ instanceId ], function( i, instance ){
        if( instance){ stop( instance ); }
      });
    }else{
      error( "could not stop instance '" + instanceId +
        "' - instance does not exist.", name );
      return false;
    }
  };

  /**
   * Function: startAll
   * Starts all available modules.
   *
   * Parameters:
   * (Function) fn  - The Function that gets called after all modules where initialized.
   * (Array) array  - Array of module ids that shell be started.
   */
  var startAll = function( fn, array ){

    var couldNotStartModuleStr = "Could not start module";

    var callback = function(){};

    if( typeof fn === "function" ){

      var count = 0;
      if( $.isArray( array ) ){
        count = array.length;
      }else{
        count = that['util']['countObjectKeys']( modules );
      }
      callback = function(){
        count --;
        if( count === 0 ){
          fn();
        }
      };
    }

    if( $.isArray( array ) ){
      $.each( array, function( i, id ){
        if( typeof id === "string" ){
          start( id, id, modules[ id ]['opt'], callback );
        }
        else if( typeof id === "object" ){
          if( id.moduleId && id.opt ){
            start( id.moduleId, id.instanceId, id.opt, callback );
          }else{
            error(
            couldNotStartModuleStr + " from array - invalid parameters", name );
          }
        }
        else{
          error( couldNotStartModuleStr + " from array", name );
        }
      });

    }else{
      $.each( modules, function( id, module ){
        if( module ){ start( id, id, module['opt'], callback ); }
      });
    }
  };


  /**
   * Function: stopAll
   * Stops all available instances.
   */
  var stopAll = function(){ $.each( instances, function( id, inst ){ stop( id ); }); };

  /**
   * PrivateFunction: publish
   *
   * Parameters:
   * (String) topic             - The topic name
   * (Object) data              - The data that gets published
   * (Boolean) publishReference - If the data should be passed as a reference to
   *                              the other modules this parameter has to be set
   *                              to *true*.
   *                              By default the data object gets copied so that
   *                              other modules can't influence the original
   *                              object.
   */
  var publish = function( topic, data, publishReference ){

    $.each( instances, function( i, instance ){

      if( instance['subscriptions'] ){

        var handlers = instance['subscriptions'][ topic ];

        if( handlers ){
          $.each( handlers, function( i, h ){
            if( typeof h === "function" ){
              if( typeof data === "object" && publishReference !== true ){
                var copy = {};
                $.extend( true, copy, data );
                h( copy, topic );
              }else {
                h( data, topic );
              }
            }
          });
        }
      }
    });
  };

  /**
   * PrivateFunction: subscribe
   *
   * Parameters:
   * (String) topic
   * (Function) handler
   */
  var subscribe = function( instanceId, topic, handler ){

    debug( "subscribe to '" + topic + "'", instanceId );

    var instance = instances[ instanceId ];

    if( !instance['subscriptions'] ){
      instance['subscriptions'] = { };
    }
    var subs = instance['subscriptions'];

    if( !subs[ topic ] ){
      subs[ topic ] = [];
    }
    subs[ topic ].push( handler );
  };

  /**
   * PrivateFunction: unsubscribe
   *
   * Parameters:
   * (String) instanceId
   * (String) topic
   */
  var unsubscribe = function( instanceId, topic ){

    var subs = instances[ instanceId ]['subscriptions'];
    if( subs ){
      if( subs[ topic ] ){
        delete subs[ topic ];
      }
    }
  };

  /**
   * PrivateFunction: getInstances
   *
   * Parameters:
   * (String) id
   *
   * Returns:
   * Instance
   */
  var getInstance = function( id ){
    return instances[ id ];
  };

  /**
   * PrivateFunction: getContainer
   */
  var getContainer = function( instanceId ){

    var o = instances[ instanceId ]['opt'];

    if( o ){
      if( typeof o['container'] === "string" ){
        return $( "#" + o['container'] );
      }
    }
    return $( "#" + instanceId );
  };

  var registerPlugin = function( id, plugin ){

    if( typeof id === "string" && typeof plugin == "object" ){

      if( typeof plugin['sandbox'] === "function" ){
        plugins[ id ] = plugins[ id ] || plugin['sandbox'];
      }
      if( typeof plugin['core'] === "function" || typeof plugin['core'] === "object" ){
        that['util']['mixin']( that, plugin['core'], true );
      }
      if( typeof plugin['onInstantiate'] === "function" ){
        onInstantiate( plugin['onInstantiate'] );
      }
    }else{
      error( "registerPlugin expect an id and an object as parameters", name );
    }

  };

  // public core API
  that = ({

    'register': register,
    'onInstantiate':onInstantiate,

    'registerPlugin': registerPlugin,

    'start': start,
    'startSubModule': startSubModule,
    'stop': stop,
    'startAll': startAll,
    'stopAll': stopAll,

    'publish': publish,
    'subscribe': subscribe,

    'getContainer': getContainer,

    'getInstance': getInstance,

    'log': log

  });

  window[ name ] = window[ name ] || that;

}( window, 'scaleApp' ));
