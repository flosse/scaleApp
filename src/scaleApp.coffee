if typeof require is "function"
  Mediator  = require "./Mediator"
  Sandbox   = require "./Sandbox"

VERSION = "0.3.7"

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
    error new Error "could not register module '#{moduleId}': #{e.message}"
    false

unregister = (id) ->
  if modules[id]?
    delete modules[id]
    true
  else
    false

unregisterAll = -> unregister id for id of modules

getArgNames = (fn) ->
  args = fn.toString().match(/function\b[^(]*\(([^)]*)\)/)[1]
  args = args.split /\s*,\s*/
  (a for a in args when a.trim() isnt '')

start = (moduleId, opt={}) ->

  try

    throw new Error "module ID has to be a string" unless typeof moduleId is "string"
    throw new Error "second parameter has to be an object" unless typeof opt is "object"
    throw new Error "module does not exist" unless modules[moduleId]?

    instance = createInstance moduleId, opt.instanceId, opt.options

    throw new Error "module was already started" if instance.running is true

    # if the module wants to init in an asynchronous way
    if (getArgNames instance.init).length >= 2
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
    if (getArgNames instance.destroy).length >= 1
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

doForAll = (modules, action, cb)->

  count = modules.length
  if count is 0
    cb? null
    true
  else

    errors = []

    actionCB = ->
      count--
      checkEnd count, errors, cb

    for m in modules when not action m, actionCB
      errors.push "'#{m}'"

    errors.length is 0

checkEnd = (count, errors, cb) ->
  if count is 0
    if errors.length > 0
      cb? new Error "errors occoured in the following modules: #{errors}"
    else
      cb? null

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
      next?()
    start m, o

  aCB = (err) ->
    cb? err or invalidErr
  (doForAll valid, startAction, aCB) and not invalidErr?

stopAll = (cb) -> doForAll (id for id of instances)
  , ((m, next) -> stop m, next)
  , cb

coreKeywords = [ "VERSION", "register", "unregister", "registerPlugin", "start"
  "stop", "startAll", "stopAll", "publish", "subscribe", "unsubscribe"
  "Mediator", "Sandbox", "unregisterAll", "uniqueId", "lsModules", "lsInstances"]

sandboxKeywords = [ "core", "instanceId", "options", "publish"
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
  start: start
  stop: stop
  startAll: startAll
  stopAll: stopAll
  uniqueId: uniqueId
  lsInstances: lsInstances
  lsModules: lsModules
  Mediator: Mediator
  Sandbox: Sandbox
  subscribe: -> mediator.subscribe.apply mediator, arguments
  unsubscribe: -> mediator.unsubscribe.apply mediator, arguments
  publish: -> mediator.publish.apply mediator, arguments

module.exports  = core if module?.exports?
window.scaleApp = core if window?
