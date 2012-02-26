Mediator = window?.scaleApp?.Mediator or require?("../Mediator").Mediator

baseLanguage = "en"

getBrowserLanguage = ->
  (navigator?.language or navigator?.browserLanguage or baseLanguage).split("-")[0]

# Holds the current global language code.
# By default the browsers language is used.
lang = getBrowserLanguage()

mediator = new Mediator

channelName = "i18n"

subscribe = -> mediator.subscribe channelName, arguments...

unsubscribe = -> mediator.unsubscribe channelName, arguments...

getLanguage = -> lang

setLanguage = (code) ->
  if typeof code is "string"
    lang = code
    mediator.publish channelName, lang

get = (x, text) ->
  x[lang]?[text] ? ( x[lang.substring(0, 2)]?[text] ? ( x[baseLanguage]?[text] ? text ) )

class SBPlugin

  constructor: (@sb) ->

  i18n:
    subscribe: subscribe
    unsubscribe: unsubscribe

  _: (text) ->
    i18n = @sb.options.i18n
    return text if typeof i18n isnt "object"
    get i18n, text

  getLanguage: getLanguage

plugin =
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

window?.scaleApp.registerPlugin plugin if window?.scaleApp?
exports.Plugin = plugin if exports?
