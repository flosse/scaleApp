# Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)

# PrivateClass: console
# Some browsers don't support logging via the console object.
# If the console object is not defined, just disable logging,
# else check if all needed functions exists and set a dummy 
# function if a function does not exist

enabled = ( typeof console is "object" )

if enabled

  dummy = ->
    
  for name in [ "log", "debug", "info", "warn", "error", "fatal" ]
    console[name] = dummy if typeof console[name] isnt "function"

# PrivateVariable: currentLogLevel
# Holds the current LogLevel
currentLogLevel = 0

# PrivateConstants: logLevel
# logging level indicators
# 
# Parameters:
# logLevel.DEBUG  - Debug output
# logLevel.INFO   - Informational output
# logLevel.WARN   - Warnings
# logLevel.ERROR  - Errors
# logLevel.FATAL  - Fatal error
logLevel =
  DEBUG:  0
  INFO:   1
  WARN:   2
  ERROR:  3
  FATAL:  4

# PrivateFunction: getLogLevel
getLogLevel = -> currentLogLevel

#  PrivateFunction: setLogLevel
#  
#  Parameters:
#  (String) level - name of the level
setLogLevel = (level) ->

  if typeof level is "string"

    switch level.toLowerCase()
      when "debug" then currentLogLevel = logLevel.DEBUG
      when "info"  then currentLogLevel = logLevel.INFO
      when "warn"  then currentLogLevel = logLevel.WARN
      when "error" then currentLogLevel = logLevel.ERROR
      when "fatal" then currentLogLevel = logLevel.FATAL
      else
        currentLogLevel = logLevel.INFO

  else if typeof level is "number"
    if level >= logLevel.DEBUG and level <= logLevel.FATAL
      currentLogLevel = level
    else
      currentLogLevel = logLevel.INFO

# PrivateFunction: log
# 
# Parameters:
# (String) level  - The log level
# (String) msg    - The messge
# (String) module - The module name
log = (level, msg, module) ->

  if enabled is true
    if module
      if typeof msg is "object"
        log level, module + ":"
        log level, msg
        return
      else
        msg = module + ": " + msg

    switch level
      when logLevel.DEBUG then console.debug  msg  if currentLogLevel <= logLevel.DEBUG
      when logLevel.INFO  then console.info   msg  if currentLogLevel <= logLevel.INFO
      when logLevel.WARN  then console.warn   msg  if currentLogLevel <= logLevel.WARN
      when logLevel.ERROR then console.error  msg  if currentLogLevel <= logLevel.ERROR
      when logLevel.FATAL then console.error  msg  if currentLogLevel <= logLevel.FATAL
      else
        console["log"] msg

# logging functions, each for a different level
debug = (msg, module) ->  log logLevel.DEBUG, msg, module
info =  (msg, module) ->  log logLevel.INFO,  msg, module
warn =  (msg, module) ->  log logLevel.WARN,  msg, module
error = (msg, module) ->  log logLevel.ERROR, msg, module
fatal = (msg, module) ->  log logLevel.FATAL, msg, module

# public API
coreLog =
  debug:  debug
  info:   info
  warn:   warn
  error:  error
  fatal:  fatal
  setLogLevel: setLogLevel
  getLogLevel: getLogLevel

sbLog = (sb, instanceId) ->
  debug:  (msg) -> debug  msg, instanceId
  info:   (msg) -> info   msg, instanceId
  warn:   (msg) -> warn   msg, instanceId
  error:  (msg) -> error  msg, instanceId
  fatal:  (msg) -> fatal  msg, instanceId

scaleApp.registerPlugin "log",
  sandbox: sbLog
  core: coreLog
