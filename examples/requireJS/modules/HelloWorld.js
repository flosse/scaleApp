define(function(){

  // create the HelloWorld module
  return function(sandbox){

    // dom reference
    var container = null;

    // boot your module
    var init = function(){

      // create a reference to the module's html element
      container = document.getElementById(sandbox.instanceId);

      // say hello
      container.innerText = container.textContent = "Hello World!";
    };

    // shutdown your module
    var destroy = function(){

      // clean your container
      container.innerText = container.textContent = '';
    };

    // return public module API
    return {
      init: init,
      destroy: destroy
    }
  };

});
