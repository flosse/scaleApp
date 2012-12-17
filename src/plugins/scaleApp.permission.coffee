permissions = {}

addPermission = (id, action, channels) ->
  if typeof action is "object"
    not false in (addPermission id,k,v for k,v of action)
  else if channels?
    p = permissions[id] ?= {}
    a = p[action] ?= {}
    if typeof channels is "string"
      channels = [channels]
    else if channels is true
      channels = ["__all__"]
    a[c] = true for c in channels
    true
  else
    false

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
 p = hasPermission sb.instanceId, action, channel
 if p is true
   method.apply sb, args
 else false

tweakSandboxMethod = (sb, methodName) ->
  originalMethod = sb[methodName]
  if typeof originalMethod is "function"
    sb[methodName] = -> grantAction sb, methodName, originalMethod, arguments

class SBPlugin

  constructor: (sb) ->

    # override original functions
    tweakSandboxMethod sb, a for a in ["on", "emit", "off"]

plugin =
  id: "permission"
  sandbox: SBPlugin
  core:
    permission:
      add: addPermission
      remove: removePermission

window.scaleApp.plugin.register plugin if window?.scaleApp?
module.exports = plugin if module?.exports?
(define -> plugin) if define?.amd?
