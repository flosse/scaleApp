TestCase("scaleApp.template tests", {

  setUp: function(){ },

	// API
	"test that scaleApp.template namespace is an object": function(){
		assertEquals( "object", typeof( scaleApp.template ) );
	},

	"test that scaleApp.template.load is an function": function(){
		assertEquals( "function", typeof( scaleApp.template.load ) );
	},

	"test that scaleApp.template.loadMultiple is an function": function(){
		assertEquals( "function", typeof( scaleApp.template.loadMultiple ) );
	},

	"test that scaleApp.template.get is an function": function(){
		assertEquals( "function", typeof( scaleApp.template.get ) );
	},

	"test that scaleApp.template.add is an function": function(){
		assertEquals( "function", typeof( scaleApp.template.add ) );
	},

	"test that scaleApp.template.set is an function": function(){
		assertEquals( "function", typeof( scaleApp.template.set ) );
	},

});
