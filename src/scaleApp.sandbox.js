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
    * Function: getContainer
    * Get the DOM container of the module. 
    *
    * Returns:
    * (Object) container - The container
    */
    var getContainer = function(){
      return core['getContainer']( instanceId );
    };

    // public sandbox API
    return ({

      'subscribe': subscribe,
      'unsubscribe': unsubscribe,
      'publish': publish,

      'startSubModule': startSubModule,
      'stopSubModule': stopSubModule,

      'getContainer': getContainer,

      'mixin': core['util']['mixin'],
      'count': core['util']['countObjectKeys']

    });

  };
}( window, window['scaleApp'] ));
