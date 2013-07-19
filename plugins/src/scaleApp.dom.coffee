plugin = (core) ->

  cleanHTML = (str) ->

    # remove newline / carriage return
    str.replace(/\n/g, "")

    #remove whitespace (space and tabs) before tags
    .replace(/[\t ]+\</g, "<")

    #remove whitespace between tags
    .replace(/\>[\t ]+\</g, "><")

    #remove whitespace after tags
    .replace(/\>[\t ]+$/g, ">")

  core.html = html = clean: cleanHTML

  init: (sb) ->

    sb.getContainer = ->
      switch typeof sb.options.container
        when "string"  then document.getElementById sb.options.container
        when "object"  then sb.options.container
        else document.getElementById sb.instanceId

    html: html

# AMD support
if define?.amd?
  define -> plugin

# Browser support
else if window?.scaleApp?
  window.scaleApp.plugins.dom = plugin

# Node.js support
else if module?.exports?
  module.exports = plugin
