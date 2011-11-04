class SBPlugin

  constructor: (@sb) ->

  _: (text) ->
    i18n = @sb.options.i18n
    return text if typeof i18n is not "object"
    @sb.core.i18n.get i18n, text

  getLanguage: -> @sb.core.i18n.getLanguage()

  onLanguageChanged: (fn) -> @sb.core.i18n.subscribe fn

baseLanguage = "en"
 
getBrowserLanguage = ->
  (navigator.language or navigator.browserLanguage or baseLang).split("-")[0]
 
# Holds the current global language code.
# By default the browsers language is used.
lang = getBrowserLanguage()

mediator = new scaleApp.Mediator

channelName = "i18n"

subscribe = (fn) -> mediator.subscribe(channelName,fn)

unsubscribe = (fn) -> mediator.unsubscribe(channelName,fn)

getLanguage = -> lang

setLanguage = (code) ->
  if typeof code is "string"
    lang = code
    mediator.publish channelName, lang

get = (x, text) ->
  x[lang]?[text] ? ( x[lang.substring(0, 2)]?[text] ? ( x[baseLanguage]?[text] ? text ) )

scaleApp.registerPlugin
  id: "i18n"
  sandbox: SBPlugin
  core:
    i18n:
      setLanguage: setLanguage
      getBrowserLanguage: getBrowserLanguage
      getLanguage: getLanguage
      baseLanguage: baseLanguage
      get: get
      subscribe: subscribe
      unsubscribe: unsubscribe
