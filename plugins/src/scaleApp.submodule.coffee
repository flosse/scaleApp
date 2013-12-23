plugin = (core, options={}) ->

  methods = ["register", "start", "stop", "on", "off", "emit"]

  install = (sb, subCore) ->
    sb.sub = {}

    for fn in methods then do (fn) =>
      sb.sub[fn] = ->
        subCore[fn].apply subCore, arguments
        sb

    #TODO: replace that with a more elegant solution
    if subCore.permission?
      sb.sub.permission =
        add:    subCore.permission.add
        remove: subCore.permission.remove

  init: (sb, opt, done) ->

    sb._subCore = subCore = new core.constructor
    if options.useGlobalMediator
      core._mediator.installTo subCore._mediator, true

    else if options.mediator?
      options.mediator?.installTo? subCore._mediator, true

    # make sure that plugins do not modify the original
    # Sandbox class.
    subCore.Sandbox = class SubSandbox extends core.Sandbox

    plugins = []

    if options.inherit
      for p in core._plugins
        plugins.push plugin: p.creator, options: p.options

    if options.use instanceof Array
      plugins.push p for p in options.use

    else if typeof options.use is "function"
      plugins.push options.use

    subCore.use(plugins).boot (err) ->
      return done err if err
      install sb, subCore
      done()

  destroy: (sb) -> sb._subCore.stop()

# AMD support
if define?.amd?
  define -> plugin

# Browser support
else if window?.scaleApp?
  window.scaleApp.plugins.submodule = plugin

# Node.js support
else if module?.exports?
  module.exports = plugin
