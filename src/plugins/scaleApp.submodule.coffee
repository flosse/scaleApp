plugin = (core, options={}) ->

  methods = ["register", "start", "stop", "on", "off", "emit"]

  install = (sb, subCore) ->
    sb.sub = {}

    for fn in methods then do (fn) =>
      sb.sub[fn] = ->
        subCore[fn].apply subCore, arguments
        sb

    if subCore.permission?
      sb.sub.permission =
        add:    subCore.permission.add
        remove: subCore.permission.remove

  init: (sb, opt, done) ->

    sb._subCore = subCore = new core.constructor
    if options.use instanceof Array
      subCore.use p for p in options.use
      subCore.boot (err) ->
        return done err if err
        install sb, subCore
        done()
    else
      if typeof options.use is "function"
        subCore.use options.use
      install sb, subCore
      done()

  destroy: (sb) ->
    sb._subCore.stopAll()

# AMD support
if define?.amd?
  define -> plugin

# Browser support
else if window?.scaleApp?
  window.scaleApp.plugins.submodule = plugin

# Node.js support
else if module?.exports?
  module.exports = plugin
