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
    @_mediator     = new Mediator @

    # define public variables

    @Mediator     = Mediator
    @Sandbox      ?= (core, @instanceId, @options = {}, @moduleId) ->
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
  register: (id, creator, options = {}) ->
    err =
      checkType("string",   id,       "module ID")  or
      checkType("function", creator,  "creator")    or
      checkType("object",   options,  "option parameter")
    if err
      @log.error "could not register module '#{id}': #{err}"
      return @

    if id of @_modules
      @log.warn "module #{id} was already registered"
      return @

    @_modules[id] = { creator, options, id }
    @

  # start a module
  start: (moduleId, opt={}, cb=->) ->

    if arguments.length is 0         then return @_startAll()
    if moduleId instanceof Array     then return @_startAll moduleId, opt
    if typeof moduleId is "function" then return @_startAll null, moduleId
    if typeof opt is "function"      then cb = opt; opt = {}

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
      @_createInstance moduleId, opt, initInst

  _startFail: (e, cb) ->
    @log.error e
    cb new Error "could not start module: #{e.message}"
    @

  _createInstance: (moduleId, o, cb) ->

    id = o.instanceId or moduleId
    opt = o.options

    module = @_modules[moduleId]

    return cb @_instances[id] if @_instances[id]

    iOpts = {}
    for obj in [module.options, opt] when obj
      iOpts[key] ?= val for key,val of obj

    Sandbox =
      if typeof o.sandbox is 'function' then o.sandbox
      else @Sandbox

    sb = new Sandbox @, id, iOpts, moduleId

    @_runSandboxPlugins 'init', sb, (err) =>
      instance = new module.creator sb
      unless typeof instance.init is "function"
        return cb new Error "module has no 'init' method"
      @_instances[id] = instance
      @_sandboxes[id] = sb
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
          instance.destroy (err2) =>
            delete @_running[id]
            cb err or err2
        else
          # else call the callback directly after stopping
          instance.destroy?()
          delete @_running[id]
          cb err
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
