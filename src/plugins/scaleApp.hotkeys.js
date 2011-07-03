/**
 * Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)
 */
(function( window, scaleApp, $ ){

    scaleApp.registerPlugin('hotkeys', { sandbox: function( sb ){

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
          sb.publish( handler, type );
        });

      }
      else if( typeof handler === "function" ){

        if( !type ){ type = "keypress"; }

        $(document).bind( type, keys, handler );
      }

    };

    // Public API
    return ({
      hotkeys: hotkeys
    });

  }});

}( window, window['scaleApp'], jQuery ));
