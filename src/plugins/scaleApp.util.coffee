class UtilPlugin

  constructor: (sb) ->

  countObjectKeys: (o) -> if typeof o is "object" then (k for k,v of o).length

  mixin: (receivingClass, givingClass, override=false) ->

    switch "#{typeof givingClass}-#{typeof receivingClass}"
      when "function-function" then @mix givingClass::, receivingClass::, override
      when "function-object"   then @mix givingClass::, receivingClass,   override
      when "object-object"     then @mix givingClass,   receivingClass,   override
      when "object-function"   then @mix givingClass,   receivingClass::, override

  mix: (giv, rec, override) ->
    if override is true then rec[k]=v for k,v of giv
    else rec[k]=v for k,v of giv when not rec.hasOwnProperty k

plugin =
  id: "util"
  sandbox: UtilPlugin

scaleApp.registerPlugin plugin if scaleApp?
exports.Plugin = plugin if exports?
