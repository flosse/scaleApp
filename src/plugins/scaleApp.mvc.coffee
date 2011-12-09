class Model extends scaleApp.Mediator

  constructor: (obj) ->
    super()
    @id = obj?.id or scaleApp.uniqueId()
    @[k] = v for k,v of obj when not @[k]?

  set: (key, val, silent=false) ->
    switch typeof key
      when "object"
        @set k,v,true for k,v of key
        @publish "changed", (k for k,v of key) if not silent
      when "string"
        if not (key in ["set","get"]) and @[key] isnt val
          @[key] = val
          @publish "changed", [key] if not silent
      else console?.error? "key is not a string"
    @

  change: -> @publish "changed"

  get: (key) -> @[key]

  toJSON: ->
    json = {}
    json[k]=v for own k,v of @
    json

class View

  constructor: (model) -> @setModel model if model

  setModel: (@model) -> @model.subscribe "changed", @render, @

  render: ->

class Controller

  constructor: (@model, @view) ->

scaleApp.registerPlugin
  id: "mvc"
  core:
    Model: Model
    View: View
    Controller: Controller
