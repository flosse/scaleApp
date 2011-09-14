fs     = require 'fs'
path   = require 'path'
{exec} = require 'child_process'
util   = require 'util'

require.paths.push '/usr/local/lib/node_modules'
coffee    = require 'coffee-script'
uglify    = require 'uglify-js'

coreName = "scaleApp"
coreCoffeeDir   = 'src'
pluginCoffeeDir  = 'src/plugins'
pluginTargetDir  = 'build/plugins'
libDir = 'lib'
targetDir = 'build'

coreCoffeeFiles  = [
  'scaleApp.Mediator'
  'scaleApp.Sandbox'
  'scaleApp.core'
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
  res = if resNames then "--reserved-names #{resNames.join ',' } " else ""
  exec "uglifyjs -o #{file}.min.js #{res}#{file}.js", (err) ->
    util.log err if err
    cb()

minify = (code, resNames) -> uglify.uglify.gen_code(
  uglify.uglify.ast_squeeze(
    uglify.uglify.ast_mangle(
      uglify.parser.parse(code)
      ,{ except: resNames }
    )
  )
)

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
      minifyFile "#{dir}/#{f}", reservedNames, ->

    for i in full
      minifyFile "#{dir}/#{i}", null, ->

concate = (files, type, cb) ->
  concateContents = new Array filesRemaining = files.length
  util.log "concate #{filesRemaining} files"

  for file, index in files then do (file, index) ->
    fs.readFile "#{file}.#{type}", 'utf8', (err, fileContents) ->
      util.log err if err
      concateContents[index] = fileContents
      if --filesRemaining is 0
        cb concateContents.join '\n\n'

checkTargetDir = (cb) -> path.exists targetDir, (exists) ->
  if not exists then createTargetDir (err) ->
    util.log err if err
    cb()
  else cb()

task 'build', 'Build all', ->
  invoke 'build:core'
  invoke 'build:plugins'

task 'build:core', 'Build a single JavaScript file from src files', ->

  checkTargetDir ->

    util.log "Building #{coreName}"
    coreContents = new Array remaining = coreCoffeeFiles.length
    util.log "Appending #{coreCoffeeFiles.length} files to #{coreName}.coffee"
    files = ("#{coreCoffeeDir}/#{f}" for f in coreCoffeeFiles)
    concate files, "coffee", (content) ->
      targetName = "#{targetDir}/#{coreName}"
      code = coffee.compile content
      fs.writeFile "#{targetName}.min.js", code, 'utf8', (err) ->
        util.log err if err

task 'build:full', "Builds a single file with all dependencies and plugins", ->

  libs = []

  for f in coreDepJsFiles
    libs.push "lib/#{f}"

  for plugin, dep of pluginDeps
    libs.push "lib/#{dep}"

  concate libs, "js", ->

    allCoreFiles.push "#{targetDir}/#{coreName}"

    allCoreFiles = []


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

       # for plugin, dep of pluginDeps
       #   do ->
       #     libs = []
       #     pluginName = "#{coreName}.#{plugin}"
       #     libs.push "#{libDir}/#{f}" for f in dep
       #     libs.push "#{pluginTargetDir}/#{pluginName}"
       #     util.log n for n in libs

       #     concate "#{pluginTargetDir}/#{pluginName}.full", "js", (content) ->
       #       #  util.log err if err

task 'minify:plugins', "Minify the plugins", -> minifyDir pluginTargetDir

task 'minify:core', "Minify the core", -> minifyDir targetDir

task 'test', "runs the tests", ->

  exec "cake build:core", (err, stdout) ->
    util.log err if err
    util.log stdout if stdout

    exec "cake build:plugins", (err, stdout) ->
      util.log err if err
      util.log stdout if stdout

      exec "coffee -c spec/", (err, stdout) ->
        util.log err if err
        util.log stdout if stdout

        exec "./runTests.sh", (err, stdout) ->
          util.log err if err
          util.log stdout if stdout
