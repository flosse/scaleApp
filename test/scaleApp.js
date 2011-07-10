TestCase("scaleApp.js tests", {

  setUp: function(){

		this.i18n = { en: { "hello": "Hello" }, de:{ "hello": "Hallo" } };
		this.view = function(){
			return {
				init:	function(){
		 		}
			}
		};
		this.template = "tmpl"
		this.model = { text: "dummy text" };

		this.validModule = function( sb ){

			var m;
			var v;

			return {
				init: function(){
				  sb.subscribe("bla");
					sb.publish("blub", 55 );
				},
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

  "test to register a module with options and start it": function(){

		var aModule = function( sb ){

			var m;
			var v;

			return {
				init: function(){
					
				  sb.subscribe("bla");
					sb.publish("blub", 55 );
				},
				destroy: function(){}
			};
		};
		scaleApp.register("myId", aModule, {
			views: { "view": this.view },
			templates: { "template": this.template },
	 		models: { "model":this.model },
			i18n: this.i18n
		});
		scaleApp.startAll();
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
