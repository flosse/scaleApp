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
        
    // Container for all registered modules           
    var modules = { };
    
    // Container for all module instances
    var instances = { };
        
    /**
     * PrivateFunction: log
     * 
     * Parameters:
     * (String) level
     * (String) msg
     * (String) module
     */
    var log = function( level, msg, module ){
      
      if( module ){
	msg = module + ": " + msg;
      }      
      console[ level ](	msg );
    };
    
    // logging functions, each for a different level
    var debug =	function( msg, module ){ log("debug", msg, module ); };
    var info  =	function( msg, module ){ log("info",  msg, module ); };
    var warn  =	function( msg, module ){ log("warn",  msg, module ); };
    var error =	function( msg, module ){ log("error", msg, module ); };
    var fatal =	function( msg, module ){ log("fatal", msg, module ); };    
    
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
      
      // Merge default options and instance options, without modifying the defaults.
      var instanceOpts = { };
      $.extend( true, instanceOpts, mod.opt, opt ); 
      
      return mod.creator( new sandbox( api, instanceId, instanceOpts ) );                 
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
	  opt: { }
	};
      } 
      else {
	error( "could not register module - illegal arguments", "core" );
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
      
      return	( typeof moduleId === "string" && typeof instanceId === "string" && typeof opt === "object" ) ||
		( typeof moduleId === "string" && typeof instanceId === "object" &&  !opt ) ||      
		( typeof moduleId === "string" && !instanceId  &&  !opt );
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
      
      if( hasValidStartParameter( moduleId, instanceId, opt ) ){
		
	if( modules[ moduleId ] ){
	      
	  if( typeof instanceId === "object" && !opt ){		    
	    // no instance id was specified, so use module id instead	
	    opt = instanceId;
	    instanceId = moduleId;
	  }
	  if( !instanceId && !opt ){	    
	    instanceId = moduleId;
	    opt = {};
	  }
	  
	  instances[ instanceId  ] = createInstance( moduleId, instanceId, opt );
	  instances[ instanceId ].init();
	  
	} else{
	  error( "could not start module '" + moduleId + "' - module does not exist.", "core" );
	}
      } else {
	error( "could not start module '"+ moduleId +"' - illegal arguments.", "core" );
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
	instances[ instanceId ] = null;
      }else{
	error( "could not stop instance '" + instanceId + "' - instance does not exist.", "core" );
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
	      handlers[j]( data );
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
    
    
    var api = {
      
      register: register,
      
      start: start,
      stop: stop,
      stopAll: stopAll,
      
      debug: debug,
      info: info,
      warn: warn,
      error: error,
      fatal: fatal,
      
      publish: publish,
      subscribe: subscribe
    };
    
    return api;
    
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
	core.debug( msg, instanceId );
      },

      /**
      * Function: info
      * 
      * Parameters:
      * (String) msg     
      */    
      info: function( msg ){
	core.info( msg, instanceId );
      },
      
      /**
      * Function: warn
      * 
      * Parameters:
      * (String) msg     
      */          
      warn: function( msg ){
	core.warn( msg, instanceId );
      },
      
      /**
      * Function: error
      * 
      * Parameters:
      * (String) msg     
      */          
      error: function( msg ){
	core.error( msg, instanceId );
      },
      
      /**
      * Function: fatal
      * 
      * Parameters:
      * (String) msg     
      */          
      fatal: function( msg ){
	core.fatal( msg, instanceId );
      }
    };
    
    return {
      
      subscribe: subscribe,
      unsubscribe: unsubscribe,
      publish: publish,
      
      debug: log.debug,
      info: log.info,
      warn: log.warn,
      error: log.error,
      fatal: log.fatal
      
    };
        
  };
  
  return core;
  
})();