path   = require "path"

renameCoffe2js = (dest, matchedSrcPath, opts) ->
  path.join dest, path.basename(matchedSrcPath,'.coffee') + '.js'

renameJs2min = (dest, matchedSrcPath, opts) ->
  path.join dest, path.basename(matchedSrcPath,'.js') + '.min.js'

banner =
  """
  /*!
  <%= pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today(\"yyyy-mm-dd\") %>
  This program is distributed under the terms of the <%= pkg.licenses[0].type %> license.
  Copyright (c) 2011-<%= grunt.template.today(\"yyyy\") %> <%= pkg.author %>
  */\n
  """

module.exports = (grunt) ->
  grunt.initConfig

    pkg: grunt.file.readJSON "package.json"

    concat:
      options:
        banner: banner
      core:
        files:
          "dist/scaleApp.js": ["dist/scaleApp.js"]
      full:
        files:
          "dist/scaleApp.full.js": ["dist/scaleApp.full.js"]

    coffee:
      core:
        options:
          join: true
        files:
          "dist/scaleApp.js": [
            "src/Util.coffee"
            "src/Mediator.coffee"
            "src/Core.coffee"
            "src/scaleApp.coffee" ]
      full:
        options:
          join: true
        files:
          "dist/scaleApp.full.js": [
            "src/Util.coffee",
            "src/Mediator.coffee"
            "src/Core.coffee"
            "src/scaleApp.coffee"
            "plugins/src/*.coffee" ]
      plugins:
        expand: true
        flatten: true
        cwd: 'plugins/src'
        src: ['*.coffee']
        dest: 'dist/plugins/'
        rename: renameCoffe2js

    uglify:
      options:
        banner: banner
        mangle:
          toplevel: false

        squeeze:
          dead_code: true

        codegen:
          quote_keys: false
      core:
        files:
          'dist/scaleApp.min.js': ["dist/scaleApp.js"]
      full:
        files:
          'dist/scaleApp.full.min.js': ["dist/scaleApp.full.js"]
      plugins:
        expand: true
        flatten: true
        cwd: 'dist/plugins/'
        src: ["*.js","!*.min.js"]
        dest: 'dist/plugins/'
        rename: renameJs2min

    watch:
      src:
        files: ["src/*.coffee", "src/**/*.coffee"]
        tasks: ["coffee"]

    coffeelint:
      core: ["src/*.coffee"]
      options:
        no_trailing_whitespace:
          level: "warn"

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.registerTask "default", ["coffeelint", "coffee", "concat", "uglify" ]

  # Quick and dirty task to build a custom bundle
  # Does s.o. know how to do that properly?
  grunt.registerTask "custom", "create a custom bundle", ->
    if @args.length is 0
      grunt.warn @name + ", no plugins specified"
    else
      base = grunt.file.read("./dist/scaleApp.js")
      plugins = ""
      i = 0
      while i < @args.length
        try
          plugins += "\n" + grunt.file.read("./dist/plugins/scaleApp." + @args[i] + ".js")
        catch e
          console.log e
          grunt.warn "could not find \"" + @args[i] + "\" plugin"
        i++
      customBuild = base + "\n" + plugins
      grunt.file.write "./dist/scaleApp.custom.js", customBuild
      min = require("uglify-js").minify customBuild, fromString:true
      grunt.file.write "./dist/scaleApp.custom.min.js", min.code
