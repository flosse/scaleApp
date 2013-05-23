plugin = (core) ->

  ls = (o) -> (id for id,m of o)

  core.lsInstances = -> ls core._instances
  core.lsModules   = -> ls core._modules
  core.lsPlugins   = -> (p.plugin.id for p in core._plugins when p.plugin?.id?)

# AMD support
if define?.amd?
  define -> plugin

# Browser support
else if window?.scaleApp?
  window.scaleApp.plugins.ls = plugin

# Node.js support
else if module?.exports?
  module.exports = plugin
