module.exports = function(grunt) {

  grunt.initConfig({
    pkg: '<json:package.json>',
    meta: {
      banner: '###\n<%= pkg.name %> - v<%= pkg.version %> - ' +
       '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
       'This program is distributed under the terms of ' +
       'the <%= pkg.licenses[0].type %> license.\n' +
       'Copyright (c) 2011-<%= grunt.template.today("yyyy") %> '+
       ' <%= pkg.author %>\n###',
    },
    concat: {
      dist: {
        src: [
          '<banner>',
          'src/Util.coffee',
          'src/Mediator.coffee',
          'src/Sandbox.coffee',
          'src/scaleApp.coffee'
        ],
        dest: 'dist/scaleApp.coffee'
      },
      full: {
        src: [
          'dist/scaleApp.js',
          'dist/plugins/*.js'
        ],
        dest: 'dist/scaleApp.full.js'
      }
    },
    coffee: {
      compile: {
        files: {
          "dist/scaleApp.js":  'dist/scaleApp.coffee',
          "dist/plugins/*.js": 'src/plugins/*.coffee',
          "dist/modules/*.js": 'src/modules/*.coffee'
        },
      }
    },
    copy: {
      dist: {
        files: {
          "dist/modules/":"src/modules/*.css"
        }
      }
    },
    min: {
      dist: {
        src: ["dist/scaleApp.js"],
        dest: "dist/scaleApp.min.js"
      },
      full: {
        src: ["dist/scaleApp.full.js"],
        dest: "dist/scaleApp.full.min.js"
      }
    },
    uglify: {
      mangle:  {toplevel: false},
      squeeze: {dead_code: true},
      codegen: {quote_keys: false}
    },
    watch: {
      src: {
        files: ['src/*.coffee', 'src/**/*.coffee'],
        tasks: ['default']
      }
    }
  });

  grunt.loadNpmTasks("grunt-contrib-coffee");
  grunt.loadNpmTasks("grunt-contrib-copy");
  grunt.registerTask('default', 'concat:dist coffee concat:full min copy');

  // Quick and dirty task to build a custom bundle
  // Does s.o. know how to do that properly?
  grunt.registerTask('custom', 'create a custom bundle', function(){

    if (this.args.length === 0) {
      grunt.warn(this.name + ", no plugins specified");
    }
    else {
      base = grunt.file.read('./dist/scaleApp.js')
      plugins = ''
      for(i=0; i<this.args.length; i++){
        try{
          plugins += '\n' + grunt.file.read('./dist/plugins/scaleApp.' + this.args[i] + '.js');
        }catch(e){
          console.log(e);
          grunt.warn('could not find "' + this.args[i] + '" plugin');
        }
      }
      var customBuild = base + '\n' + plugins;
      grunt.file.write('./dist/scaleApp.custom.js', customBuild);
      var minify = function(code, resNames){
        return uglify.uglify.gen_code(
          uglify.uglify.ast_squeeze(
            uglify.uglify.ast_mangle(
              uglify.parser.parse(code)
              ,{ except: resNames }
            )
          )
        )+';'
      };
      var uglify = require("uglify-js");
      grunt.file.write('./dist/scaleApp.custom.min.js', minify(customBuild));
    }
  });
};

