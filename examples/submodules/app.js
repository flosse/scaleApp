var sa        = require("../../dist/scaleApp");
var submodule = require("../../dist/plugins/scaleApp.submodule");

var moduleC = function(sb){
  return {
    init: function(){
      console.log("starting module C");
    },
    destroy: function(done){
      console.log("stopping module C first");
      // do something async.
      setTimeout(done,10);
    }
  };
};

var moduleB = function(sb){
  return {
    init: function(opt, done){
      console.log("starting module B");
      sb.sub.register("c", moduleC);
      sb.sub.start(done);
    },
    destroy: function(){
      console.log("stopping module B after C was stopped");
    }
  };
};

var moduleA = function(sb){
  return {
    init: function(){
      console.log("starting module A");
      sb.sub.register("b", moduleB);
      sb.sub.start();
    },
    destroy: function(){
      console.log("stopping module A after B was stopped");
  }};
};

(new sa.Core())
  .use(submodule, {inherit: true})
  .register("a", moduleA)
  .start()
  .stop();

/**
 * Here is an other example with usage of the i18n plugin
 */

var i18n  = require("../../dist/plugins/scaleApp.i18n");

var localization = {
  en : {
    saving : 'Saving...',
    searching : 'Searching...',
    searchfinished : 'Search finished'
  },
};

var childMod = function(sb){
  return {
    init: function(opt){
      var check = sb._("searching") === 'Searching...';
      console.log('CHILD: Calling sb._("searching") should return "Searching...":', check);
    }
  };
};

var parentMod = function(sb){
  return {
    init: function(){
      console.log("starting parent module with i18n plugin");
      var check = sb._("searching") === 'Searching...';
      console.log('PARENT: Calling sb._("searching") should return "Searching...":', check);
      sb.sub.register("child", childMod);
      sb.sub.start();
    }
  };
};

var core = new sa.Core();

core
  .use(i18n, { global: localization })
  .use(submodule, { inherit: true, useGlobalMediator: true })
  .register("parent", parentMod)
  .start()
  .stop();
