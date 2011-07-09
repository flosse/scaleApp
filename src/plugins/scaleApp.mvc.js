/**
 * Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)
 */

/**
 * PrivateClass: scaleApp.mvc
 */
(function( window, core, undefined ){

  /**
   * PrivateClass: observable
   */
  var observable = function(){};

  observable['prototype'] = {

    'subscribe' : function( s ){
      if( !this._subscribers ){
        this._subscribers = [];
      }
      this._subscribers.push( s );
    },

    'unsubscribe' : function( observer ){

      if( this._subscribers ){
        this._subscribers = this._subscribers.filter(
          function( el ){
            if( el !== observer ){ return el; }
          }
        );
      }
    },

    'notify' : function(){
      if( this._subscribers ){
        $.each( this._subscribers, function( i, subscriber ){
          if( typeof subscriber['update'] === "function" ){
            subscriber['update']();
          }else if( typeof subscriber === "function" ){
            subscriber();
          }
        });
      }
    }
  };

  // Container for all models
  var models = { };

  // Container for all views
  var views = { };

  // Controller for all controllers
  var controllers = { };

  // register function that gets called after an instance was created
  var onInstantiate = function( instanceId, opt ){

    if( opt['models'] ){
      mixinDefaultModel( opt['models'] );
      addObjects( models, instanceId, opt['models']  );
    }
    if( opt['views'] ){
      addObjects( views, instanceId, opt['views'] );
    }
    if( opt['controllers'] ){
      addObjects( controllers, instanceId, opt['controllers'] );
    }

  };

  /**
   * PrivateFunction: mixinDefaultModel
   * Extend the model with standard model-methods by default.
   * At the moment there are just the observale methods.
   */
  var mixinDefaultModel = function( objects ){

    if( typeof objects === "object" ){

      $.each( objects, function( i, obj ){

        if( obj ){
          core['util']['mixin']( obj, observable );
        }
      });
    }
  };

  /**
  * PrivateFunction: addObjects
  *
  * Paraneters:
  * (Object) container
  * (String) instanceId
  * (Object) objects
  */
  var addObjects = function( container, instanceId, objects ){

    if( typeof objects === "object" ){

      $.each( objects, function( i, obj ){

        if( obj ){
          add( container, instanceId, i, obj );
        }
      });
    }
  };

  /**
  * PrivateFunction: add
  *
  * Paraneters:
  * (Object) container
  * (String) instanceId
  * (String) id
  * (Object) obj
  */
  var add = function( container, instanceId, id, obj ){
    if( !container[ instanceId ] ){
      container[ instanceId ] = { };
    }
    container[ instanceId ][ id ] = obj;
  };

  /**
  * PrivateFunction: get
  *
  * Paraneters:
  * (Object) container
  * (String) instanceId
  * (String) id
  */
  var get = function( container, instanceId, id ){

    var o = container[ instanceId ];

    if( o ){

      // if no id was specified and only one object exist => return it
      if( !id && core['util']['countObjectKeys'](o) === 1 ){
        for( var one in o ) break;
          return o[ one ];
      }
      return o[ id ];
    }
  };

  var mvcPlugin = function( sb, instanceId ){
    
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
      return get( models, instanceId, id );
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
      return get( views, instanceId, id );
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
      return get( controllers, instanceId, id );
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
      return add( models, instanceId, id, view );
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
      return add( views, instanceId, id, view );
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
      return add( controllers, instanceId, id, controller );
    };

    return ({
      'getModel': getModel,
      'getView': getView,
      'getController': getController,

      'addModel': addModel,
      'addView': addView,
      'addController': addController,

      'observable': observable

    });

  };

  /**
   * PrivateClass: corePlugin
   */
  var corePlugin = {
    mvc: { observable:observable }
  };

  // register plugin
  scaleApp.registerPlugin('mvc', {
    sandbox: mvcPlugin,
    core: corePlugin,
    onInstantiate: onInstantiate
  });

}( window, window['scaleApp'] ));
