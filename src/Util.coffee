clone = (data) ->
  if data instanceof Array
    copy = (v for v in data)
  else
    copy = {}
    copy[k] = v for k,v of data
  copy

# support older browsers
if not String::trim?
  String::trim = -> @replace(/^\s\s*/, '').replace(/\s\s*$/, '')

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

uniqueId = (length=8) ->
 id = ""
 id += Math.random().toString(36).substr(2) while id.length < length
 id.substr 0, length

runSeries = (tasks=[], cb=(->), force) ->
  count   = tasks.length
  results = []

  return  cb? null, results if count is 0

  errors  = []
  checkEnd = ->
    count--
    if count is 0
      if (e for e in errors when e?).length > 0
        cb errors, results
      else
        cb null, results

  for t,i in tasks then do (t,i) ->
    next = (err, res...) ->
      if err?
        errors[i] = err
        results[i] = undefined
      else
        results[i] = if res.length < 2 then res[0] else res
      checkEnd()
    try
      t next
    catch e
      next e if force

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

doForAll = (args=[], fn, cb)->
  tasks = for a in args then do (a) -> (next) -> fn a, next
  util.runSeries tasks, cb

util =
  doForAll: doForAll
  runSeries : runSeries
  runWaterfall : runWaterfall
  clone: clone
  getArgumentNames: getArgumentNames
  uniqueId: uniqueId
