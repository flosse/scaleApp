scaleApp = window?.scaleApp or require? "../scaleApp"

class StateMachine

  constructor: (opts={}) ->
    @states      = []
    @transitions = {}
    if opts.start?
      @addState opts.start
      @start   = opts.start
      @current = opts.start
    if opts.states?
      @addState s for s in opts.states
    if opts.transitions?
      @addTransition id,t for id,t in opts.transitions

  start:    null
  current:  null
  exit:     null

  addState: (id) ->
    if id instanceof Array
      return not (false in (@addState s for s in id))
    else
      return false unless typeof id is "string"
      if id in @states
        false
      else
        @states.push id
        true

  addTransition: (id, edge) ->
    return false unless (typeof id      is "string" ) and
                        (typeof edge.to is "string" ) and
                        (not @transitions[id]? )      and
                        (edge.to in @states )

    if edge.from instanceof Array
      err = false in (i in @states for i in edge.from)
      return false unless err is false

    else if typeof edge.from isnt "string"
      return false

    @transitions[id] = { from: edge.from, to: edge.to }
    true

  fire: (id) ->
    t = @transitions[id]
    return false unless @can id
    @current = t.to
    true

  can: (id) ->
    t = @transitions[id]
    t?.from is @current or
    @current in t or
    t.from is "*"

plugin =
  id: "state"
  core:
    StateMachine: StateMachine

scaleApp.registerPlugin plugin if window?.scaleApp?
module.exports = plugin if module?.exports?
(define -> plugin) if define?.amd?
