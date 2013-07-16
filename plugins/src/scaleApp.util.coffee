plugin = (core) ->

  mix = (giv, rec, override) ->
    if override is true then rec[k]=v for k,v of giv
    else rec[k]=v for k,v of giv when not rec.hasOwnProperty k

  core.uniqueId = (length=8) ->
    id = ""
    id += Math.random().toString(36).substr(2) while id.length < length
    id.substr 0, length

  core.clone = (data) ->
    if data instanceof Array
      copy = (v for v in data)
    else
      copy = {}
      copy[k] = v for k,v of data
    copy

  core.countObjectKeys = (o) ->
    if typeof o is "object" then (k for k,v of o).length

  core.mixin = (receivingClass, givingClass, override=false) ->

    switch "#{typeof givingClass}-#{typeof receivingClass}"
      when "function-function" then mix givingClass::, receivingClass::, override
      when "function-object"   then mix givingClass::, receivingClass,   override
      when "object-object"     then mix givingClass,   receivingClass,   override
      when "object-function"   then mix givingClass,   receivingClass::, override


# AMD support
if define?.amd?
  define -> plugin

# Browser support
else if window?.scaleApp?
  window.scaleApp.plugins.util = plugin

# Node.js support
else if module?.exports?
  module.exports = plugin
