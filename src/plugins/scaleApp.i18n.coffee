# Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)

# holds the fallback language code
baseLang = "en"

# PrivateFunction: getBrowserLanguage
#
# Returns:
# (String) the language code of the browser
getBrowserLanguage = ->
  (navigator.language or navigator.browserLanguage or baseLang).split("-")[0]

# Holds the current global language code.
# By default the browsers language is used.
lang = getBrowserLanguage()

# holds the callback functions
callbacks = []

# holds the language objects
i18n = {}

# PrivateFunction: getLanguage
#
# Returns:
# (String) the current language code, that is used globally.
getLanguage = -> lang

# PrivateFunction: setLanguage
#
# Parameters:
# (String) languageCode  - the language code you want to set
setLanguage = (languageCode) ->
  if typeof languageCode is "string"
    lang = languageCode
    cb?( languageCode ) for cb in callbacks

# PrivateFunction: subscribe
#
# Parameters:
# (Function) fn - The callback function
subscribe = (fn) ->
  if typeof fn is "function"
    callbacks.push fn

# PrivateFunction: unsubscribe
#
# Parameters:
# (Function) fn - The callback function
unsubscribe = (fn) ->
  if typeof fn is "function"
    callbacks = callbacks.filter (f) -> fn isnt f

# PrivateFunction: _
#
# Parameters:
# (String) instanceId
# (String) textId
#
# Returns
# (String) the localized string.
get = (instanceId, text) ->
  x = i18n[instanceId]
  x[lang]?[text] ? ( x[lang.substring(0, 2)]?[text] ? ( x[baseLang]?[text] ? text ) )

# PrivateFunction: onInstantiate
#
# Parameters:
# (String) instanceId
# (object) opt
onInstantiate = (instanceId, opt) ->
  if typeof instanceId is "string" and typeof opt is "object"
    i18n[ instanceId ] = opt.i18n if typeof opt.i18n is "object"
    console.debug( i18n )

sbPlugin = (sb, instanceId) ->
  i18n:
    subscribe: subscribe
    unsubscribe: unsubscribe
  getBrowserLanguage: getBrowserLanguage
  setLanguage: setLanguage
  getLanguage: getLanguage
  _: (textId) -> get instanceId, textId

corePlugin =
  i18n:
    setLanguage: setLanguage
    getBrowserLanguage: getBrowserLanguage
    getLanguage: getLanguage
    subscribe: subscribe
    unsubscribe: unsubscribe

scaleApp.registerPlugin "i18n",
  sandbox : sbPlugin
  core: corePlugin
  onInstantiate: onInstantiate
