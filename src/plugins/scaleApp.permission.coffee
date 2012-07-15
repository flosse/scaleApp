Mediator = window?.scaleApp?.Mediator or require? "../Mediator"

permissions = {}

addPermission = (id, action) ->
  p = permissions[id] ?= {}
  p[action] = true

removePermission = (id, action) ->
  p = permissions[id]
  if not p?
    false
  else
    delete p[action]
    true

hasPermission = (id, action) ->
  p = permissions[id]?[action]
  if p?
    true
  else
    console.warn "#{id} has no permissions for '#{action}'"
    false

grantAction = (sb, action, method, args) ->
  p = hasPermission sb.instanceId, action
  if p is true
    method.apply sb, args
  else false

tweakSandboxMethod = (sb, methodName) ->
  originalMethod = sb[methodName]
  if typeof(originalMethod) is "function"
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
