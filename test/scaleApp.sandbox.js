TestCase("scaleApp.sandbox tests", {
  
  setUp: function(){ 

		this.sb = new scaleApp.sandbox( "exampleInstance", { } );
	},
  
	// API namespace tests	
	"test that the scaleApp.sandbox namespace is an function": function(){    
		assertEquals( "function", typeof( scaleApp.sandbox ) );    
	},

	"test that the sandbox.subscribe function exists": function(){    
		assertEquals( "function", typeof( this.sb.subscribe ) );    
	},

	"test that the sandbox.unsubscribe function exists": function(){    
		assertEquals( "function", typeof( this.sb.unsubscribe ) );    
	},

	"test that the sandbox.publish function exists": function(){    
		assertEquals( "function", typeof( this.sb.publish ) );    
	},
	
	"test that the sandbox.startSubModule function exists": function(){    
		assertEquals( "function", typeof( this.sb.startSubModule ) );    
	},

	"test that the sandbox.stopSubModule function exists": function(){    
		assertEquals( "function", typeof( this.sb.stopSubModule ) );    
	},

	"test that the sandbox.getContainer function exists": function(){    
		assertEquals( "function", typeof( this.sb.getContainer ) );    
	},

	"test that the sandbox.mixin function exists": function(){    
		assertEquals( "function", typeof( this.sb.mixin ) );    
	},
	
	"test that the sandbox.count function exists": function(){    
		assertEquals( "function", typeof( this.sb.count ) );    
	},

});
