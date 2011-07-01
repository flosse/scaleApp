TestCase("scaleApp.i18n tests", {

  setUp: function(){

		this.myLangObj = {

				en: {
					helloWorld: "Hello world"
				},
				de: {
					helloWorld: "Hallo Welt"
				},
				es: {
					something: "??"
				}

			};

			this.myModule = function( sb ){
				return { init: function(){}, destroy: function(){} };
			};

			scaleApp.register("module", this.myModule, { i18n: this.myLangObj });

			scaleApp.start( "module");
	},

	// API
	"test that scaleApp.i18n namespace is an object": function(){
		assertEquals( "object", typeof( scaleApp.i18n ) );
	},

	"test that getLanguage is a function": function(){
		assertEquals( "function", typeof( scaleApp.i18n.getLanguage ) );
	},

	"test that setLanguage is a function": function(){
		assertEquals( "function", typeof( scaleApp.i18n.setLanguage ) );
	},

	"test that getBrowserLanguage is a function": function(){
		assertEquals( "function", typeof( scaleApp.i18n.getBrowserLanguage ) );
	},

	"test that _ is a function": function(){
		assertEquals( "function", typeof( scaleApp.i18n._ ) );
	},

	// setting and getting languages

	"test that setting a language code works": function(){
		var lang = "en-US";
		scaleApp.i18n.setLanguage( lang );
		assertEquals( lang, scaleApp.i18n.getLanguage() );
	},

	"test that _ returns english string if current language is not supported": function(){
		var lang = "es";
		scaleApp.i18n.setLanguage( lang );
    assertEquals( this.myLangObj.en.helloWorld, scaleApp.i18n._("module", "helloWorld") );
	},

	"test that _ returns base language string if current language is not supported": function(){
		var lang = "de-CH";
		scaleApp.i18n.setLanguage( lang );
    assertEquals( this.myLangObj.de.helloWorld, scaleApp.i18n._("module", "helloWorld") );
	},
});
