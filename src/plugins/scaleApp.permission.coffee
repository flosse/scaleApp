permissions = {}

addPermission = (id, action, channels) ->
  if channels?
    p = permissions[id] ?= {}
    a = p[action] ?= {}
    if typeof channels is "string"
      channels = [channels]
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
  if channel? and permissions[id]?[action]?[channel]
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
    tweakSandboxMethod sb, "subscribe"
    tweakSandboxMethod sb, "publish"
    tweakSandboxMethod sb, "unsubscribe"

plugin =
  id: "permission"
  sandbox: SBPlugin
  core:
    permission:
      add: addPermission
      remove: removePermission

window.scaleApp.registerPlugin plugin if window?.scaleApp?
module.exports = plugin if module?.exports?
(define -> plugin) if define?.amd?
