cleanHTML = (str) ->

  # remove newline / carriage return
  str.replace(/\n/g, "")

  #remove whitespace (space and tabs) before tags
  .replace(/[\t ]+\</g, "<")

  #remove whitespace between tags
  .replace(/\>[\t ]+\</g, "><")

  #remove whitespace after tags
  .replace(/\>[\t ]+$/g, ">")

html = clean: cleanHTML

class DOMPlugin

  constructor: (@sb) ->

  getContainer: =>
    switch typeof @sb.options.container
      when "string"  then document.getElementById @sb.options.container
      when "object"  then @sb.options.container
      else document.getElementById @sb.instanceId

  html: html

plugin =
  id: "dom"
  sandbox: DOMPlugin
  base: html: html

window.scaleApp.plugin.register plugin if window.scaleApp?
module.exports = plugin if module?.exports?
(define -> plugin) if define?.amd?
