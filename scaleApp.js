/**
 * Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)
 */

/**
 * File: scaleApp.js
 * scaleApp is a tiny framework for One-Page-Applications. 
 * It is licensed under the MIT licence.
 */
var scaleApp = (function(){
  
  /**
   * Class: core
   * The core holds and manages all data that is used globally.
   */
  var core = (function(){
               
    // container for public API and reference to this
    var that = { };
    
    // Container for all registered modules           
    var modules = { };
    
    // Container for all module instances
    var instances = { };
    
    // Container for lists of submodules
    var subInstances = { };
    
    // define a dummy object for logging.
    var log = {
      debug: function(){ return; },
      info:  function(){ return; },
      warn:  function(){ return; },
      error: function(){ return; },
      fatal: function(){ return; }
    };
            
    /**
     * PrivateFunction: createInstance
     * Creates a new instance of a module.
     * 
     * Parameters:
     * (String) moduleId	- The ID of a registered module.
     * (String) instanceId	- The ID of the instance that will be created.
     * (Object) opt		- The object that holds specific options for the module.
     */
    var createInstance = function( moduleId, instanceId, opt ){
      
      var mod = modules[ moduleId ];
      
      if( mod ){
	
	// Merge default options and instance options, without modifying the defaults.	      
	var instanceOpts = { };
	$.extend( true, instanceOpts, mod.opt, opt );
	
	var instance = mod.creator( new sandbox( that, instanceId, instanceOpts ) );
	
	// store opt
	instance.opt = instanceOpts;
	
	return instance;
	
      } else {
	that.log.error( "could not start module '" + moduleId + "' - module does not exist.", "core" );
      } 
    };
    
    /**
     * Function: register
     * 
     * Parameters:
     * (String) moduleId	- The module id
     * (Function) creator	- The module creator function
     * (Object) ops		- The default options for this module 
     */    
    var register = function( moduleId, creator, opt ){
            
      if( typeof moduleId === "string" && typeof creator === "function" ){
	     
	if( !opt ){ opt = {}; }
	      
	modules[ moduleId ] = {
	  creator: creator,
	  opt: opt
	};
      } 
      else {
	that.log.error( "could not register module - illegal arguments", "core" );
      }
      
    };
    
    /**
     * PrivateFunction: hasValidStartParameter
     * 
     * Parameters:
     * (String) moduleId
     * (String) instanceId
     * (Object) opt
     * 
     */    
    var hasValidStartParameter = function( moduleId, instanceId, opt ){
      
      return	( typeof moduleId === "string" ) && (
		  ( typeof instanceId === "string" && !opt )			||
		  ( typeof instanceId === "object" && !opt )			||      
		  ( typeof instanceId === "string" && typeof opt === "object" ) ||
		  ( !instanceId  &&  !opt )
		);
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

      if( hasValidStartParameter( moduleId, instanceId, opt ) ){
	if( typeof instanceId === "object" && !opt ){		    
	  // no instance id was specified, so use module id instead	
	  opt = instanceId;
	  instanceId = moduleId;
	}
	if( !instanceId && !opt ){	    
	  instanceId = moduleId;
	  opt = {};
	}      
	return { moduleId: moduleId, instanceId: instanceId, opt: opt };	
      }
      that.log.error( "could not start module '"+ moduleId +"' - illegal arguments.", "core" );
      return;
    };
    
    
    /**
     * Function: start
     * 
     * Parameters:
     * (String) moduleId
     * (String) instanceId
     * (Object) opt
     */    
    var start = function( moduleId, instanceId, opt ){
                  
      var p = getSuitedParamaters( moduleId, instanceId, opt );      
      if( p ){	
	
	that.log.debug( "start '" + p.moduleId + "'", "core" );
	
	instances[ p.instanceId ] = createInstance( p.moduleId, p.instanceId, p.opt );
	instances[ p.instanceId ].init();
	
	return true;
      }      
      return false;
    };
        
    /**
     * Function: startSubModule
     * 
     * Parameters:
     * (String) moduleId
     * (String) parentInstanceId
     * (String) instanceId
     * (Object) opt
     */    
    var startSubModule = function( moduleId, instanceId, opt, parentInstanceId ){
                  
      var p = getSuitedParamaters( moduleId, instanceId, opt ); 
      if( start( p.moduleId, p.instanceId, p.opt ) && typeof parentInstanceId === "string" ){
	      
	var sub = subInstances[ parentInstanceId ];
	if( !sub ){
	  sub = [ ];
	}
	sub.push( p.instanceId );
      }      
    };
    
    /**
     * Function: stop
     * 
     * Parameters:
     * (String) instanceId
     */    
    var stop = function( instanceId ){
      
      var instance = instances[ instanceId ];
      
      if( instance ){
	instance.destroy();
	delete instances[ instanceId ];
	
	for( var i in subInstances[ instanceId ] ){
	  if( subInstances[ instanceId ][i] ){
	    stop( subInstances[ instanceId ][i] );	    
	  }
	}	
      }else{
	that.log.error( "could not stop instance '" + instanceId + "' - instance does not exist.", "core" );
	return;
      }
    };
    
    
    /**
     * Function: stopAll
     * Stops all available instances.
     */
    var stopAll = function(){
      for( var id in instances ){
	if( instances.hasOwnProperty( id ) ){
	  stop( id );
	}
      }
    };
    
    /**
     * PrivateFunction: publish
     * 
     * Parameters:
     * (String) topic
     * (Object) data      
     */
    var publish = function( topic, data ){

      for( var i in instances ){
	
	if( instances[i].subscriptions ){
  
	  var handlers = instances[i].subscriptions[ topic ];
	  
	  if( handlers ){
	    for( var j in handlers ){
	      if( typeof handlers[j] === "function" ){
		handlers[j]( data );		
	      }
	    }
	  }  
	}
      }      
    };
    
    /**
     * PrivateFunction: subscribe
     * 
     * Parameters:
     * (String) topic
     * (Function) handler
     */
    var subscribe = function( instanceId, topic, handler ){
      
      that.log.debug( "subscribe to '" + topic + "'", instanceId );
      
      var instance = instances[ instanceId ];
                              
      if( !instance.subscriptions ){
	instance.subscriptions = { };
      }
      var subs = instance.subscriptions;
      
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

      var subs = instances[ instanceId ].subscriptions;
      if( subs ){
	if( subs[ topic ] ){
	  delete subs[ topic ];
	}
      }
    };
    
    /**
     * Function: getInstances
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
    
    // public API
    that = {
      
      register: register,
      
      start: start,
      startSubModule: startSubModule,
      stop: stop,
      stopAll: stopAll,
                  
      publish: publish,
      subscribe: subscribe,
      
      getInstance: getInstance,
      
      log: log      
      
    };
    
    return that;
    
  })();
  
  /**
   * Class: sandbox
   * 
   * Parameters:
   * (Object) core
   * (String) instanceId
   * (Object) opt
   */
  var sandbox = function( core, instanceId, opt ){
            
    /**
     * Function: subscribe
     * 
     * Parameters:
     * (String) topic
     * (Function) callback
     */
    
    var subscribe = function( topic, callback ){            
      core.subscribe( instanceId, topic, callback );
    };
    
    /**
     * Function: unsubscribe
     * 
     * Parameters:
     * (String) topic    
     */
    var unsubscribe = function( topic ){      
      core.unsubscribe( instanceId, topic );
    };

    /**
     * Function: publish
     * 
     * Parameters:
     * (String) topic
     * (Object) data
     */
    var publish = function( topic, data ){      
      core.publish( topic, data );
    };
    
    var log = {
      
      /**
      * Function: debug
      * 
      * Parameters:
      * (String) msg     
      */      
      debug: function( msg ){
	core.log.debug( msg, instanceId );
      },

      /**
      * Function: info
      * 
      * Parameters:
      * (String) msg     
      */    
      info: function( msg ){
	core.log.info( msg, instanceId );
      },
      
      /**
      * Function: warn
      * 
      * Parameters:
      * (String) msg     
      */          
      warn: function( msg ){
	core.log.warn( msg, instanceId );
      },
      
      /**
      * Function: error
      * 
      * Parameters:
      * (String) msg     
      */          
      error: function( msg ){
	core.log.error( msg, instanceId );
      },
      
      /**
      * Function: fatal
      * 
      * Parameters:
      * (String) msg     
      */          
      fatal: function( msg ){
	core.log.fatal( msg, instanceId );
      }
    };
    
    var startSubModule = function( moduleId, subInstanceId, opt ){
      core.startSubModule( moduleId, subInstanceId, opt, instanceId );
    };
    
    var stopSubModule = function( instanceId ){
      core.stop( instanceId );
    };
     
    /**
     * Function: _

     * Parameters:
     * (String) textId 
     */    
    var _ = function( textId ){
      return core.i18n._( instanceId, textId );
    };
    
    return {
      
      subscribe: subscribe,
      unsubscribe: unsubscribe,
      publish: publish,
      
      startSubModule: startSubModule,
      stopSubModule: stopSubModule,
      
      debug: log.debug,
      info: log.info,
      warn: log.warn,
      error: log.error,
      fatal: log.fatal,      
      
      _:_
      
    };
        
  };
  
  return core;
  
})();