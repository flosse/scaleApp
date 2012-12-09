scaleApp = window?.scaleApp or require? "../scaleApp"

id2subId = (id, sb) -> "#{sb.instanceId}_sub_#{id}"

core = null

class SBPlugin

  constructor: (@sb) -> core = @sb.core

  register: (id, args...)->
    core.register id2subId(id, @sb), args...

  start: (id, opt={}) ->
    moduleId = id2subId id, @sb
    if opt.instanceId
      opt.instanceId = id2subId opt.instanceId, @sb
      core.onModuleState "destroy", (-> core.stop opt.instanceId), @sb.instanceId
    else
      core.onModuleState "destroy", (-> core.stop moduleId), @sb.instanceId
    core.start moduleId, opt

  stop: (id, args...)-> core.stop id2subId(id, @sb), args...

plugin =
  id: "submodule"
  sandbox: SBPlugin

window.scaleApp.registerPlugin plugin if window?.scaleApp?
module.exports = plugin if module?.exports?
(define -> plugin) if define?.amd?
