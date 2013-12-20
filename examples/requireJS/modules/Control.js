define(['text!modules/ControlModuleTemplate.html'],function(template){

  return function(sandbox){

    var container, startButton, stopButton, mods;

    // boot your module
    var init = function(opts, done){

      // create references
      container = sandbox.getContainer();
      container.innerHTML = template;
      startButton = container.getElementsByClassName("start")[0];
      stopButton  = container.getElementsByClassName("stop")[0];
      selection   = container.getElementsByTagName("select")[0];

      // load info about available modules
      require(["text!modules.json"], function(modules){

        // parse modules.json
        try{
          mods = JSON.parse(modules);
        }catch(e){
          return done(e);
        }

        // create otptions
        for(m in mods){
          var o = document.createElement("option");
          var l = mods[m].label;
          o.innerText   = l;
          o.textContent = l;
          o.setAttribute('value', mods[m].name);
          selection.appendChild(o);
        }

        // bind start button
        startButton.onclick = function(){
          sandbox.emit("start", selection.value);
        };

        // bind stop button
        stopButton.onclick  = function(){
          sandbox.emit("stop", selection.value);
        };

        done();

      });
    };

    // shutdown your module
    var destroy = function(){
      // clean your container
      container.innerHTML = '';
    };

    // return public module API
    return {
      init: init,
      destroy: destroy
    };

  };
});
