(function(sa){

  // initialize the application
  var init = function(){

    // creata new Core instance
    var core = new sa.Core();

    // create the helloWorld module
    var HelloModule = function(sandbox){

      // dom reference
      var container = null;

      // boot your module
      var init = function(){

        // create a reference to the module's html element
        container = document.getElementById(sandbox.instanceId);

        // say hello
        container.innerText = "Hello World!";
      };

      // shutdown your module
      var destroy = function(){

        // clean your container
        container.innerText = '';
      };

      // return public module API
      return {
        init: init,
        destroy: destroy
      }
    };

    // register the module
    core.register("helloWorld", HelloModule);

    // create element references
    var startButton = document.getElementById("start");
    var stopButton  = document.getElementById("stop");
    var logElement  = document.getElementById("log");

    // creat log method
    var log = function(msg){
      var li = document.createElement("li");
      li.innerText = msg;
      logElement.appendChild(li);
    };

    // bind start button
    startButton.onclick = function(){
      core.start("helloWorld", function(err){
        if(err) return log(err.message);
        log("started 'helloWorld' module");
      });
    };

    // bind stop button
    stopButton.onclick  = function(){
      core.stop("helloWorld", function(err){
        if(err) return log(err.message);
        log("stopped 'helloWorld' module");
      });
    };
  };

  // return public API
  window.app = {
    init: init
  };

})(window.scaleApp);
