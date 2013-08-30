getArgumentNames = (fn=->) ->
  args = fn.toString().match ///
    function    # start with 'function'
    [^(]*       # any character but not '('
    \(          # open bracket = '(' character
      ([^)]*)   # any character but not ')'
    \)          # close bracket = ')' character
  ///
  return [] if not args? or (args.length < 2)
  args = args[1]
  args = args.split /\s*,\s*/
  (a for a in args when a.trim() isnt '')

# run asynchronous tasks in parallel
runParallel = (tasks=[], cb=(->), force) ->
  count   = tasks.length
  results = []

  return cb null, results if count is 0

  errors  = []

  for t,i in tasks then do (t,i) ->
    next = (err, res...) ->
      if err
        errors[i] = err
        return cb errors, results unless force
      else
        results[i] = if res.length < 2 then res[0] else res
      if --count is 0
        if (e for e in errors when e?).length > 0
          cb errors, results
        else
          cb null, results
    try
      t next
    catch e
      next e

# run asynchronous tasks one after another
runSeries = (tasks=[], cb=(->), force) ->
  i = -1
  count   = tasks.length
  results = []
  return cb null, results if count is 0

  errors  = []
  next = (err, res...) ->
    if err
      errors[i] = err
      return cb errors, results unless force
    else
      results[i] = if res.length < 2 then res[0] else res
    if ++i is count
      if (e for e in errors when e?).length > 0
        cb errors, results
      else
        cb null, results
    else
      try
        tasks[i] next
      catch e
        next e
  next()

# run asynchronous tasks one after another
# and pass the argument
runWaterfall = (tasks, cb) ->
  i = -1
  return cb() if tasks.length is 0

  next = (err, res...) ->
    return cb err if err?
    if ++i is tasks.length
      cb null, res...
    else
      tasks[i] res..., next
  next()

doForAll = (args=[], fn, cb, force)->
  tasks = for a in args then do (a) -> (next) -> fn a, next
  util.runParallel tasks, cb, force

util =
  doForAll: doForAll
  runParallel : runParallel
  runSeries : runSeries
  runWaterfall : runWaterfall
  getArgumentNames: getArgumentNames
  hasArgument: (fn, idx=1) -> util.getArgumentNames(fn).length >= idx
