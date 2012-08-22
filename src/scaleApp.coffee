###
This program is distributed under the terms of the MIT license.
Copyright (c) 2011-2012 Markus Kohlhase (mail@markus-kohlhase.de)
###

if module?.exports? and typeof require is "function" and not require.amd?
  Mediator  = require "./Mediator"
  Sandbox   = require "./Sandbox"
  util      = require "./Util"

VERSION = "0.3.8"

modules       = {}
instances     = {}
instanceOpts  = {}
mediator      = new Mediator
plugins       = {}
error         = (e) -> console?.error? e.message

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

getInstanceOptions = (instanceId, module, opt) ->

  # Merge default options and instance options and start options,
  # without modifying the defaults.
  o = {}

  # first copy default module options
  o[key] = val for key, val of module.options

  # then copy instance options
  io = instanceOpts[instanceId]
  o[key] = val for key, val of io if io

  # and finally copy start options
  o[key] = val for key, val of opt if opt

  # return options
  o

createInstance = (moduleId, instanceId=moduleId, opt) ->

  module = modules[moduleId]

  return instances[instanceId] if instances[instanceId]?

  iOpts = getInstanceOptions instanceId, module, opt
  sb = new Sandbox core, instanceId, iOpts
  mediator.installTo sb

  for i,p of plugins when p.sandbox?
    plugin = new p.sandbox sb
    sb[k] = v for own k,v of plugin

  instance              = new module.creator sb
  instance.options      = iOpts
  instance.id           = instanceId
  instances[instanceId] = instance

  for n in [instanceId, '_always']
    entry.callback.apply entry.context for entry in onInstantiateFunctions[n] if onInstantiateFunctions[n]?

  instance

addModule = (moduleId, creator, opt) ->

  throw new TypeError "module ID has to be a string"             unless typeof moduleId  is "string"
  throw new TypeError "creator has to be a constructor function" unless typeof creator   is "function"
  throw new TypeError "option parameter has to be an object"     unless typeof opt       is "object"

  modObj = new creator()

  throw new TypeError "creator has to return an object"          unless typeof modObj          is "object"
  throw new TypeError "module has to have an init function"      unless typeof modObj.init     is "function"
  throw new TypeError "module has to have a destroy function"    unless typeof modObj.destroy  is "function"

  throw new TypeError "module #{moduleId} was already registered" if modules[moduleId]?

  modules[moduleId] =
    creator: creator
    options: opt
    id: moduleId
  true

register = (moduleId, creator, opt = {}) ->

  try
    addModule moduleId, creator, opt
  catch e
    error new Error "could not register module '#{moduleId}': #{e.message}"
    false

setInstanceOptions = (instanceId, opt) ->
  throw new TypeError "instance ID has to be a string"        unless typeof instanceId  is "string"
  throw new TypeError "option parameter has to be an object"  unless typeof opt         is "object"
  instanceOpts[instanceId] ?= {}
  instanceOpts[instanceId][k] = v for k,v of opt

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

    # if the module wants to init in an asynchronous way
    if (util.getArgumentNames instance.init).length >= 2
      # then define a callback
      instance.init instance.options, (err) -> opt.callback? err
    else
      # else call the callback directly after initialisation
      instance.init instance.options
      opt.callback? null

    instance.running = true
    true

  catch e
    error e
    opt.callback? new Error "could not start module: #{e.message}"
    false

stop = (id, cb) ->
  if instance = instances[id]

    #i18n.unsubscribe instance
    mediator.unsubscribe instance

    # if the module wants destroy in an asynchronous way
    if (util.getArgumentNames instance.destroy).length >= 1
      # then define a callback
      instance.destroy (err) ->
        cb? err
    else
      # else call the callback directly after stopping
      instance.destroy()
      cb? null

    # remove
    delete instances[id]
    true
  else false

startAll = (cb, opt) ->

  if cb instanceof Array
    mods = cb; cb = opt; opt = null
    valid = (id for id in mods when modules[id]?)
  else
    mods = valid = (id for id of modules)

  if valid.length is mods.length is 0
    cb? null
    return true
  else if valid.length isnt mods.length
    invalid = ("'#{id}'" for id in mods when not (id in valid))
    invalidErr = new Error "these modules don't exist: #{invalid}"

  startAction = (m, next) ->
    o = {}
    modOpts = modules[m].options
    o[k] = v for own k,v of modOpts when v
    o.callback = (err) ->
      modOpts.callback? err
      next err
    start m, o

  util.doForAll valid, startAction, (err) ->
    if err?.length > 0
      e = new Error "errors occoured in the following modules: #{("'#{valid[i]}'" for x,i in err when x?)}"
    cb? e or invalidErr

  not invalidErr?

stopAll = (cb) ->
  util.doForAll (id for id of instances), stop, cb

coreKeywords = [ "VERSION", "register", "unregister", "registerPlugin", "start"
  "stop", "startAll", "stopAll", "publish", "subscribe", "unsubscribe", "on",
  "emit", "setInstanceOptions", "Mediator", "Sandbox", "unregisterAll",
  "uniqueId", "lsModules", "lsInstances"]

sandboxKeywords = [ "core", "instanceId", "options", "publish", "emit", "on"
  "subscribe", "unsubscribe" ]

lsModules = -> (id for id,m of modules)

lsInstances = -> (id for id,m of instances)

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
      for k,v of plugin.core
        core[k] = v
        exports?[k] = v

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
  setInstanceOptions: setInstanceOptions
  start: start
  stop: stop
  startAll: startAll
  stopAll: stopAll
  uniqueId: util.uniqueId
  lsInstances: lsInstances
  lsModules: lsModules
  util: util
  Mediator: Mediator
  Sandbox: Sandbox
  subscribe:    -> mediator.subscribe.apply mediator, arguments
  on:           -> mediator.subscribe.apply mediator, arguments
  unsubscribe:  -> mediator.unsubscribe.apply mediator, arguments
  publish:      -> mediator.publish.apply mediator, arguments
  emit:         -> mediator.publish.apply mediator, arguments

module.exports  = core if module?.exports?
if define?.amd?
  (define -> core) if define?.amd?
else if window?
  window.scaleApp = core
