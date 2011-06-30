/**
 * Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)
 */

/**
 * File: scaleApp.mvc.js
 * scaleApp.mvc.js is a Model-View-Controler extension for scaleApp.
 *
 * It is licensed under the MIT licence.
 */

/**
 * Class: scaleApp.mvc
 */
(function( window, core, undefined ){

  /**
   * Class: observable
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
  core['onInstantiate']( function( instanceId, opt ){

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

  });

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

  /**
  * Function: addModel
  *
  * Paraneters:
  * (String) instanceId
  * (String) id
  * (Function) model
  */
  var addModel = function( instanceId, id, model ){
    add( models, instanceId, id, model );
  };

  /**
  * Function: addView
  *
  * Paraneters:
  * (String) instanceId
  * (String) id
  * (Function) view
  */
  var addView = function( instanceId, id, view ){
    add( views, instanceId, id, view );
  };

  /**
  * Function: addController
  *
  * Paraneters:
  * (String) instanceId
  * (String) id
  * (Function) controller
  */
  var addController = function( instanceId, id, controller ){
    add( controllers, instanceId, id, controller );
  };

  /**
  * Function: getModel
  *
  * Paraneters:
  * (String) instanceId
  * (String) id
  *
  * Returns:
  * (Object) model
  */
  var getModel = function( instanceId, id ){
    return get( models, instanceId, id );
  };

  /**
  * Function: getView
  *
  * Paraneters:
  * (String) instanceId
  * (String) id
  *
  * Returns:
  * (Object) view
  */
  var getView = function( instanceId, id ){
    return get( views, instanceId, id );
  };


  /**
  * Function: getController
  *
  * Paraneters:
  * (String) instanceId
  * (String) id
  *
  * Returns:
  * (Object) controller
  */
  var getController = function( instanceId, id ){
    return get( controllers, instanceId, id );
  };

  core.mvc = core.mvc || ({

    'addModel': addModel,
    'addView': addView,
    'addController': addController,

    'getModel': getModel,
    'getView': getView,
    'getController': getController,

    'observable': observable

  });

}( window, window['scaleApp'] ));
