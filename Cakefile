fs     = require 'fs'
path   = require 'path'
{exec} = require 'child_process'
util   = require 'util'
coffee = require 'coffee-script'
uglify = require 'uglify-js'

coreName = "scaleApp"
coreCoffeeDir   = 'src'
pluginCoffeeDir  = 'src/plugins'
moduleCoffeeDir  = 'src/modules'
pluginTargetDir  = 'build/plugins'
moduleTargetDir  = 'build/modules'
libDir = 'lib'
targetDir = 'build'

coreCoffeeFiles  = [
  'Mediator'
  'Sandbox'
  'scaleApp'
]

reservedNames  = [ ]

coreDepJsFiles  = [ ]

pluginDeps = {}

createTargetDir = (cb) ->
  util.log "create #{targetDir} directory"
  fs.mkdir targetDir, 0755, cb

minifyJsFile = (file, resNames, cb) ->
  fs.readFile "#{file}.js", 'utf8', (err, code) ->
    util.log err if err
    min = minify code, resNames
    fs.writeFile "#{file}.min.js", min, 'utf8', (err) ->
      util.log err if err
      cb()

minify = (code, resNames) -> uglify.uglify.gen_code(
  uglify.uglify.ast_squeeze(
    uglify.uglify.ast_mangle(
      uglify.parser.parse(code)
      ,{ except: resNames }
    )
  )
)+';'

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
      minifyJsFile "#{dir}/#{f}", reservedNames, ->

    for i in full
      minifyJsFile "#{dir}/#{i}", null, ->

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
  invoke 'build:modules'

task 'build:core', 'Build a single JavaScript file from src files', ->

  checkTargetDir ->

    util.log "Building #{coreName}"
    coreContents = new Array remaining = coreCoffeeFiles.length
    util.log "Appending #{coreCoffeeFiles.length} files to #{coreName}.coffee"
    files = ("#{coreCoffeeDir}/#{f}" for f in coreCoffeeFiles)
    concate files, "coffee", (content) ->
      targetName = "#{targetDir}/#{coreName}"
      code = coffee.compile content
      fs.writeFile "#{targetName}.js", code, 'utf8', (err) ->
        util.log err if err

task 'build:full', "Builds a single file with all plugins", ->

  checkTargetDir ->

    fs.readdir pluginCoffeeDir, (err, files) ->
      pluginFiles = files.filter (s) -> (s.indexOf( ".coffee") isnt -1)

      pluginFiles = ("#{pluginCoffeeDir}/#{f.split(".coffee")[0]}" for f in pluginFiles)
      coreFiles   = ("#{coreCoffeeDir}/#{f}" for f in coreCoffeeFiles)

      all = [ coreFiles..., pluginFiles...]
      concate all, "coffee", (content) ->
        targetName = "#{targetDir}/#{coreName}.full"
        code = coffee.compile content
        min = minify code, reservedNames
        fs.writeFile "#{targetName}.js", code, 'utf8', (err) ->
          util.log err if err
        fs.writeFile "#{targetName}.min.js", min, 'utf8', (err) ->
          util.log err if err

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

task 'build:modules', "Build #{coreName} modules from source files", ->

  checkTargetDir ->

    util.log "Building modules"
    exec "coffee -c -o #{moduleTargetDir} #{moduleCoffeeDir}", (err, stdout, stderr) ->
      util.log err if err

task 'minify',         "Minify all js files", ->
  invoke "build"
  invoke "minify:core"
  invoke "minify:plugins"
  invoke "minify:modules"

task 'minify:core',    "Minify the core",    -> minifyDir targetDir
task 'minify:plugins', "Minify the plugins", -> minifyDir pluginTargetDir
task 'minify:modules', "Minify the modules", -> minifyDir moduleTargetDir

task 'test', "runs the tests", ->

  exec "jasmine-node --coffee spec/", (err, stdout) ->
    util.log err if err
    util.log stdout if stdout

task 'doc', "create docs", ->
  
  checkTargetDir ->

    exec "docco #{coreCoffeeDir}/*.coffee #{pluginCoffeeDir}/*.coffee", (err,stdout) ->
      util.log err if err
      util.log stdout if stdout
