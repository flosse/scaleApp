scaleApp = window?.scaleApp or require? "../scaleApp"

id2subId = (id, sb) -> "#{sb.instanceId}_sub_#{id}"

core = null

register = (sb, id, args...) ->
  core.register id2subId(id, sb), args...

start = (sb, id, opt={})->
  moduleId = id2subId id, sb
  if opt.instanceId
    opt.instanceId = id2subId opt.instanceId, sb
    core.onModuleState "destroy", (-> core.stop opt.instanceId), sb.instanceId
  else
    core.onModuleState "destroy", (-> core.stop moduleId), sb.instanceId
  core.start moduleId, opt

stop = (sb, id, args...)-> core.stop id2subId(id, sb), args...

class SBPlugin

  constructor: (@sb) ->
    core = @sb.core

    @sub =
      register: => register @sb, arguments...
      start: => start @sb, arguments...
      stop: => stop @sb, arguments...

    if core.permission?
      @permission =
        add: (id, args...) => core.permission.add id2subId(id, @sb), args...
        remove: (id, args...) => core.permission.remove id2subId(id, @sb), args...

plugin=
  id: "submodule"
  sandbox: SBPlugin

window.scaleApp.registerPlugin plugin if window?.scaleApp?
module.exports = plugin if module?.exports?
(define -> plugin) if define?.amd?
