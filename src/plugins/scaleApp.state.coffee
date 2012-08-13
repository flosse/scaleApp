scaleApp = window?.scaleApp or require? "../scaleApp"

leaveChannel = (state) -> "#{state}/leave"
enterChannel = (state) -> "#{state}/enter"

class StateMachine extends scaleApp.Mediator

  constructor: (opts={}) ->
    super()
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

  addState: (id, opt={}) ->
    if id instanceof Array
      return not (false in (@addState s for s in id))
    else if typeof id is "object"
      return not (false in (@addState k,v for k,v of id))
    else
      return false unless typeof id is "string"
      return false if id in @states
      @states.push id
      success = []
      if opt.enter?
        success.push @on enterChannel(id), opt.enter
      if opt.leave?
        success.push @on leaveChannel(id), opt.leave
      return not (false in success)

  addTransition: (id, edge) ->
    return false unless (typeof id      is "string" ) and
                        (typeof edge.to is "string" ) and
                        (not @transitions[id]? )      and
                        (edge.to in @states)

    if edge.from instanceof Array
      err = false in (i in @states for i in edge.from)
      return false unless err is false

    else if typeof edge.from isnt "string"
      return false

    @transitions[id] = { from: edge.from, to: edge.to }
    true

  onEnter: (state, cb) ->
    return false if not state in @states
    @on enterChannel(state), cb

  onLeave: (state, cb) ->
    return false if not state in @states
    @on leaveChannel(state), cb

  fire: (id, callback=->) =>
    t = @transitions[id]
    return false unless t? and @can id

    @emit leaveChannel(t.from), t, (err) =>
      if err?
        callback err
      else
        @emit enterChannel(t.to), t, (err) =>
          @current = t.to if not err?
          callback err
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
