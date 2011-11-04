class DOMPlugin

  constructor: (@sb) ->

  getContainer: =>
    switch typeof @sb.options.container
      when "string"  then document.getElementById @sb.options.container
      when "object"  then @sb.options.container
      else document.getElementById @sb.instanceId

scaleApp.registerPlugin
  id: "dom"
  sandbox: DOMPlugin
