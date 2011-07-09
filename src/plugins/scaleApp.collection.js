/**
 * Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)
 */

/**
 * PrivateClass: scaleApp.collection
 */
(function( window, core, undefined ){

  // container for global collections
  var globalCollections = {};

  /**
   * PrivateFunction: generateId
   *
   * Parameters:
   * (String) salt -
   */
  var generateId = function( salt ){
    return salt + (new Date()).getTime();
  };

  /**
   * PrivateClass: Collection
   *
   * Parameters:
   * (String) cid - Collection ID
   */
  var Collection = function( cid ){

    // container for objects
    var collection = {};

    core.util.mixin( collection, core.mvc.observable );

    // identifier for the collection
    var id = cid || generateId( "col" );

    /**
     * Function: getId
     */
    var getId = function(){
      return id;
    };

    /**
     * Function: add
     *
     * Parameters:
     * (Object) obj     -
     * (String) id      -
     * (Boolean) silent -
     */
    var add = function( obj, id, silent ){

      var oid = id || generateId("obj");
      collection[ oid ] = obj;
      if( silent !== true ){
        collection.notify();
      }
      return oid
    };

    /**
     * Function: get
     */
    var get = function( id ){
      if( id ){
        return collection[ id ];
      }else{
        return collection;
      }
    };

    /**
     * Function: remove
     *
     * Parameters:
     * (String) id      - 
     * (Boolean) silent -
     */
    var remove = function( id, silent ){
      delete collection[ id ];
      if( silent !== true ){
        collection.notify();
      }
    };

    /**
     * Function: update
     */
    var update = function( obj, silent ){
      $.each( collection, function( i, o ){
        if( o === obj ){
          collection[ i ] = obj;
          if( silent !== true ){
            collection.notify();
          }
        }
      })
    };

    // public API
    return ({
      get: get,
      add: add,
      remove: remove,
      update: update,
      getCollectionId: getId,
      subscribe: collection.subscribe,
      unsubscribe: collection.unsubscribe,
      notify: collection.notify
    });
  };

  /**
   * PrivateFunction: collectionPlugin
   */
  var collectionPlugin = function( sb, instanceId ){

    // local container
    var localCollections = {};

    /**
     * PrivateFunction: createCollection
     */
    var create = function( id, global ){

      var col = new Collection( id );

      if( global === true ){
        globalCollections[ col.getCollectionId() ] = col;
      }else{
        localCollections[ col.getCollectionId() ] = col;
      }
      return col;
    };

    /**
     * Function: getCollection
     */
    var get = function( id ){
      return localCollections[ id ] || globalCollections[ id ];
    };

    // public API
    return ({
      getCollection: get,
      createCollection: create
    });
  };

  var corePlugin = {
    getCollection: function( id ){
      return globalCollections[ id ];
    },
    createCollection: function( id ){
      var col = new Collection( id );
      globalCollections[ col.getCollectionId() ] = col;
      return col;
    }
  };

  scaleApp.registerPlugin( 'collection', {
    sandbox: collectionPlugin,
    core: corePlugin
  });

}( window, window['scaleApp'] ));
