/**
 * Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)
 */

/**
 * PrivateClass: scaleApp.i18n
 */
(function( window, core, undefined ){

  /**
   * PrivateFunction: getBrowserLanguage
   *
   * Returns:
   * (String) the language code of the browser
   */
  var getBrowserLanguage = function(){
    return ( navigator.language || navigator.browserLanguage || "en" ).split('-')[0];
  };

  /**
   * Holds the current global language code.
   * By default the browsers language is used.
   */
  var lang = getBrowserLanguage();

  /**
   * PrivateFunction: getLanguage
   *
   * Returns:
   * (String) the current language code, that is used globally.
   */
  var getLanguage = function(){
    return lang;
  };

  /**
   * PrivateFunction: setLanguage
   *
   * Parameters:
   * (String) languageCode  - the language code you want to set
   *
   * Returns:
   * TRUE, if setting to code was successfull else FALSE is returned
   */
  var setLanguage = function( languageCode ){

    if( typeof languageCode === "string" ){
      lang = languageCode;
      core['publish']( "languageChanged", languageCode );
      return true;
    }
    return false;

  };

  /**
   * PrivateFunction: _
   *
   * Parameters:
   * (String) instanceId
   * (String) textId
   *
   * Returns
   * (String) the localized string.
   */
  var get = function( instanceId, textId ){

    var inst = core['getInstance']( instanceId );

    if( inst['opt'] ){
      if( inst['opt']['i18n'] ){
        var i18n = inst['opt']['i18n']; 

        // everything is fine
        if( i18n[ lang ] && i18n[ lang ][ textId ] ){
          return i18n[ lang ][ textId ];
        }else{
          // fallback
          var sub = lang.substring(0,2);

          if( i18n[ sub ] && i18n[ sub ][ textId ] ){
            return i18n[ sub ][ textId ];
          }else{
            if( i18n[ 'en' ] && i18n[ 'en' ][ textId ] ){
              return i18n[ 'en' ][ textId ];
            }
          }
        }
      }
    }
    return textId;
  };

  /**
   * PrivateFunction: sandboxPlugin
   */
  var sandboxPlugin = function( sb, instanceId ){

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
      return get( instanceId, textId );
    };

    return ({
      'setLanguage': setLanguage,
      'getBrowserLanguage': getBrowserLanguage,
      'getLanguage': getLanguage,
      '_': _
    });

  };

  // register plugin
  scaleApp.registerPlugin( 'i18n', { sandbox: sandboxPlugin });

}( window, window['scaleApp'] ));
