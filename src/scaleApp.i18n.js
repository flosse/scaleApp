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
  var _ = function( instanceId, textId ){

    var inst = core['getInstance']( instanceId );

    if( inst['opt'] ){
      if( inst['opt']['i18n'] ){
        return inst['opt']['i18n'][ lang ][ textId ] || textId;
      }
    }
    return textId;
  };

  // public API
  core['i18n'] = core['i18n'] || ({
    'setLanguage': setLanguage,
    'getBrowserLanguage': getBrowserLanguage,
    'getLanguage': getLanguage,
    '_': _
  });

}( window, window['scaleApp'] ));
