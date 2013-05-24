checkType = (type, val, name) ->
  throw new TypeError "#{name} has to be a #{type}" unless typeof val is type

runSandboxPlugins = (ev, sb, cb) ->
  tasks = for p in @_plugins when typeof p.plugin?[ev] is "function" then do (p) ->
    x = p.plugin[ev]
    if util.hasArgument x, 3
      (next) ->
        x sb, p.options, next
    else
      (next) ->
        x sb, p.options
        next()
  util.runSeries tasks, cb, true

createInstance = (moduleId, instanceId=moduleId, opt, cb) ->

  module = @_modules[moduleId]

  return cb @_instances[instanceId] if @_instances[instanceId]?

  iOpts = {}
  for o in [module.options, opt] when o
    iOpts[key] = val for key, val of o

  sb = new @Sandbox @, instanceId, iOpts
  sb.moduleId ?= moduleId

  runSandboxPlugins.call @, 'init', sb, (err) =>
    instance               = new module.creator sb
    unless typeof instance.init is "function"
      return cb new Error "module has no 'init' method"
    instance.options       = iOpts
    instance.id            = instanceId
    @_instances[instanceId] = instance
    @_sandboxes[instanceId] = sb
    cb null, instance

class Core

  constructor: (sandbox=Sandbox)->

    # define private variables

    @_modules      = {}
    @_plugins      = []
    @_instances    = {}
    @_sandboxes    = {}
    @_mediator     = new Mediator

    # define public variables

    @Sandbox      = sandbox
    @Mediator     = Mediator

  # define dummy logger
  log:
     error: ->
     log:   ->
     info:  ->
     warn:  ->
     enable: ->

  # register a module
  register: (moduleId, creator, opt = {}) ->
    try
      checkType "string",   moduleId, "module ID"
      checkType "function", creator,  "creator"
      checkType "object",   opt,      "option parameter"
    catch e
      @log.error "could not register module '#{moduleId}': #{e.message}"
      return @

    if @_modules[moduleId]?
      @log.warn "module #{moduleId} was already registered"
      return @

    @_modules[moduleId] =
      creator: creator
      options: opt
      id: moduleId
    @

  # start a module
  start: (moduleId, opt={}, done=->) ->

    if typeof opt is "function"
      callback = opt
      opt = callback: callback

    cb = (err) ->
      opt.callback? err
      done err

    try
      checkType "string", moduleId, "module ID"
      checkType "object", opt, "second parameter"
      throw new Error "module doesn't exist" unless @_modules[moduleId]?

      id = opt.instanceId or moduleId
      throw new Error "module was already started" if @_instances[id]?.running is true

      @boot =>
        createInstance.call @, moduleId, opt.instanceId, opt.options, (err, instance) =>
          if err
            @log.error err
            return cb err

          if util.hasArgument instance.init, 2
            # the module wants to init in an asynchronous way
            # therefore define a callback
            instance.init instance.options, (err) ->
              instance.running = true
              cb err
          else
            # call the callback directly after initialisation
            instance.init instance.options
            cb null
            instance.running = true
      true

    catch e
      @log.error e
      cb new Error "could not start module: #{e.message}"
      @

  startAll: (cb, opt) ->

    if cb instanceof Array
      mods = cb; cb = opt; opt = null
      valid = (id for id in mods when @_modules[id]?)
    else
      mods = valid = (id for id of @_modules)

    if valid.length is mods.length is 0
      cb? null
      return true
    else if valid.length isnt mods.length
      invalid = ("'#{id}'" for id in mods when not (id in valid))
      invalidErr = new Error "these modules don't exist: #{invalid}"

    startAction = (m, next) => @start m, @_modules[m].options, (err) -> next err

    util.doForAll valid, startAction, (err) ->
      if err?.length > 0
        e = new Error "errors occoured in the following modules: #{("'#{valid[i]}'" for x,i in err when x?)}"
      cb? e or invalidErr

    not invalidErr?

  stop: (id, cb) ->
    if instance = @_instances[id]

      @_mediator.off instance
      runSandboxPlugins.call @, 'destroy', @_sandboxes[id], (err) =>

        # if the module wants destroy in an asynchronous way
        if util.hasArgument instance.destroy
          # then define a callback
          instance.destroy (err) ->
            cb? err
        else
          # else call the callback directly after stopping
          instance.destroy()
          cb? null

        # remove
        delete @_instances[id]
    @

  stopAll: (cb) ->
    util.doForAll (id for id of @_instances), (=> @stop.apply @, arguments), cb
    @

  # register a plugin
  use: (plugin, opt) ->
    return @ unless typeof plugin is "function"
    @_plugins.push creator:plugin, options:opt
    @

  # load plugins
  boot: (cb) ->
    core  = @
    tasks = for p in @_plugins when p.booted isnt true then do (p) ->
      if util.hasArgument p.creator, 3
        (next) ->
          plugin = p.creator core, p.options, (err) ->
            if not err
              p.booted = true
              p.plugin = plugin
            next()
      else
        (next) ->
          p.plugin = p.creator core, p.options
          p.booted = true
          next()
    util.runSeries tasks, cb, true
    @

  on:                 -> @_mediator.on.apply   @_mediator, arguments
  off:                -> @_mediator.off.apply  @_mediator, arguments
  emit:               -> @_mediator.emit.apply @_mediator, arguments
