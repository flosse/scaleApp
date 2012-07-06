fs     = require 'fs'
{exec} = require 'child_process'
coffee = require 'coffee-script'
uglify = require 'uglify-js'

srcDir    = 'src'
targetDir = 'build'

coreFiles  = [ 'Mediator', 'Sandbox', 'scaleApp' ]

minify = (code, resNames) -> uglify.uglify.gen_code(
  uglify.uglify.ast_squeeze(
    uglify.uglify.ast_mangle(
      uglify.parser.parse(code)
      ,{ except: resNames }
    )
  )
)+';'

concate = (files, type, wrapEach, cb) ->
  if not cb?
    cb = wrapEach
    wrapEach = true
  concateContents = new Array filesRemaining = files.length

  for file, index in files then do (file, index) ->
    fs.readFile "#{file}.#{type}", 'utf8', (err, fileContents) ->
      console.log err if err
      concateContents[index] = fileContents
      if --filesRemaining is 0
        if type is 'coffee'
          if wrapEach
            cb (coffee.compile c for c in concateContents).join '\n'
          else
            cb coffee.compile concateContents.join '\n'
        else
          cb concateContents.join '\n'

checkDir = (d) -> fs.mkdirSync d if not fs.existsSync d
checkTargetDir = -> checkDir targetDir

watchDir = (dir) ->

  console.log "Watching for changes in #{dir}"
  files = fs.readdirSync "#{dir}"
  files = ("#{dir}/#{f}" for f in files when f.indexOf('.coffee') isnt -1)
  for file in files then do (file) ->
    fs.watchFile file, (curr, prev) ->
      if +curr.mtime isnt +prev.mtime
        console.log "Saw change in #{file}"
        invoke 'build'

task 'build', 'Build all', ->
  invoke 'compile'
  invoke 'bundle'

option '-p',    '--include-plugins [PLUGIN_NAMES]', "bundles scaleApp with defined plugins"

task 'compile', 'compiles to JS', ->

  exec "coffee -c -o #{targetDir} #{srcDir}", (err, stdout, stderr) ->
    console.error err if err
    console.error stderr if stderr

task 'bundle', 'create browser bundles', (opts) ->

  checkTargetDir()
  dir = "#{targetDir}/bundles"
  checkDir dir

  files = ("#{srcDir}/#{f}" for f in coreFiles)

  concate files, "coffee", false, (core) ->
    targetName = "#{dir}/scaleApp"

    if opts['include-plugins']?
      plugins = opts['include-plugins'].split ','
      plugins  = ("#{srcDir}/plugins/scaleApp.#{f}" for f in plugins)
      concate plugins, "coffee", (pluginCode) ->
        code = core+pluginCode
        fs.writeFileSync "#{targetName}.custom.js", code, 'utf8'
        fs.writeFileSync "#{targetName}.custom.min.js", (minify code), 'utf8'

    else
      fs.writeFile "#{targetName}.js", core, 'utf8', (err) ->
        console.error err if err
      fs.writeFile "#{targetName}.min.js",(minify core), 'utf8', (err) ->
        console.error err if err

      fs.readdir "#{srcDir}/plugins", (err, files) ->
        pluginFiles = files.filter (s) -> (s.indexOf( ".coffee") isnt -1)
        pluginFiles = ("#{srcDir}/plugins/#{f.split(".coffee")[0]}" for f in pluginFiles)
        concate pluginFiles, "coffee", (pluginCode) ->
          code = core+pluginCode
          fs.writeFile "#{targetName}.full.js", code, 'utf8', (err) ->
            console.error err if err
          fs.writeFile "#{targetName}.full.min.js", (minify code), 'utf8', (err) ->
            console.error err if err

task 'watch', 'Watch source files and build changes', ->

  invoke "build"
  watchDir "#{srcDir}"
  watchDir "#{srcDir}/plugins"

task 'doc', "create docs", ->
  exec "docco #{srcDir}/*.coffee #{srcDir}/plugins/*.coffee", (err, stdout) ->
    console.error err if err
