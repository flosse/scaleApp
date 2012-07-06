scaleApp = window?.scaleApp or require? "../scaleApp"

class Model extends scaleApp.Mediator

  constructor: (obj) ->
    super()
    @id = obj?.id or scaleApp.uniqueId()
    @[k] = v for k,v of obj when not @[k]?

  set: (key, val, silent=false) ->
    switch typeof key
      when "object"
        @set k,v,true for k,v of key
        @publish Model.CHANGED, (k for k,v of key) if not silent
      when "string"
        if not (key in ["set","get"]) and @[key] isnt val
          @[key] = val
          @publish Model.CHANGED, [key] if not silent
      else console?.error? "key is not a string"
    @

  change: (cb, context) ->
    if typeof cb is "function"
      @subscribe Model.CHANGED, cb, context
    else if arguments.length is 0
      @publish Model.CHANGED

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

plugin =
  id: "mvc"
  core:
    Model: Model
    View: View
    Controller: Controller

scaleApp.registerPlugin plugin if window?.scaleApp?
module.exports = plugin if module?.exports?
