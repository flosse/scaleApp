if typeof require is "function"
  Mediator  = require("./Mediator").Mediator
  Sandbox   = require("./Sandbox").Sandbox

VERSION = "0.3.3"

modules = {}
instances = {}
mediator = new Mediator
plugins = {}
error = (e) -> console?.error? e.message

uniqueId = (length=8) ->
 id = ""
 id += Math.random().toString(36).substr(2) while id.length < length
 id.substr 0, length

# container for all functions that gets called when an instance gets created
onInstantiateFunctions = _always: []

# registers a function that gets executed when a module gets instantiated.
onInstantiate = (fn, moduleId) ->

  throw new Error "expect a function as parameter" unless typeof fn is "function"
  entry = { context: @, callback: fn }

  if typeof moduleId is "string"
    onInstantiateFunctions[moduleId] = [] unless onInstantiateFunctions[moduleId]?
    onInstantiateFunctions[moduleId].push entry
  else if not moduleId?
    onInstantiateFunctions._always.push entry

createInstance = (moduleId, instanceId=moduleId, opt) ->

  module = modules[moduleId]

  return instances[instanceId] if instances[instanceId]?

  # Merge default options and instance options,
  # without modifying the defaults.
  instanceOpts = {}
  instanceOpts[key] = val for key, val of module.options
  instanceOpts[key] = val for key, val of opt if opt

  sb = new Sandbox core, instanceId, instanceOpts
  mediator.installTo sb

  for i,p of plugins when p.sandbox?
    plugin = new p.sandbox sb
    sb[k] = v for own k,v of plugin

  instance = new module.creator sb
  instance.options = instanceOpts
  instance.id = instanceId
  instances[instanceId] = instance

  for n in [instanceId, '_always']
    entry.callback.apply entry.context for entry in onInstantiateFunctions[n] if onInstantiateFunctions[n]?

  instance

addModule = (moduleId, creator, opt) ->

  throw new Error "moudule ID has to be a string"            unless typeof moduleId  is "string"
  throw new Error "creator has to be a constructor function" unless typeof creator   is "function"
  throw new Error "option parameter has to be an object"     unless typeof opt       is "object"

  modObj = new creator()

  throw new Error "creator has to return an object"          unless typeof modObj          is "object"
  throw new Error "module has to have an init function"      unless typeof modObj.init     is "function"
  throw new Error "module has to have a destroy function"    unless typeof modObj.destroy  is "function"

  throw new Error "module #{moduleId} was already registered" if modules[moduleId]?

  modules[moduleId] =
    creator: creator
    options: opt
    id: moduleId
  true

register = (moduleId, creator, opt = {}) ->

  try
    addModule moduleId, creator, opt
  catch e
    error new Error "could not register module: #{e.message}"
    false

unregister = (id) ->
  if modules[id]?
    delete modules[id]
    true
  else
    false

unregisterAll = -> unregister id for id of modules

start = (moduleId, opt={}) ->

  try

    throw new Error "module ID has to be a string" unless typeof moduleId is "string"
    throw new Error "second parameter has to be an object" unless typeof opt is "object"
    throw new Error "module does not exist" unless modules[moduleId]?

    instance = createInstance moduleId, opt.instanceId, opt.options

    throw new Error "module was already started" if instance.running is true

    instance.init instance.options
    instance.running = true
    opt.callback?()
    true

  catch e
    error e
    false

stop = (id) ->
  if instance = instances[id]

    #i18n.unsubscribe instance
    mediator.unsubscribe instance

    instance.destroy()
    delete instances[id]
  else false

startAll = (cb, opt) ->

  if cb instanceof Array
    mods = (id for id in cb when modules[id])
    cb = opt
  else switch typeof cb
    when "undefined","function" then mods = (id for id of modules)

  if mods?.length >= 1
    o = {}; o[k] = v for own k,v of modules[mods[0]].options when v
    origCB = o.callback

    if mods[1..].length is 0
      o.callback = -> origCB?(); cb?()
    else
      o.callback = -> origCB?(); startAll mods[1..], cb
    start mods[0], o
  else false

stopAll = -> stop id for id of instances

coreKeywords = [ "VERSION", "register", "unregister", "registerPlugin", "start"
  "stop", "startAll", "stopAll", "publish", "subscribe", "unsubscribe"
  "Mediator", "Sandbox", "unregisterAll", "uniqueId" ]

sandboxKeywords = [ "core", "instanceId", "options", "publish"
  "subscribe", "unsubscribe" ]

registerPlugin = (plugin) ->

  try
    throw new Error "plugin has to be an object" unless typeof plugin is "object"
    throw new Error "plugin has no id" unless typeof plugin.id is "string"

    if typeof plugin.sandbox is "function"
      for k of new plugin.sandbox new Sandbox core, ""
        throw new Error "plugin uses reserved keyword" if k in sandboxKeywords
      Sandbox::[k] = v for k, v of plugin.sandbox::

    if typeof plugin.core is "object"
      for k of plugin.core
        throw new Error "plugin uses reserved keyword" if k in coreKeywords
      core[k] = v for k, v of plugin.core

    if typeof plugin.onInstantiate is "function"
      onInstantiate plugin.onInstantiate

    plugins[plugin.id] = plugin
    true

  catch e
    error e
    false

# define pupblic API
core =
  VERSION: VERSION
  register: register
  unregister: unregister
  unregisterAll: unregisterAll
  registerPlugin: registerPlugin
  start: start
  stop: stop
  startAll: startAll
  stopAll: stopAll
  uniqueId: uniqueId
  Mediator: Mediator
  Sandbox: Sandbox

mediator.installTo core
exports.scaleApp  = core if exports?
window.scaleApp   = core if window?
