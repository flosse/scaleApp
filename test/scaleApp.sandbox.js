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

	"test that the sandbox.getModel function exists": function(){    
		assertEquals( "function", typeof( this.sb.getModel ) );    
	},

	"test that the sandbox.getView function exists": function(){    
		assertEquals( "function", typeof( this.sb.getView ) );    
	},

	"test that the sandbox.getController function exists": function(){    
		assertEquals( "function", typeof( this.sb.getController ) );    
	},

	"test that the sandbox.addModel function exists": function(){    
		assertEquals( "function", typeof( this.sb.addModel ) );    
	},

	"test that the sandbox.addController function exists": function(){    
		assertEquals( "function", typeof( this.sb.addController ) );    
	},

	"test that the sandbox.observable function exists": function(){    
		assertEquals( "function", typeof( this.sb.observable ) );    
	},

	"test that the sandbox.getTemplate function exists": function(){    
		assertEquals( "function", typeof( this.sb.getTemplate ) );    
	},

	"test that the sandbox.tmpl function exists": function(){    
		assertEquals( "function", typeof( this.sb.tmpl ) );    
	},

	"test that the sandbox.getContainer function exists": function(){    
		assertEquals( "function", typeof( this.sb.getContainer ) );    
	},

	"test that the sandbox logging functions exists": function(){    
		assertEquals( "function", typeof( this.sb.debug ) );    
		assertEquals( "function", typeof( this.sb.info ) );    
		assertEquals( "function", typeof( this.sb.warn ) );    
		assertEquals( "function", typeof( this.sb.error ) );    
		assertEquals( "function", typeof( this.sb.fatal ) );    
	},

	"test that the sandbox.mixin function exists": function(){    
		assertEquals( "function", typeof( this.sb.mixin ) );    
	},
	
	"test that the sandbox.count function exists": function(){    
		assertEquals( "function", typeof( this.sb.count ) );    
	},

	"test that the sandbox._ function exists": function(){    
		assertEquals( "function", typeof( this.sb._ ) );    
	},

	"test that the sandbox.getLanguage function exists": function(){    
		assertEquals( "function", typeof( this.sb.getLanguage ) );    
	},

	"test that the sandbox.count function exists": function(){    
		assertEquals( "function", typeof( this.sb.count ) );    
	},

	"test that the sandbox.hotkeys function exists": function(){    
		assertEquals( "function", typeof( this.sb.hotkeys ) );    
	},

});
