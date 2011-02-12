TestCase("scaleApp API tests", {
  
  setUp: function(){   
   
   this.validModule = function(){
      return {
	init: function(){},
	destroy: function(){}
      };
    };
  },
   
    
  "test the scaleApp namespace should exist": function(){    
    assertEquals( "object", typeof( scaleApp ) );    
  },

  "test register function should exist": function(){    
    assertEquals( "function", typeof( scaleApp.register ) );    
  },
  
  "test register function should return true, if module is valid": function(){    
    assertEquals( true, scaleApp.register( "myModule", this.validModule )  );    
  },
  
  "test register function should return false, if module creator is not a function": function(){    
    assertEquals( false, scaleApp.register( "myModule", { } )  );    
  },
  
  "test register function should return false, if module creator does not return an object": function(){    
    assertEquals( false, scaleApp.register( "myModule", function(){ return "I'm not an object" } )  );    
  },
  
  "test register function should return false, if created module object has not the functions init and destroy": function(){    
    assertEquals( false, scaleApp.register( "myModule", function(){ return {} } )  );    
  },
    
  "test start function should exist": function(){    
    assertEquals( "function", typeof( scaleApp.start ) );    
  },
  
  "test startSubModule function should exist": function(){    
    assertEquals( "function", typeof( scaleApp.startSubModule ) );    
  },
  
  "test stop function should exist": function(){    
    assertEquals( "function", typeof( scaleApp.stop ) );    
  },
  
  "test stopAll function should exist": function(){    
    assertEquals( "function", typeof( scaleApp.stopAll ) );    
  },
  
  "test publish function should exist": function(){    
    assertEquals( "function", typeof( scaleApp.publish ) );    
  },
  
  "test subscribe function should exist": function(){    
    assertEquals( "function", typeof( scaleApp.subscribe ) );    
  },
 
  
});