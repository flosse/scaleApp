module.exports = function(cfg){
cfg.set({

  basePath: '',

  files: [
    'dist/scaleApp.js',
    'dist/plugins/scaleApp.*.js',
    'node_modules/chai/chai.js',
    'node_modules/sinon/pkg/sinon.js',
    'node_modules/sinon-chai/lib/sinon-chai.js',
    'spec/*.spec.coffee',
    'plugins/spec/scaleApp.*.spec.coffee',
  ],

  frameworks: ["mocha"],

  exclude: [
    'spec/quality.spec.coffee',
    'dist/plugins/scaleApp.*.min.js',
  ],

  // possible values: 'dots', 'progress', 'junit'
  reporters: ['progress', 'coverage'],

  // web server port
  port: 9876,

  // cli runner port
  runnerPort: 9100,

  // enable / disable colors in the output (reporters and logs)
  colors: true,

  // level of logging
  // possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
  logLevel: cfg.LOG_INFO,

  // enable / disable watching file and executing tests whenever any file changes
  autoWatch: false,

  // Start these browsers, currently available:
  // - Chrome
  // - ChromeCanary
  // - Firefox
  // - Opera
  // - Safari (only Mac)
  // - PhantomJS
  // - IE (only Windows)
  browsers: ['PhantomJS'],

  // If browser does not capture in given timeout [ms], kill it
  captureTimeout: 60000,

  // Continuous Integration mode
  // if true, it capture browsers, run tests and exit
  singleRun: true,

  preprocessors: {
    'dist/scaleApp.js': ['coverage'],
    'spec/**/*.coffee':  ['coffee'],
    'plugins/**/*.coffee':  ['coffee']
  }

});};
