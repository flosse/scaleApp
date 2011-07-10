TestCase("scaleApp.log tests", {
  
  setUp: function(){   
   
  },

	"test that scaleApp.log.debug is a function": function(){    
		assertEquals( "function", typeof( scaleApp.debug ) );    
  },

	"test that scaleApp.log.info is a function": function(){    
		assertEquals( "function", typeof( scaleApp.info ) );    
  },

	"test that scaleApp.log.warn is a function": function(){    
		assertEquals( "function", typeof( scaleApp.warn ) );    
  },

	"test that scaleApp.log.error is a function": function(){    
		assertEquals( "function", typeof( scaleApp.error ) );    
  },

	"test that scaleApp.log.fatal is a function": function(){    
		assertEquals( "function", typeof( scaleApp.fatal ) );    
  },

	"test that scaleApp.log.setLogLevel is a function": function(){    
		assertEquals( "function", typeof( scaleApp.setLogLevel ) );    
  },

	"test that scaleApp.log.getLogLevel is a function": function(){    
		assertEquals( "function", typeof( scaleApp.getLogLevel ) );    
  },

});
