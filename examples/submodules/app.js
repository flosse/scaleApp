var sa = require("../../dist/scaleApp");
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
