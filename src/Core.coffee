checkType = (type, val, name) ->
  "#{name} has to be a #{type}" unless typeof val is type

class Core

  constructor: (@Sandbox) ->

    # define private variables

    @_modules      = {}
    @_plugins      = []
    @_instances    = {}
    @_sandboxes    = {}
    @_running      = {}
    @_mediator     = new Mediator

    # define public variables

    @Mediator     = Mediator
    @Sandbox      ?= (core, @instanceId, @options = {}) ->
      core._mediator.installTo @
      @

  # define dummy logger
  log:
    error: ->
    log:   ->
    info:  ->
    warn:  ->
    enable:->

  # register a module
  register: (moduleId, creator, opt = {}) ->
    err =
      checkType("string",   moduleId, "module ID")  or
      checkType("function", creator,  "creator")    or
      checkType("object",   opt,      "option parameter")
    if err
      @log.error "could not register module '#{moduleId}': #{err}"
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
  start: (moduleId, opt={}, cb=->) ->

    if arguments.length is 0
      return @_startAll()

    if moduleId instanceof Array
      return @_startAll moduleId, opt

    if typeof moduleId is "function"
      return @_startAll null, moduleId

    if typeof opt is "function"
      cb = opt; opt = {}

    e =
      checkType("string", moduleId, "module ID")    or
      checkType("object", opt, "second parameter")  or
      ("module doesn't exist" unless @_modules[moduleId])

    return @_startFail e, cb if e

    id = opt.instanceId or moduleId

    if @_running[id] is true
      return @_startFail (new Error "module was already started"), cb

    initInst = (err, instance, opt) =>
      return @_startFail err, cb if err
      try
        if util.hasArgument instance.init, 2
          # the module wants to init in an asynchronous way
          # therefore define a callback
          instance.init opt, (err) =>
            @_running[id] = true unless err
            cb err
        else
          # call the callback directly after initialisation
          instance.init opt
          @_running[id] = true
          cb()
      catch e
        @_startFail e,cb

    @boot (err) =>
      return @_startFail err, cb if err
      @_createInstance moduleId, opt.instanceId, opt.options, initInst

  _startFail: (e, cb) ->
    @log.error e
    cb new Error "could not start module: #{e.message}"
    @

  _createInstance: (moduleId, instanceId=moduleId, opt, cb) ->

    module = @_modules[moduleId]

    return cb @_instances[instanceId] if @_instances[instanceId]

    iOpts = {}
    for o in [module.options, opt] when o
      iOpts[key] ?= val for key,val of o

    sb = new @Sandbox @, instanceId, iOpts
    sb.moduleId = moduleId

    @_runSandboxPlugins 'init', sb, (err) =>
      instance = new module.creator sb
      unless typeof instance.init is "function"
        return cb new Error "module has no 'init' method"
      @_instances[instanceId] = instance
      @_sandboxes[instanceId] = sb
      cb null, instance, iOpts

  _runSandboxPlugins: (ev, sb, cb) ->
    tasks =
      for p in @_plugins when typeof p.plugin?[ev] is "function" then do (p) ->
        fn = p.plugin[ev]
        (next) ->
          if util.hasArgument fn, 3
            fn sb, p.options, next
          else
            fn sb, p.options
            next()
    util.runSeries tasks, cb, true

  _startAll: (mods=(m for m of @_modules), cb) ->

    startAction = (m, next) => @start m, @_modules[m].options, next

    done = (err) ->
      if err?.length > 0
        mdls = ("'#{mods[i]}'" for x,i in err when x?)
        e = new Error "errors occoured in the following modules: #{mdls}"
      cb? e
    util.doForAll mods, startAction, done, true
    @

  stop: (id, cb=->) ->
    if arguments.length is 0 or typeof id is "function"
      util.doForAll (x for x of @_instances), (=> @stop arguments...), id, true

    else if instance = @_instances[id]

      delete @_instances[id]

      @_mediator.off instance
      @_runSandboxPlugins 'destroy', @_sandboxes[id], (err) =>

        # if the module wants destroy in an asynchronous way
        if util.hasArgument instance.destroy
          # then define a callback
          instance.destroy (err) ->
            # rereference if something went wrong
            @_instances[id] = instance if err
            cb err
        else
          # else call the callback directly after stopping
          instance.destroy?()
          cb()
    @

  # register a plugin
  use: (plugin, opt) ->
    if plugin instanceof Array
      for p in plugin
        switch typeof p
          when "function" then @use p
          when "object"   then @use p.plugin, p.options
    else
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

  on:   -> @_mediator.on.apply   @_mediator, arguments
  off:  -> @_mediator.off.apply  @_mediator, arguments
  emit: -> @_mediator.emit.apply @_mediator, arguments
