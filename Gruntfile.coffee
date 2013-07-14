path   = require "path"

banner =
  """
  /*!
  <%= pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today(\"yyyy-mm-dd\") %>
  This program is distributed under the terms of the <%= pkg.licenses[0].type %> license.
  Copyright (c) 2011-<%= grunt.template.today(\"yyyy\") %> <%= pkg.author %>\n
  */
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
            "src/Sandbox.coffee"
            "src/scaleApp.coffee" ]
      full:
        options:
          join: true
        files:
          "dist/scaleApp.full.js": [
            "src/Util.coffee",
            "src/Mediator.coffee"
            "src/Sandbox.coffee"
            "src/scaleApp.coffee"
            "src/plugins/*.coffee" ]
      plugins:
        expand: true
        flatten: true
        cwd: 'src/plugins/'
        src: ['*.coffee']
        dest: 'dist/plugins/'
        rename: (dest, matchedSrcPath, opts) ->
          path.join dest, path.basename(matchedSrcPath,'.coffee') + '.js'
      modules:
        expand: true
        cwd: 'src/modules/'
        src: ['*.coffee']
        dest: 'dist/modules/'

    copy:
      modules:
        expand: true
        cwd: 'src/modules/'
        src: ['*.html']
        dest: 'dist/modules'

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
        cwd: 'dist/plugins/'
        src: ["*.js"]
        dest: 'dist/plugins/'
        ext: '.min.js'

    watch:
      src:
        files: ["src/*.coffee", "src/**/*.coffee"]
        tasks: ["coffee"]
      styles:
        files: ["src/modules/*.styl"]
        tasks: ["stylus"]

    stylus:
      modules:
        options:
          compress: true

        expand: true
        cwd: 'src/modules/'
        src: ["*.styl"]
        dest: 'dist/modules/'
        ext: '.css'

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-stylus"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.registerTask "default", ["coffee", 'concat', "uglify", "stylus", "copy"]
  grunt.registerTask "core", ["coffee:core", "concat:core", "uglify:core"]
  grunt.registerTask "full", ["coffee:full", "concat:full", "uglify:full"]

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
      minify = (code, resNames) ->
        uglify.uglify.gen_code(uglify.uglify.ast_squeeze(uglify.uglify.ast_mangle(uglify.parser.parse(code),
          except: resNames
        ))) + ";"

      uglify = require("uglify-js")
      grunt.file.write "./dist/scaleApp.custom.min.js", minify(customBuild)
