TestCase("scaleApp API tests", {
  
  setUp: function(){   
   
   this.validModule = function(){
      return {
	init: function(){},
	destroy: function(){}
      };
    };
  },
   
  "test scaleApp namespace should exist": function(){    
    assertEquals( "object", typeof( scaleApp ) );    
  },

  "test register function should exist": function(){    
    assertEquals( "function", typeof( scaleApp.register ) );    
  },
  
  "test register function should return true, if module is valid": function(){    
    assertTrue( scaleApp.register( "myModule", this.validModule )  );    
  },
  
  "test register function should return false, if module creator is not a function": function(){    
    assertFalse( scaleApp.register( "myModule", { } )  );    
  },
  
  "test register function should return false, if module creator does not return an object": function(){    
    assertFalse( scaleApp.register( "myModule", function(){ return "I'm not an object" } )  );    
  },
  
  "test register function should return false, if created module object has not the functions init and destroy": function(){    
    assertFalse( scaleApp.register( "myModule", function(){ return {} } )  );    
  },
  
  "test register function should return true, if option is an object": function(){    
    assertTrue( scaleApp.register( "myModule", this.validModule, { } )  );    
  },
   
  "test register function should return false, if option is not an object": function(){    
    assertFalse( scaleApp.register( "myModule", this.validModule , "I'm not an object" )  );    
  },
  
  "test register function should return false, if property views of option object is not an object": function(){    
    assertFalse( scaleApp.register( "myModule", this.validModule , { views: " " } ) );    
  },
  
  "test register function should return false, if views are no functions": function(){    
    assertFalse( scaleApp.register( "myModule", this.validModule , { views: { "myView": "I'm not a function" } } ) );    
  },
  
  "test register function should return false, if view creators don't return objects": function(){    
    assertFalse( scaleApp.register( "myModule", this.validModule , { views: { "myView": function(){ return "I'm not an object"; } } } ) );    
  },
  
  "test register function should return false, if property models of option object is not an object": function(){    
    assertFalse( scaleApp.register( "myModule", this.validModule , { models: " " } ) );    
  },
  
  "test register function should return false, if models are no functions": function(){    
    assertFalse( scaleApp.register( "myModule", this.validModule , { models: { "myModel": "I'm not a function" } } ) );    
  },
  
  "test register function should return false, if model creators don't return objects": function(){    
    assertFalse( scaleApp.register( "myModule", this.validModule , { models: { "myModel": function(){ return "I'm not an object"; } } } ) );    
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