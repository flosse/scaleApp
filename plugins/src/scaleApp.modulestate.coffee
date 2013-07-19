plugin = (core) ->

  core.state = s = new core.Mediator true

  init:    (sb) ->
    s.emit "init/#{sb.moduleId}/#{sb.instanceId}",
      instanceId: sb.instanceId
      moduleId: sb.moduleId

  destroy: (sb) ->
    s.emit "destroy/#{sb.moduleId}/#{sb.instanceId}",
      instanceId: sb.instanceId
      moduleId: sb.moduleId

# AMD support
if define?.amd?
  define -> plugin

# Browser support
else if window?.scaleApp?
  window.scaleApp.plugins.modulestate = plugin

# Node.js support
else if module?.exports?
  module.exports = plugin
