TestCase("scaleApp.mvc tests", {

  setUp: function(){ },

	// API
	"test that scaleApp.mvc namespace is an object": function(){
		assertEquals( "object", typeof( scaleApp.mvc ) );
	},

	"test that scaleApp.mvc.addModel is an function": function(){
		assertEquals( "function", typeof( scaleApp.mvc.addModel ) );
	},

	"test that scaleApp.mvc.addView is an function": function(){
		assertEquals( "function", typeof( scaleApp.mvc.addView ) );
	},

	"test that scaleApp.mvc.addController is an function": function(){
		assertEquals( "function", typeof( scaleApp.mvc.addController ) );
	},

	"test that scaleApp.mvc.getModel is an function": function(){
		assertEquals( "function", typeof( scaleApp.mvc.getModel ) );
	},

	"test that scaleApp.mvc.getView is an function": function(){
		assertEquals( "function", typeof( scaleApp.mvc.getView ) );
	},

	"test that scaleApp.mvc.getController is an function": function(){
		assertEquals( "function", typeof( scaleApp.mvc.getController ) );
	},

	"test that scaleApp.mvc.observable is an function": function(){
		assertEquals( "function", typeof( scaleApp.mvc.observable ) );
	},

});
