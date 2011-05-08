TestCase("scaleApp.log tests", {
  
  setUp: function(){   
   
  },

	// API	
	"test that the scaleApp.log namespace exists": function(){    
		assertEquals( "object", typeof( scaleApp.log ) );    
  },

	"test that scaleApp.log.debug is a function": function(){    
		assertEquals( "function", typeof( scaleApp.log.debug ) );    
  },

	"test that scaleApp.log.info is a function": function(){    
		assertEquals( "function", typeof( scaleApp.log.info ) );    
  },

	"test that scaleApp.log.warn is a function": function(){    
		assertEquals( "function", typeof( scaleApp.log.warn ) );    
  },

	"test that scaleApp.log.error is a function": function(){    
		assertEquals( "function", typeof( scaleApp.log.error ) );    
  },

	"test that scaleApp.log.fatal is a function": function(){    
		assertEquals( "function", typeof( scaleApp.log.fatal ) );    
  },

	"test that scaleApp.log.setLogLevel is a function": function(){    
		assertEquals( "function", typeof( scaleApp.log.setLogLevel ) );    
  },

	"test that scaleApp.log.getLogLevel is a function": function(){    
		assertEquals( "function", typeof( scaleApp.log.getLogLevel ) );    
  },

});
