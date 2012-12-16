scaleApp = window?.scaleApp or require? "../scaleApp"

class SBPlugin

  constructor: (@sb) ->

    core = new scaleApp.Core
    destroy = -> core.stopAll.apply core
    @sb.core.onModuleState "destroy", destroy, @sb.instanceId
    @sub = {}

    for fn in ["register", "start", "stop", "on", "off", "emit"] then do (fn) =>
      @sub[fn] = -> core[fn].apply core, arguments

    if core.permission?
      @sub.permission =
        add: -> core.permission.add.apply core, arguments
        remove: -> core.permission.remove.apply core, arguments

plugin=
  id: "submodule"
  sandbox: SBPlugin

window.scaleApp.plugin.register plugin if window?.scaleApp?
module.exports = plugin if module?.exports?
(define -> plugin) if define?.amd?
