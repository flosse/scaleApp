# Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)

# scaleApp is a tiny framework for One-Page-Applications.
# It is licensed under the MIT licence.

# Class: scaleApp
# The core holds and manages all data that is used globally.

# reference to the core object itself
that = this

# container for all registered modules
modules = {}

# container for all module instances
instances = {}

# container for lists of submodules
subInstances = {}

# container for all plugins
plugins = {}

# container for all functions that gets called when an instance gets created
onInstantiateFunctions = _always: []

# log level constants

DEBUG = "debug"
INFO  = "info"
WARN  = "warn"
ERROR = "error"
FATAL = "fatal"

# local log functions
log = (msg, mod, level) ->
  that.log[level] msg, mod  if that.log and typeof that.log[level] is "function"

#  Function: onInstantiate
#  Registers a function that gets executed when a module gets instantiated.
#
#  Parameters:
#  (Function) fn      - Callback function
#  (String) moduleId  - Only call if specified module ID gets instantiated
onInstantiate = (fn, moduleId) ->

  if typeof fn is "function"
    if moduleId and typeof moduleId is "string"
      onInstantiateFunctions[moduleId] = []  unless onInstantiateFunctions[moduleId]
      onInstantiateFunctions[moduleId].push fn
    else
      onInstantiateFunctions._always.push fn
  else
    log "onInstantiate expect a function as parameter", name, ERROR

# PrivateFunction: createInstance
# Creates a new instance of a module.
#
# Parameters:
# (String) moduleId    - The ID of a registered module.
# (String) instanceId  - The ID of the instance that will be created.
# (Object) opt         - An object that holds specific options for the module.
# (Function) opt       - Callback function.
createInstance = (moduleId, instanceId, opt, success, error) ->

  mod = modules[moduleId]

  callSuccess = ->
    if typeof success is "function" then success instance else
      log "callback function is not a function", name, WARN

  callError = ->
    error instance if typeof error is "function"

  if mod

    # Merge default options and instance options,
    # without modifying the defaults.
    instanceOpts = {}
    $.extend true, instanceOpts, mod["opt"], opt

    sb = new that.sandbox(instanceId, instanceOpts)

    # add plugins
    for id, plugin of plugins
      p = new plugin(sb, instanceId)
      $.extend true, sb, p

    instance = new mod.creator(sb)

    # store opt
    instance["opt"] = instanceOpts

    callInstantiateFunctions(moduleId, instanceId, instanceOpts, sb).done(->
      callSuccess()
    ).fail (err) ->
      callError err
  else
    log "could not start module '" + moduleId + "' - module does not exist.", name, ERROR

# PrivateFunction: callInstantiateFunctions
#
# Parameters:
# (String) id  - The instance ID
# (Object) opt - The instance option object
# (Object) sb  - The sandbox
callInstantiateFunctions = (moduleId, instanceId, opt, sb) ->

  dfd = $.Deferred()
  deferreds = []
  addToDeferreds = (functions) ->
    for i, fn of functions
      deferreds.push fn(instanceId, opt, sb)

  addToDeferreds onInstantiateFunctions._always
  addToDeferreds onInstantiateFunctions[moduleId]  if onInstantiateFunctions[moduleId]
  $.when.apply(null, deferreds).done ->
    dfd.resolve()

  dfd.promise()

# PrivateFunction: checkRegisterParameters
#
# Parameters:
# (String) moduleId  - The module ID
# (Function) creator - The creator function
# (Object) opt       - The option object
#
# Returns:
# (Boolean) ok - True if everything is ok.
checkRegisterParameters = (moduleId, creator, opt) ->

  errString = "could not register module"

  if typeof moduleId isnt "string"
    log errString + "- mouduleId has to be a string", name, ERROR
    return false

  if typeof creator isnt "function"
    log errString + " - creator has to be a constructor function", name, ERROR
    return false

  modObj = new creator()

  valid = typeof modObj             is "object"   and
          typeof modObj["init"]     is "function" and
          typeof modObj["destroy"]  is "function"

  if not valid
    log errString + " - creator has to return an object with the functions 'init' and 'destroy'", name, ERROR
    return false

  return false if ( opt and typeof opt isnt "object" )

  true

# Function: register
# Registers a new module.
#
# Parameters:
# (String) moduleId  - The module id
# (Function) creator - The module creator function
# (Object) ops       - The default options for this module
#
# Returns:
# (Boolean) success  - True if registration was successfull.
register = (moduleId, creator, opt) ->

  return false unless checkRegisterParameters(moduleId, creator, opt)

  opt = {} unless opt

  modules[moduleId] =
    creator: creator
    opt: opt

  true

# PrivateFunction: hasValidStartParameter
#
# Parameters:
# (String) moduleId
# (String) instanceId
# (Object) opt
#
# Returns:
# True, if parameters are valid.
hasValidStartParameter = (moduleId, instanceId, opt) ->

  (typeof moduleId is "string") and

    (typeof instanceId is "string" and not opt)                 or
    (typeof instanceId is "object" and not opt)                 or
    (typeof instanceId is "string" and typeof opt is "object")  or
    (not instanceId and not opt)                                or
    ($.isArray(moduleId) and not instanceId and not opt)

# PrivateFunction: getSuitedParamaters
#
# Parameters:
# (String) moduleId
# (String) instanceId
# (Object) opt
#
# Returns:
# Object with parameters
getSuitedParamaters = (moduleId, instanceId, opt) ->

  if typeof instanceId is "object" and not opt
    # no instance id was specified, so use module id instead
    opt = instanceId
    instanceId = moduleId

  if not instanceId and not opt
    instanceId = moduleId
    opt = {}

  moduleId: moduleId
  instanceId: instanceId
  opt: opt

# PrivateFunction: regularStart
#
# Parameters:
# (String) moduleId    -
# (String) instanceId  -
# (Object) opt         -
# (Function) callback  -
regularStart = (moduleId, instanceId, opt, callback) ->

  p = getSuitedParamaters(moduleId, instanceId, opt)

  if p
    log "start '" + p.moduleId + "'", name, DEBUG

    onSuccess = (instance) ->
      instances[p.instanceId] = instance
      instance["init"] instance["opt"]
      callback()  if typeof callback is "function"

    createInstance p.moduleId, p.instanceId, p["opt"], onSuccess
    return true
  false

# Function: start
# Starts a module.
#
# Parameters:
# (String) moduleId    - The module ID
# (String) instanceId  - The instance ID
# (Object) opt         - The option object
start = (moduleId, instanceId, opt, callback) ->

  if hasValidStartParameter(moduleId, instanceId, opt)
    regularStart moduleId, instanceId, opt, callback
  else
    error "could not start module '" + moduleId + "' - illegal arguments.", name
    false

# PrivateFunction: startSubModule
#
# Parameters:
# (String) moduleId
# (String) parentInstanceId
# (String) instanceId
# (Object) opt
# (Function) callback
startSubModule = (moduleId, instanceId, opt, parentInstanceId, callback) ->

  p = getSuitedParamaters(moduleId, instanceId, opt)

  if start(p.moduleId, p.instanceId, p["opt"], callback) and typeof parentInstanceId is "string"
    sub = subInstances[parentInstanceId]
    sub = []  unless sub
    sub.push p.instanceId

# Function: stop
# Stops a module.
#
# Parameters:
# (String) instanceId  - The instance ID
stop = (instanceId) ->

  instance = instances[instanceId]

  if instance
    instance["destroy"]()
    delete instances[instanceId]

    for i, instance of subInstances[instanceId]
      stop instance if instance

  else
    log "could not stop instance '" + instanceId + "' - instance does not exist.", name, ERROR
    false

# Function: startAll
# Starts all available modules.
#
# Parameters:
# (Function) fn  - The Function that gets called after all modules where initialized.
# (Array) array  - Array of module ids that shell be started.
startAll = (fn, array) ->

  couldNotStartModuleStr = "Could not start module"

  callback = ->

  if typeof fn is "function"
    count = 0
    if $.isArray(array)
      count = array.length
    else
      count = that.util.countObjectKeys(modules)
    callback = ->
      count--
      fn() if count is 0

  if $.isArray(array)

    $.each array, (i, id) ->

      if typeof id is "string"
        start id, id, modules[id]["opt"], callback

      else if typeof id is "object"

        if id["moduleId"] and id["opt"]
          start id["moduleId"], id["instanceId"], id["opt"], callback
        else
          log couldNotStartModuleStr + " from array - invalid parameters", name, ERROR
      else
        log couldNotStartModuleStr + " from array", name, ERROR
  else

    for id, module of modules
      start id, id, module["opt"], callback if module

# Function: stopAll
# Stops all available instances.
stopAll = -> stop id for id, inst of instances

# PrivateFunction: publish
# 
# Parameters:
# (String) topic             - The topic name
# (Object) data              - The data that gets published
# (Boolean) publishReference - If the data should be passed as a reference to
#                              the other modules this parameter has to be set
#                              to *true*.
#                              By default the data object gets copied so that
#                              other modules can't influence the original
#                              object.
publish = (topic, data, publishReference) ->

  for i, instance of instances

    if instance.subscriptions

      handlers = instance.subscriptions[topic]

      if handlers

        for i,h of handlers

          if typeof h is "function"

            if typeof data is "object" and publishReference isnt true

              copy = {}
              $.extend true, copy, data
              h copy, topic

            else
              h data, topic

# PrivateFunction: subscribe
# 
# Parameters:
# (String) topic
# (Function) handler
subscribe = (instanceId, topic, handler) ->

  log "subscribe to '" + topic + "'", instanceId, DEBUG

  instance = instances[instanceId]
  instance.subscriptions = {}  unless instance.subscriptions
  subs = instance.subscriptions
  subs[topic] = []  unless subs[topic]
  subs[topic].push handler

# PrivateFunction: unsubscribe
# 
# Parameters:
# (String) instanceId
# (String) topic
unsubscribe = (instanceId, topic) ->
  subs = instances[instanceId].subscriptions
  delete subs[topic] if subs[topic] if subs

# PrivateFunction: getInstances
# 
# Parameters:
# (String) id
# 
# Returns:
# Instance
getInstance = (id) -> instances[id]

# PrivateFunction: getContainer
getContainer = (instanceId) ->

  o = instances[instanceId]["opt"]
  return $("#" + o["container"])  if typeof o["container"] is "string"  if o
  $ "#" + instanceId

# Function: registerPlugin
#
# Parameters:
# (String) id     - The plugin ID
# (Object) plugin - The plugin object
registerPlugin = (id, plugin) ->

  if typeof id is "string" and typeof plugin is "object"

    if typeof plugin["sandbox"] is "function"
      plugins[id] = plugins[id] or plugin["sandbox"]

    if typeof plugin["core"] is "function" or typeof plugin["core"] is "object"
      that.util.mixin that, plugin["core"]

    if typeof plugin["onInstantiate"] is "function"
      onInstantiate plugin["onInstantiate"]

  else
    log "registerPlugin expect an id and an object as parameters", name, ERROR

that =
  'register': register
  'onInstantiate': onInstantiate
  'registerPlugin': registerPlugin
  'start': start
  'startSubModule': startSubModule
  'stop': stop
  'startAll': startAll
  'stopAll': stopAll
  'publish': publish
  'subscribe': subscribe
  'getContainer': getContainer
  'getInstance': getInstance
  'log': log

window['scaleApp'] = that
