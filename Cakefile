fs     = require 'fs'
path   = require 'path'
{exec} = require 'child_process'
util   = require 'util'

coreName = "scaleApp"
coreCoffeeDir   = 'src'
pluginCoffeeDir  = 'src/plugins'
pluginTargetDir  = 'build/plugins'
libDir = 'lib'
targetDir = 'build'

coreCoffeeFiles  = [
  'scaleApp.core'
  'scaleApp.util'
  'scaleApp.sandbox'
]

reservedNames  = [
  '$'
  'jQuery'
]

coreDepJsFiles  = [ 'jquery-1.6.2.min' ]

pluginDeps =
  "template" : [ 'jquery.tmpl' ]
  "hotkeys"  : [ 'jquery.hotkeys' ]

createTargetDir = (cb) ->
  util.log "create #{targetDir} directory"
  fs.mkdir targetDir, 0755, cb

minify = (file, resNames, cb) ->
  res = if resNames then "--reserved-names #{resNames.join(',')} " else ""
  exec "uglifyjs -o #{file}.min.js #{res}#{file}.js", (err) ->
    util.log err if err
    cb()

filterJsFiles = (files) -> files.filter (s) -> (s.indexOf( ".js") isnt -1)

filterFullFiles = (files) -> files.filter (s) -> (s.indexOf(".full.js") isnt -1)

filterSingleFiles = (files) -> files.filter (s) ->
  not (s.indexOf( ".full.js") isnt -1) and
  not (s.indexOf( ".js.") isnt -1) and
  not (s.indexOf( ".min.js") isnt -1) and
  (s.indexOf( ".js") isnt -1)

minifyDir = (dir)->

  fs.readdir dir, (err, files) ->
    util.log err if err

    single = filterSingleFiles files
    full = filterFullFiles files

    single = single.map (s) ->
      s.replace(".js","")

    full = full.map (s) ->
      s.replace(".js","")

    for f in single
      minify "#{dir}/#{f}", reservedNames, ->

    for i in full
      minify "#{dir}/#{i}", null, ->

concate = (out, files, src, target, type, cb) ->
  concateContents = new Array filesRemaining = files.length
  util.log "concate #{filesRemaining} files to #{target}/#{out}.#{type}"

  srcDir = ""
  if typeof src is "string" then srcDir = "#{src}/"

  targetDir = ""
  if typeof target is "string" then targetDir = "#{target}/"

  for file, index in files then do (file, index) ->
    fs.readFile "#{srcDir}#{file}.#{type}", 'utf8', (err, fileContents) ->
      util.log err if err
      concateContents[index] = fileContents
      if --filesRemaining is 0
        fs.writeFile "#{targetDir}#{out}.#{type}", concateContents.join('\n\n'), 'utf8', cb

checkTargetDir = (cb) -> path.exists targetDir, (exists) ->
  if not exists then createTargetDir (err) ->
    util.log err if err
    cb()
  else cb()

task 'build', 'Build all', ->
  invoke 'build:core'
  invoke 'build:plugins'

task 'build:core', 'Build a single JavaScript file from src files', ->

  checkTargetDir -> go()

  go = ->
    util.log "Building #{coreName}"
    coreContents = new Array remaining = coreCoffeeFiles.length
    util.log "Appending #{coreCoffeeFiles.length} files to #{coreName}.coffee"

    concate coreName, coreCoffeeFiles, coreCoffeeDir, targetDir, "coffee", (err) ->
      util.log err if err

      targetName = "#{targetDir}/#{coreName}"
      exec "coffee -c #{targetName}.coffee", (err, stdout, stderr) ->
        util.log err if err
        util.log "Compiled #{coreName}.js"
        fs.unlink "#{targetName}.coffee", (err) ->
          util.log err if err

task 'build:full', "Builds a single file with all dependencies and plugins", ->

  allCoreFiles = []
  for f in coreDepJsFiles
    allCoreFiles.push "lib/#{f}"
  allCoreFiles.push "#{targetDir}/#{coreName}"

  fs.readdir pluginTargetDir, (err, files) ->
    util.log err if err

    full = filterFullFiles files
    single = filterSingleFiles files

    dublicates = []

    for i in single
      for k in full
        if i.replace(".js","") is k.replace(".full.js","")
          dublicates.push i

    for i in dublicates
      idx = single.indexOf i
      single.splice idx, 1

    single = single.map (s) ->
      s.replace(".js","")

    full = full.map (s) ->
      s.replace(".js","")

    for f in full
      allCoreFiles.push "#{pluginTargetDir}/#{f}"

    for f in single
      allCoreFiles.push "#{pluginTargetDir}/#{f}"

    concate "#{coreName}.full", allCoreFiles, null, targetDir, "js", (err) ->


task 'watch', 'Watch prod source files and build changes', ->
  util.log "Watching for changes in #{coreCoffeeDir}/"

  for file in coreCoffeeDir then do (file) ->
    fs.watchFile "#{coreCoffeeDir}/#{file}.coffee", (curr, prev) ->
      if +curr.mtime isnt +prev.mtime
        util.log "Saw change in #{coreCoffeeDir}/#{file}.coffee"
        invoke 'build'

task 'build:plugins', "Build #{coreName} plugins from source files", ->

  checkTargetDir ->

    util.log "Building plugins"
    exec "coffee -c -o #{pluginTargetDir} #{pluginCoffeeDir}", (err, stdout, stderr) ->
      util.log err if err

      # copy js plugins
      exec "cp #{pluginCoffeeDir}/*.js #{pluginTargetDir}/", (err, stdout, stderr) ->
        util.log err if err

        for plugin, dep of pluginDeps
          (->
            libs = []
            pluginName = "#{coreName}.#{plugin}"
            libs.push "#{libDir}/#{f}" for f in dep
            libs.push "#{pluginTargetDir}/#{pluginName}"
            util.log n for n in libs

            concate "#{pluginTargetDir}/#{pluginName}.full", libs, null, null, "js", (err) ->
              util.log err if err
          )()

task 'minify:plugins', "Minify the plugins", -> minifyDir pluginTargetDir

task 'minify:core', "Minify the core", -> minifyDir targetDir
