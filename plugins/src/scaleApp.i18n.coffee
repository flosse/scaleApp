plugin = (core) ->

  baseLanguage = "en"

  getBrowserLanguage = ->
    (navigator?.language or navigator?.browserLanguage or baseLanguage).split("-")[0]

  channelName = "i18n"

  getText = (key, x, l, global) -> x[l]?[key] or global[l]?[key]

  get = (key, x={}, lang="", global) ->
    getText(key, x, lang, global)                 or
    getText(key, x, lang.substring(0,2), global)  or
    getText(key, x, baseLanguage,global)          or
    key

  addLocal = (dict, i18n) ->
    return false unless typeof dict is "object"
    for lang,txt of dict
      i18n[lang] ?= {}
      i18n[lang][k] ?= v for k,v of txt

  mediator = new core.Mediator
  lang     = getBrowserLanguage()
  global   = {}

  core.getBrowserLanguage = getBrowserLanguage
  core.baseLanguage = baseLanguage

  getLanguage = -> lang

  unsubscribe = -> mediator.off channelName, arguments...

  onChange = -> mediator.on channelName, arguments...

  setLanguage = (code) ->
    if typeof(code) is "string"
      lang = code
      mediator.emit channelName, lang

  setGlobal = (obj) ->
    if typeof obj is "object"
      global = obj
      true
    else false

  _ = (text, o) -> get text, o, lang, global

  core.i18n =
    setLanguage: setLanguage
    getLanguage: getLanguage
    setGlobal: setGlobal
    onChange: onChange
    _ : _
    unsubscribe: unsubscribe

  core.Sandbox::i18n =
    onChange : onChange
    unsubscribe : unsubscribe
    getLanguage : getLanguage

  id: "i18n"

  init: (sb) ->

    sb.i18n.addLocal = (dict) ->
      sb.options.i18n ?= {}
      addLocal dict, sb.options.i18n

    sb._ = (text) => _ text, sb.options.localDict or sb.options.i18n

# AMD support
if define?.amd?
  define -> plugin

# Browser support
else if window?.scaleApp?
  window.scaleApp.plugins.i18n = plugin

# Node.js support
else if module?.exports?
  module.exports = plugin
