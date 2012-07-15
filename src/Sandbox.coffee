# The sandbox class acts as a facade for a module.
# All sandboxes refer to the same core module
class Sandbox

  # ## Create a sandbox
  #
  # Parameters:
  #
  # - (Object) core       - The core object of scaleApp
  # - (String) instanceId - The instance id
  # - (Object) options    - The options object for that instance
  constructor: (@core, @instanceId, @options = {}) ->
    throw new TypeError "core was not defined" unless @core?
    throw new TypeError "no id was specified"  unless instanceId?
    throw new TypeError "id is not a string"   unless typeof instanceId is "string"

module.exports = Sandbox if module?.exports?
