/**
 * This example shows how you can build very dynamic
 * applications with require.js.
 */

// set the require.js configuration
require.config({
  urlArgs: "bust=" + (new Date()).getTime(),
  paths:{
    scaleApp: '../../dist/scaleApp',
    plugins: '../../dist/plugins',
    text: 'libs/text'
  }
});

// initialize the application
require([
  'scaleApp',
  'plugins/scaleApp.dom'
  ], function(sa, dom){

  // creata new Core instance
  var core = window.app = new sa.Core();

  // define a simple logger
  var log = function(type, msg){

    // if the log module is running,
    // the messages can be displayed
    core.emit("log/" + type, msg);

    // and use the normal console
    console[type](msg)
  }

  // register DOM plugin
  core.use(dom);

  // create dom container dynamically
  var createContainer = function(module){
    if (!document.getElementById(module)){
      var c = document.createElement("div");
      c.setAttribute('id', module);
      document.getElementsByTagName("body")[0].appendChild(c);
    }
  };

  // remove dom container dynamically
  var deleteContainer = function(module){
    document.getElementById(module).remove();
  };

  // listen to the start event
  core.on("start", function(module){

    log("debug","Try to start module '" + module + "'");

    require(["modules/" + module], function(m){

      createContainer(module);

      // register and start the module
      core.register(module,m).start(module,function(err){
        if(err){
          log("error",err.message);
        } else {
          log("info","sucessfully started '" + module + "'");
        }
      })
    });

  });

  // listen to the stop event
  core.on("stop", function(module){

    log("debug","Try to stop module '" + module + "'");

    core.stop(module,function(err){
      if (err) {
        log("error", err)
      } else {
        deleteContainer(module);
        log("info", "stopped module '" + module + "'");
      }
    });

  });

  // start 'Control' module by default
  core.emit("start", "Control");
});
