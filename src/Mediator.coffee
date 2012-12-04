class Mediator

  constructor: (obj, @cascadeChannels=false) ->
    @channels = {}
    @installTo obj if obj

  # ## Subscribe to a topic
  #
  # Parameters:
  #
  # - (String) topic      - The topic name
  # - (Function) callback - The function that gets called if an other module
  #                         publishes to the specified topic
  # - (Object) context    - The context the function(s) belongs to
  subscribe: (channel, fn, context=@) ->

    @channels[channel] ?= []
    that = @

    if channel instanceof Array
      @subscribe id, fn, context for id in channel
    else if typeof channel is "object"
      @subscribe k,v,fn for k,v of channel
    else
      return false unless typeof fn      is "function"
      return false unless typeof channel is "string"
      subscription = { context: context, callback: fn }
      (
        attach: -> that.channels[channel].push subscription; @
        detach: -> Mediator._rm that, channel, subscription.callback; @
      ).attach()

  # Alias for subscribe
  on: @::subscribe

  # ## Unsubscribe from a topic
  #
  # Parameters:
  #
  # - (String) topic      - The topic name
  # - (Function) callback - The function that gets called if an other module
  #                         publishes to the specified topic
  unsubscribe: (ch, cb) ->
    switch typeof ch
      when "string"
        Mediator._rm @,ch,cb if typeof cb is "function"
        Mediator._rm @,ch    if typeof cb is "undefined"
      when "function"  then Mediator._rm @,id,ch      for id of @channels
      when "undefined" then Mediator._rm @,id         for id of @channels
      when "object"    then Mediator._rm @,id,null,ch for id of @channels
    @

  # ## Publish an event
  #
  # Parameters:
  # (String) topic             - The topic name
  # (Object) data              - The data that gets published
  # (Object)
  #     callback:              - callback metthod
  #     publishReference       - If the data should be passed as a reference to
  #                              the other modules this parameter has to be set
  #                              to *true*.
  #                              By default the data object gets copied so that
  #                              other modules can't influence the original
  #                              object.
  publish: (channel, data, opt={}) ->

    if typeof data is "function"
      opt  = data
      data = undefined
    return false unless typeof channel is "string"
    subscribers = @channels[channel] or []

    if typeof data is "object" and opt.publishReference isnt true
      copy = util.clone data

    tasks = for sub in subscribers then do (sub) ->
      (next) ->
        try
          if (util.getArgumentNames sub.callback).length >= 3
            sub.callback.apply sub.context, [(copy or data), channel, next]
          else
            next null, sub.callback.apply sub.context, [(copy or data), channel]
        catch e
          next e

    util.runSeries tasks,((errors, results) ->
      if errors
        e = new Error (x.message for x in errors when x?).join '; '
      opt? e), true

    if @cascadeChannels and (chnls = channel.split('/')).length > 1
      @publish chnls[0...-1].join('/'), data, opt
    @

  # Alias for publish
  emit: @::publish

  # ## Install Pub/Sub functions to an object
  installTo: (obj) ->
    if typeof obj is "object"
      obj[k] = v for k,v of @
    @

  @_rm: (o, ch, cb, ctxt) ->
    o.channels[ch] = (s for s in o.channels[ch] when (
      if cb?
        s.callback isnt cb
      else if ctxt?
        s.context isnt ctxt
      else
        s.context isnt o
    ))
