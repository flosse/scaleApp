/**
 * Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)
 */

/**
 * File: scaleApp.sandbox.js
 * 
 * It is licensed under the MIT licence.
 */

/**
 * Class: scaleApp.sandbox
 * 
 * Parameters:
 * (Object) core
 * (String) instanceId
 * (Object) opt
 */
scaleApp.sandbox = scaleApp.sandbox || (function( window, core, undefined ){
  
    return function( instanceId, opt ){
	      
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
    
    /**
      * Function: startSubModule
      * 
      * Parameters:
      * (String) moduleId
      * (String) subInstanceId
      * (Object) opt
      */    
    var startSubModule = function( moduleId, subInstanceId, opt ){
      core.startSubModule( moduleId, subInstanceId, opt, instanceId );
    };
    
    /**
      * Function: stopSubModule
      * 
      * Parameters:
      * (String) instanceId
      */    
    var stopSubModule = function( instanceId ){
      core.stop( instanceId );
    };
    
    /**
      * Function: getModel
      * 
      * Paraneters:
      * (String) id
      * 
      * Returns:
      * (Object) model
      */    
    var getModel = function( id ){
      return core.mvc.getModel( instanceId, id );
    };
    
    /**
      * Function: getView
      * 
      * Paraneters:
      * (String) id
      * 
      * Returns:
      * (Object) view
      */    
    var getView = function( id ){
      return core.mvc.getView( instanceId, id );
    };
    
    /**
      * Function: getController
      * 
      * Paraneters:
      * (String) id
      * 
      * Returns:
      * (Object) controller
      */      
    var getController = function( id ){
      return core.mvc.getController( instanceId, id );
    };
    
    
    var addModel = function( id , model ){
      return core.mvc.addModel( instanceId, id, model );
    };
    
    
    var addView = function( id, view ){
      return core.mvc.addView( instanceId, id, view );
    };
    
    var addController = function( id, controller ){
      return core.mvc.addController( instanceId, id, controller );
    };
    
    /**
    * Function: getTemplate
    * 
    * Parameters:
    * (String) id   
    * 
    * Returns:
    * (Object) pre-rendered jQuery template
    */
    var getTemplate = function( id ){    
      return core.getTemplate( instanceId, id );
    };
    
    /**
    * Function: tmpl
    * 
    * Parameters:
    * (String) id
    * (Object) data
    */  
    var tmpl = function( id, data ){      
      return $.tmpl( getTemplate( id ), data );  
    };
      
    /**
      * Function: _
      * 
      * Parameters:
      * (String) textId 
      * 
      * Returns:
      * The localized text.
      */    
    var _ = function( textId ){
      return core.i18n._( instanceId, textId );
    };
    
    /**
    * Function: getContainer
    */  
    var getContainer = function(){
      return core.getContainer( instanceId );
    };
  
      /**
      * Function: hotkeys
      * Binds a function to hotkeys. 
      * If an topic as string and data is used instead of the function the data gets published.
      * 
      * Parameters:
      * (String) keys
      * (Function) handler
      * (String) type
      */
    var hotkeys = function( keys, handler, type, opt ){
      
      // if user wants to publish s.th. directly
      if( typeof handler === "string" ){

	// in this case 'handler' holds the topic, 'type' the data and 'opt' the type.
	if( !opt ){ opt = "keypress"; }
	
	$(document).bind( opt, keys, function(){	  
	  publish( handler, type );  
	});
	
      }            
      else if( typeof handler === "function" ){

	if( !type ){ type = "keypress"; }
		
	$(document).bind( type, keys, handler );	
      }
      
    };
    
    // public sandbox api    
    return {
      
      subscribe: subscribe,
      unsubscribe: unsubscribe,
      publish: publish,

      startSubModule: startSubModule,
      stopSubModule: stopSubModule,
      
      getModel: getModel,
      getView: getView,
      getController: getController,
      
      addModel: addModel,
      addView: addView,
      addController: addController,
      
      observable: core.mvc.observable,
      
      getTemplate: getTemplate,
      tmpl: tmpl,
      
      getContainer: getContainer,
      
      debug: log.debug,
      info: log.info,
      warn: log.warn,
      error: log.error,
      fatal: log.fatal,      
      
      mixin: core.mixin,
      
      _:_,
      
      hotkeys: hotkeys
      
    };
    
  };        
})( window, scaleApp );