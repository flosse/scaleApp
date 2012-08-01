class DOMPlugin

  constructor: (@sb) ->

  getContainer: =>
    switch typeof @sb.options.container
      when "string"  then document.getElementById @sb.options.container
      when "object"  then @sb.options.container
      else document.getElementById @sb.instanceId

plugin =
  id: "dom"
  sandbox: DOMPlugin

window.scaleApp.registerPlugin plugin if window.scaleApp?
module.exports = plugin if module?.exports?
(define -> plugin) if define?.amd?
