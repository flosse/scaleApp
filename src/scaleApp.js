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
        
    // Container for all templates    
    var templates = { };
    
    // Container for all functions that gets called when an instance gets created
    var onInstantiateFunctions = [];
        
    // define a dummy object for logging.
    var log = {
      debug: function(){ return; },
      info:  function(){ return; },
      warn:  function(){ return; },
      error: function(){ return; },
      fatal: function(){ return; }
    };
    
    /**
     * Function: onInstantiate
     * 
     * Parameters:
     * (Function) fn
     */    
    var onInstantiate = function( fn ){
      if( typeof fn === "function" ){
	onInstantiateFunctions.push( fn );
      }else{
	that.log.error("scaleApp.onInstantiate expect a function as parameter", "core" );
      }
    };
            
    /**
     * PrivateFunction: createInstance
     * Creates a new instance of a module.
     * 
     * Parameters:
     * (String) moduleId	- The ID of a registered module.
     * (String) instanceId	- The ID of the instance that will be created.
     * (Object) opt		- The object that holds specific options for the module.
     * (Function) opt		- Callback function.
     */
    var createInstance = function( moduleId, instanceId, opt, success, error ){
      
      var mod = modules[ moduleId ];
      
      var instance;
      
      var callSuccess = function(){
	if( typeof success === "function" ){ success( instance ); }
      };
      
      var callError = function(){
	if( typeof error === "function" ){ error( instance ); }
      };
      
      if( mod ){
	
	// Merge default options and instance options, without modifying the defaults.	      
	var instanceOpts = { };
	$.extend( true, instanceOpts, mod.opt, opt );
	
	var sb = new that.sandbox( that, instanceId, instanceOpts );
	
	instance = mod.creator( sb );
	
	// store opt
	instance.opt = instanceOpts;

	for( var i in onInstantiateFunctions ){
	  onInstantiateFunctions[i]( instanceId, instanceOpts, sb );
	}
	
	if( instanceOpts.templates ){
	  
	  loadTemplates( instanceId, instanceOpts.templates, 
	    function(){  
	      delete instanceOpts.templates;    
	      that.log.debug("templates loaded");
	      callSuccess();
	    },
	    function( err ){
	      delete instanceOpts.templates;
	      callError( err );
	    }
	  );
	  
	}else{
	  callSuccess();
	}
      } else {
	that.log.error( "could not start module '" + moduleId + "' - module does not exist.", "core" );
      } 
    };
    
    /**
     * PrivateFunction: checkOptionObject
     * Checks whether the passed option object is valid or not.
     * 
     * Parameters:
     * (Object) opt
     * 
     * Returns:
     * False if it is not valid, true if everything is ok.
     */
    var checkOptionObject = function( opt ){
      
      var errString = "could not register module";
      
      if( typeof opt !== "object" ){
	that.log.error( errString + " - option has to be an object", "core" );
	return false;
      }
      return true;
    };
      
    
    /**
     * PrivateFunction: checkRegisterParameters
     * 
     * Parameters:
     * (String) moduleId 
     * (Function) creator
     * (Object) opt
     * 
     * Returns:
     * True if everything is ok.
     */
    var checkRegisterParameters = function( moduleId, creator, opt  ){
      
      var errString = "could not register module";
      
      if( typeof moduleId !== "string" ){	
	that.log.error( errString + "- mouduleId has to be a string", "core" );
	return false;
      }      
      if( typeof creator !== "function" ){
	that.log.error( errString + " - creator has to be a constructor function", "core" );
	return false;
      }      
      
      var modObj = creator();
      
      if( typeof modObj !== "object" || typeof modObj.init !== "function" || typeof modObj.destroy !== "function" ){
	that.log.error( errString + " - creator has to return an object with the functions 'init' and 'destroy'", "core" );
	return false;           
      }
      
      if( opt ){
	if( !checkOptionObject( opt ) ){ return false; }
      }
      
      return true;
      
    };
    
    /**
     * Function: register
     * 
     * Parameters:
     * (String) moduleId	- The module id
     * (Function) creator	- The module creator function
     * (Object) ops		- The default options for this module 
     * 
     * Returns:
     * True if registration was successfull.
     */    
    var register = function( moduleId, creator, opt ){
      
      if( !checkRegisterParameters( moduleId, creator, opt  ) ){ return false; }  
      
      if( !opt ){ opt = {}; }
      
      modules[ moduleId ] = {
	creator: creator,
	opt: opt
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
	
	var onSuccess = function( instance ){
	  instances[ p.instanceId ] = instance;
	  instance.init();  
	};
	createInstance( p.moduleId, p.instanceId, p.opt, onSuccess );
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
     * Function: startAll
     * Starts all available modules.
     */
    var startAll = function(){
      for( var id in modules ){
	if( modules[ id ] ){
	  start( id, id, modules[ id ].opt );
	}
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
		handlers[j]( topic, data );
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
        
     /**
     * PrivateFunction: loadTemplates
     * 
     * Paraneters:
     * (String) instanceId
     * (Object) templates
     * (Function) success
     * (Function) error
     */    
    var loadTemplates = function( instanceId, templates, success, error ){
      
      that.log.debug("loading templates...");
      var counter = 0;
      
      var onFail = function( err ){
	
	counter--;
	
	if( typeof error === "function" ){ 
	  error( err ); 	  
	}else{
	  that.log.error("could not load template:" + err , "core" );
	}
	
	if( counter < 1 && typeof success === "function" ){
	  success();
	}
      };
      
      var onSuccess = function(){
	that.log.debug("template loading successfull")      
	counter--;
	that.log.debug( counter + " templates left");
	if( counter < 1 && typeof success === "function" ){
	  success();
	}
      };

      for( var k in templates ){
	counter++;
	addTemplate( instanceId, k, templates[k], onSuccess, onFail );
      }
    };

    /**
     * PrivateFunction: addTemplate
     * 
     * Paraneters:
     * (String) instanceId
     * (String) id
     * (String) tmpl - path to the template
     */
    var addTemplate = function( instanceId, id, tmpl, success, error ){
      
      if( !templates[ instanceId ] ){
	templates[ instanceId ] = { };
      }
      
      var onSuccess = function( html ){
	templates[ instanceId ][ id ] = $('<script type="text/x-jquery-tmpl">'+ html + '</script>').template();
	if( typeof success === "function" ){ success(); }
      };
      
      var onFail = function( err ){
	if( typeof error === "function" ){ 
	  error( err );
	}else{
	  that.log.error("could not load template:" + err , "core" );  
	}
      };
      
      if( typeof tmpl === "string" ){	
	$.get( tmpl, onSuccess );
      }
    };
    
    /**
     * Function: getTemplate
     * 
     * Paraneters:
     * (String) instanceId
     * (String) id
     * 
     * Returns:
     * (Object) template - the pre-rendered jQuery template object
     */    
    var getTemplate = function( instanceId, id ){
      
      var t = templates[ instanceId ];
      
      if( t ){
	      
	if( !id && $(t).length == 1 ){
	  for( var one in t ) break;
	  return t[ one ];
	}      
	
	return t[ id ];
      }
    };
    
    
    /**
     * Function: getContainer      
     */     
    var getContainer = function( instanceId ){
      
      var o = instances[ instanceId ].opt;
      
      if( o ){
	if( typeof o.container === "string" ){
	  return $( "#" + o.container );  
	}
      }
      return $( "#" + instanceId );      
    };
        
    // public core API
    that = {
      
      register: register,
      onInstantiate:onInstantiate,
      
      start: start,
      startSubModule: startSubModule,
      stop: stop,
      startAll: startAll,
      stopAll: stopAll,
                  
      publish: publish,
      subscribe: subscribe,
            
      getTemplate: getTemplate,  
      
      getContainer: getContainer,
      
      getInstance: getInstance,
      
      log: log      
      
    };
    
    return that;
    
  })();
  
  return core;
  
})();