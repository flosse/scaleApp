createPlugin = (scaleApp) ->
  class Model extends scaleApp.Mediator

    constructor: (obj) ->
      super()
      @id = obj?.id or scaleApp.util.uniqueId()
      @[k] = v for k,v of obj when not @[k]?

    set: (key, val, silent=false) ->
      switch typeof key
        when "object"
          @set k,v,true for k,v of key
          @emit Model.CHANGED, (k for k,v of key) if not silent
        when "string"
          if not (key in ["set","get"]) and @[key] isnt val
            @[key] = val
            @emit Model.CHANGED, [key] if not silent
        else console?.error? "key is not a string"
      @

    change: (cb, context) ->
      if typeof cb is "function"
        @on Model.CHANGED, cb, context
      else if arguments.length is 0
        @emit Model.CHANGED

    notify: -> @change()

    get: (key) -> @[key]

    toJSON: ->
      json = {}
      json[k]=v for own k,v of @
      json

    @CHANGED: "changed"

  class View

    constructor: (model) -> @setModel model if model

    setModel: (@model) -> @model.change (-> @render()), @

    render: ->

  class Controller

    constructor: (@model, @view) ->

  p =
    Model: Model
    View: View
    Controller: Controller

  plugin =
    id: "mvc"
    base:p
    sandbox: (@sb) -> p

# AMD support
if define?.amd?
  define ['scaleApp'], (sa) -> createPlugin sa

# Browser support
else if window?.scaleApp?
  sa = window.scaleApp
  sa.plugin.register createPlugin sa

# Node.js support
else if module?.exports?
  module.exports = createPlugin require "../scaleApp"
