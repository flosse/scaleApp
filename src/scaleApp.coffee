checkType = (type, val, name) ->
  throw new TypeError "#{name} has to be a #{type}" unless typeof val is type

plugins = {}

# registers a function that gets executed when a module gets instantiated.
onModuleState = (state, fn, moduleId='_always') ->
  checkType "function", fn, "parameter"
  @moduleStates.on "#{state}/#{moduleId}", fn, @

getInstanceOptions = (instanceId, module, opt) ->

  # Merge default options and instance options and start options,
  # without modifying the defaults.
  o = {}

  # first copy default module options
  o[key] = val for key, val of module.options

  # then copy instance options
  io = @instanceOpts[instanceId]
  o[key] = val for key, val of io if io

  # and finally copy start options
  o[key] = val for key, val of opt if opt

  # return options
  o

createInstance = (moduleId, instanceId=moduleId, opt) ->

  module = @modules[moduleId]

  return @instances[instanceId] if @instances[instanceId]?

  iOpts = getInstanceOptions.apply @, [instanceId, module, opt]
  sb = new Sandbox @, instanceId, iOpts
  @mediator.installTo sb

  for i,p of plugins when p.sandbox?
    plugin = new p.sandbox sb
    sb[k] = v for own k,v of plugin
    if typeof p.on is "object"
      for ev,cb of p.on when typeof cb is "function"
        @onModuleState ev, cb

  instance              = new module.creator sb
  instance.options      = iOpts
  instance.id           = instanceId
  @instances[instanceId] = instance

  for n in [instanceId, '_always']
    @moduleStates.emit "instantiate/#{n}"

  instance

addModule = (moduleId, creator, opt) ->

  checkType "string",   moduleId, "module ID"
  checkType "function", creator,  "creator"
  checkType "object",   opt,      "option parameter"

  modObj = new creator()

  checkType "object",   modObj,         "the return value of the creator"
  checkType "function", modObj.init,    "'init' of the module"
  checkType "function", modObj.destroy, "'destroy' of the module "

  throw new TypeError "module #{moduleId} was already registered" if @modules[moduleId]?

  @modules[moduleId] =
    creator: creator
    options: opt
    id: moduleId
  true

register = (moduleId, creator, opt = {}) ->
  try
    addModule.apply @, [moduleId, creator, opt]
  catch e
    console.error "could not register module '#{moduleId}': #{e.message}"
    false

setInstanceOptions = (instanceId, opt) ->
  checkType "string", instanceId, "instance ID"
  checkType "object", opt, "option parameter"
  @instanceOpts[instanceId] ?= {}
  @instanceOpts[instanceId][k] = v for k,v of opt

unregister = (id, type) ->
  if type[id]?
    delete type[id]
    return true
  false

unregisterAll = (type) -> unregister id, type for id of type

start = (moduleId, opt={}) ->

  try
    checkType "string", moduleId, "module ID"
    checkType "object", opt, "second parameter"
    throw new Error "module doesn't exist" unless @modules[moduleId]?

    instance = createInstance.apply @, [moduleId, opt.instanceId, opt.options]

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
    console.error e
    opt.callback? new Error "could not start module: #{e.message}"
    false

stop = (id, cb) ->
  if instance = @instances[id]

    @mediator.unsubscribe instance

    # if the module wants destroy in an asynchronous way
    if (util.getArgumentNames instance.destroy).length >= 1
      # then define a callback
      instance.destroy (err) ->
        cb? err
    else
      # else call the callback directly after stopping
      instance.destroy()
      cb? null

    for n in [id, '_always']
      @moduleStates.unsubscribe "instantiate/#{n}"
      @moduleStates.emit "destroy/#{n}"

    # remove
    delete @instances[id]
    true
  else false

startAll = (cb, opt) ->

  if cb instanceof Array
    mods = cb; cb = opt; opt = null
    valid = (id for id in mods when @modules[id]?)
  else
    mods = valid = (id for id of @modules)

  if valid.length is mods.length is 0
    cb? null
    return true
  else if valid.length isnt mods.length
    invalid = ("'#{id}'" for id in mods when not (id in valid))
    invalidErr = new Error "these modules don't exist: #{invalid}"

  startAction = (m, next) =>
    o = {}
    modOpts = @modules[m].options
    o[k] = v for own k,v of modOpts when v
    o.callback = (err) ->
      modOpts.callback? err
      next err
    @start m, o

  util.doForAll valid, startAction, (err) ->
    if err?.length > 0
      e = new Error "errors occoured in the following modules: #{("'#{valid[i]}'" for x,i in err when x?)}"
    cb? e or invalidErr

  not invalidErr?

stopAll = (cb) ->
  util.doForAll (id for id of @instances), (=> stop.apply @, arguments), cb

ls = (o) -> (id for id,m of o)

registerPlugin = (plugin) ->

  try
    checkType "object", plugin, "plugin"
    checkType "string", plugin.id, "'id' of plugin"

    if typeof plugin.sandbox is "function"
      Sandbox::[k] ?= v for k, v of plugin.sandbox::

    if typeof plugin.core is "function"
      Core::[k] ?= v for k,v of plugin.core::

    if typeof plugin.core is "object"
      Core::[k] ?= v for k,v of plugin.core

    if typeof plugin.base is "object"
      base[k] ?= v for k,v of plugin.base

    plugins[plugin.id] = plugin
    true

  catch e
    console.error e
    false

class Core
  constructor: ->
    @modules       = {}
    @instances     = {}
    @instanceOpts  = {}
    @mediator      = new Mediator
    @moduleStates  = new Mediator
    for id,p of plugins when p.core
      if typeof p.core is "function"
        core = new p.core()
        @[k] ?= v for own k,v of core

  register:           -> register.apply @, arguments
  lsInstances:        -> ls @instances
  lsModules:          -> ls @modules
  start:              -> start.apply    @, arguments
  startAll:           -> startAll.apply @, arguments
  stop:               -> stop.apply     @, arguments
  stopAll:            -> stopAll.apply  @, arguments
  publish:            -> @mediator.publish.apply     @mediator, arguments
  subscribe:          -> @mediator.subscribe.apply   @mediator, arguments
  on:                 -> @mediator.subscribe.apply   @mediator, arguments
  unsubscribe:        -> @mediator.unsubscribe.apply @mediator, arguments
  publish:            -> @mediator.publish.apply     @mediator, arguments
  emit:               -> @mediator.publish.apply     @mediator, arguments
  unregisterAll:      -> unregisterAll  @modules
  unregister: (id)    -> unregister id, @modules
  onModuleState:      -> onModuleState.apply      @, arguments
  setInstanceOptions: -> setInstanceOptions.apply @, arguments

# define pupblic API
base =
  VERSION: "0.4.0"
  plugin:
    register: registerPlugin
    ls: -> ls plugins
  util: util
  Mediator: Mediator
  Sandbox: Sandbox
  Core: Core

module.exports  = base if module?.exports?
if define?.amd?
  (define -> base) if define?.amd?
else if window?
  window.scaleApp = base
