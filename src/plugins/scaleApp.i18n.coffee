Mediator = window?.scaleApp?.Mediator or require? "../Mediator"

baseLanguage = "en"

getBrowserLanguage = ->
  (navigator?.language or navigator?.browserLanguage or baseLanguage).split("-")[0]

# Holds the current global language code.
# By default the browsers language is used.
lang = getBrowserLanguage()

mediator = new Mediator

channelName = "i18n"

global = {}

subscribe = -> mediator.subscribe channelName, arguments...

unsubscribe = -> mediator.unsubscribe channelName, arguments...

getLanguage = -> lang

setLanguage = (code) ->
  if typeof code is "string"
    lang = code
    mediator.publish channelName, lang

setGlobal = (obj) ->
  if typeof(obj) is "object"
    global= obj
    true
  else
    false

getText = (key, x, l) -> x[l]?[key] or global[l]?[key]

get = (key, x={}) ->
  getText(key, x, lang)                 or
  getText(key, x, lang.substring(0,2))  or
  getText(key, x, baseLanguage)         or
  key

class SBPlugin

  constructor: (@sb) ->

  i18n:
    subscribe: subscribe
    unsubscribe: unsubscribe

  _: (text) -> get text, @sb.options.i18n

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
      setGlobal: setGlobal

window?.scaleApp.registerPlugin plugin if window?.scaleApp?
module.exports = plugin if module?.exports?
