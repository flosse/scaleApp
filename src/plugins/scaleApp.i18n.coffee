scaleApp = window?.scaleApp or require? "../scaleApp"

baseLanguage = "en"

getBrowserLanguage = ->
  (navigator?.language or navigator?.browserLanguage or baseLanguage).split("-")[0]

channelName = "i18n"

getText = (key, x, l, global) -> x[l]?[key] or global[l]?[key]

get = (key, x={}, lang="", global) ->
  getText(key, x, lang, global)                 or
  getText(key, x, lang.substring(0,2), global)  or
  getText(key, x, baseLanguage,global)         or
  key

class SBPlugin

  constructor: (sb) ->

    i18nLocal = sb.core.i18n

    @i18n =
      onChange: i18nLocal.onChange
      unsubscribe: i18nLocal.unsubscribe
      getLanguage: i18nLocal.getLanguage

    @_ = (text) => i18nLocal._ text, sb.options.i18n

class CorePlugin

  constructor: ->

    mediator = new scaleApp.Mediator
    lang     = getBrowserLanguage()
    global   = {}

    @i18n =
      setLanguage: (code) ->
        if typeof code is "string"
          lang = code
          mediator.publish channelName, lang
      getLanguage: -> lang
      setGlobal: (obj) ->
        if typeof obj is "object"
          global = obj
          true
        else false

      onChange: -> mediator.on channelName, arguments...
      _: (text, o) -> get text, o, lang, global

      unsubscribe: -> mediator.off channelName, arguments...

plugin =
  id: "i18n"
  sandbox: SBPlugin
  core: CorePlugin
  base:
    getBrowserLanguage: getBrowserLanguage
    baseLanguage: baseLanguage

window.scaleApp.plugin.register plugin if window?.scaleApp?
module.exports = plugin if module?.exports?
(define -> plugin) if define?.amd?
