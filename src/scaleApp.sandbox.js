/**
 * Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)
 */

/**
 * Class: sandbox
 */
(function( window, core, undefined ){

 core['sandbox'] = core['sandbox'] || function( instanceId, opt ){

    /**
      * Function: subscribe
      * Subscribe to a topic.
      *
      * Parameters:
      * (String) topic      - The topic name
      * (Function) callback - The function that gets called if an other module publishes to the specified topic 
      */
    var subscribe = function( topic, callback ){
      core['subscribe']( instanceId, topic, callback );
    };

    /**
      * Function: unsubscribe
      * Unsubscribe from a topic
      *
      * Parameters:
      * (String) topic  - The topic name
      */
    var unsubscribe = function( topic ){
      core['unsubscribe']( instanceId, topic );
    };

    /**
     * Function: publish
     * Publish an event.
     *
     * Parameters:
     * (String) topic             - The topic name
     * (Object) data              - The data you want to publish
     * (Boolean) publishReference - If the data should be passed as a reference to
     *                              the other modules this parameter has to be set
     *                              to *true*. 
     *                              By default the data object gets copied so that
     *                              other modules can't influence the original 
     *                              object. 
     */
    var publish = function( topic, data, publishReference ){
      core['publish']( topic, data, publishReference );
    };

    var log = {

      /**
      * Function: debug
      * Log function for debugging.
      *
      * Parameters:
      * (String) msg  - The log message
      */
      debug: function( msg ){
        core['log']['debug']( msg, instanceId );
      },

      /**
      * Function: info
      * Log function for informational messages.
      *
      * Parameters:
      * (String) msg  - The log message
      */
      info: function( msg ){
        core['log']['info']( msg, instanceId );
      },

      /**
      * Function: warn
      * Log function for warn messages.
      *
      * Parameters:
      * (String) msg  - The log message
      */
      warn: function( msg ){
        core['log']['warn']( msg, instanceId );
      },

      /**
      * Function: error
      * Log function for error messages.
      *
      * Parameters:
      * (String) msg  - The log message
      */
      error: function( msg ){
        core['log']['error']( msg, instanceId );
      },

      /**
      * Function: fatal
      * Log function for fatal messages.
      *
      * Parameters:
      * (String) msg  - The log message
      */
      fatal: function( msg ){
        core['log']['fatal']( msg, instanceId );
      }
    };

    /**
      * Function: startSubModule
      * Start a submodule.
      *
      * Parameters:
      * (String) moduleId       - The module ID
      * (String) subInstanceId  - The subinstance ID
      * (Object) opt            - The option object
      * (Function) fn           - Callback function
      */
    var startSubModule = function( moduleId, subInstanceId, opt, fn ){
      core['startSubModule']( moduleId, subInstanceId, opt, instanceId, fn );
    };

    /**
      * Function: stopSubModule
      * Stop a submodule.
      *
      * Parameters:
      * (String) instanceId - The instance ID
      */
    var stopSubModule = function( instanceId ){
      core['stop']( instanceId );
    };

    /**
      * Function: getModel
      * Get a specific model.
      *
      * Parameters:
      * (String) id - The model ID
      *
      * Returns:
      * (Object) model  - The model object
      */
    var getModel = function( id ){
      return core.mvc['getModel']( instanceId, id );
    };

    /**
      * Function: getView
      * Get a specific view.
      *
      * Parameters:
      * (String) id - The view id
      *
      * Returns:
      * (Object) view - The view object
      */
    var getView = function( id ){
      return core.mvc['getView']( instanceId, id );
    };

    /**
      * Function: getController
      * Get a specific controller.
      *
      * Parameters:
      * (String) id   - The controller ID
      *
      * Returns:
      * (Object) controller - The controller object
      */
    var getController = function( id ){
      return core.mvc['getController']( instanceId, id );
    };

    /**
      * Function: addModel
      * Add a model.
      *
      * Paraneters:
      * (String) id     - The model ID
      * (Object) model  - The model object
      */
    var addModel = function( id , model ){
      return core.mvc['addModel']( instanceId, id, model );
    };

    /**
      * Function: addView
      * Add a view.
      *
      * Parameters:
      * (String) id    - The view ID
      * (Object) view  - The view object
      */
    var addView = function( id, view ){
      return core.mvc['addView']( instanceId, id, view );
    };

    /**
      * Function: addController
      * Add a controller.
      *
      * Parameters:
      * (String) id         - The controller ID
      * (Object) controller - The controller object
      */
    var addController = function( id, controller ){
      return core.mvc['addController']( instanceId, id, controller );
    };

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
      return core.template['get']( instanceId, id );
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
        log['error']("type of 'id' is not valid", "sandbox of " + instanceId );
      }
    };

    /**
      * Function: _
      * Get localized text.
      *
      * Parameters:
      * (String) textId - The text ID
      *
      * Returns:
      * (String) text - The localized text
      */
    var _ = function( textId ){
      return core['i18n']['_']( instanceId, textId );
    };

    /**
    * Function: getContainer
    * Get the DOM container of the module. 
    *
    * Returns:
    * (Object) container - The container
    */
    var getContainer = function(){
      return core['getContainer']( instanceId );
    };

      /**
      * Function: hotkeys
      * Binds a function to hotkeys.
      * If an topic as string and data is used instead of the function 
      * the data gets published.
      *
      * Parameters:
      * (String) keys       - The key combination 
      * (Function) handler  - The handler function
      * (String) type       - The event type 
      */
    var hotkeys = function( keys, handler, type, opt ){

      // if user wants to publish s.th. directly
      if( typeof handler === "string" ){

        // in this case 'handler' holds the topic, 'type' the data 
        // and 'opt' the type.
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

    // public sandbox API
    return ({

      'subscribe': subscribe,
      'unsubscribe': unsubscribe,
      'publish': publish,

      'startSubModule': startSubModule,
      'stopSubModule': stopSubModule,

      'getModel': getModel,
      'getView': getView,
      'getController': getController,

      'addModel': addModel,
      'addView': addView,
      'addController': addController,

      'observable': core.mvc['observable'],

      'getTemplate': getTemplate,
      'tmpl': tmpl,

      'getContainer': getContainer,

      'debug': log.debug,
      'info': log.info,
      'warn': log.warn,
      'error': log.error,
      'fatal': log.fatal,

      'mixin': core['util']['mixin'],
      'count': core['util']['countObjectKeys'],

      '_':_,
      'getLanguage': core['i18n']['getLanguage'],

      'hotkeys': hotkeys

    });

  };
}( window, window['scaleApp'] ));
