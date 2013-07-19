plugin = (core) ->

  permissions = {}

  controlledActions = ["on", "emit", "off"]

  addPermission = (id, action, channels) ->
    if typeof id is "object"
      not false in (addPermission k,v for k,v of id)
    else if typeof action is "object"
      not false in (addPermission id,k,v for k,v of action)
    else if channels?

      p = permissions[id] ?= {}

      if typeof channels is "string"
        channels = if channels is '*' then ["__all__"] else [channels]

      if typeof action is "string"
        if action is '*'
          not false in (addPermission id, act, channels for act in controlledActions)
        else
          a = p[action] ?= {}
          a[c] = true for c in channels
          true

      else false
    else false

  removePermission = (id, action, channel) ->
    p = permissions[id]
    if not channel?
      delete p[action]
      true
    else if not p?[action]?[channel]
      false
    else
      delete p[action][channel]
      true

  hasPermission = (id, action, channel) ->
    p = permissions[id]?[action] or {}
    if channel? and (p[channel] or p["__all__"])
      true
    else
      console.warn "'#{id}' has no permissions for '#{action}' with '#{channel}'"
      false

  grantAction = (sb, action, method, args) ->
    channel = args[0] if args?.length > 0
    p =
      if channel instanceof Array
        (c for c in channel when not hasPermission sb.instanceId, action, c).length is 0
      else
        hasPermission sb.instanceId, action, channel
    if p is true
      method.apply sb, args
    else false

  tweakSandboxMethod = (sb, methodName) ->
    originalMethod = sb[methodName]
    if typeof originalMethod is "function"
      sb[methodName] = -> grantAction sb, methodName, originalMethod, arguments

  core.permission =
    add: addPermission
    remove: removePermission

  init: (sb) ->
    # override original functions
    tweakSandboxMethod sb, a for a in controlledActions

# AMD support
if define?.amd?
  define -> plugin

# Browser support
else if window?.scaleApp?
  window.scaleApp.plugins.permission = plugin

# Node.js support
else if module?.exports?
  module.exports = plugin
