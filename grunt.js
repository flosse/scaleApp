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
      }
    },
    coffee: {
      compile: {
        files: {
          "dist/scaleApp.js": 'dist/scaleApp.coffee',
          "dist/plugins/*.js": 'src/plugins/*.coffee',
          "dist/modules/*.js": 'src/modules/*.coffee'
        }
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
  grunt.registerTask('default', 'concat coffee copy min');

};

