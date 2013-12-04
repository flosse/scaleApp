define(function(){

  // create the Log module
  return function(sandbox){

    // dom reference
    var container = null;

    //// boot your module
    var init = function(){

      // create a reference to the module's html element
      container = sandbox.getContainer();

      // creat log method
      var log = function(msg, channel){
        var li = document.createElement("li");
        li.innerText = li.textContent = channel.split('/')[1] + ': ' + msg;
        container.appendChild(li);
      };

      // listen to log events
      sandbox.on([
        "log/log",
        "log/debug",
        "log/info",
        "log/warn",
        "log/error"
      ],log);

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
    };

  };

});
