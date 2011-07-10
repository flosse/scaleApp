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
        return {
          init: function(){

          },
          sb: sb,
          destroy: function(){}
        };
      };

      scaleApp.register("module", this.myModule, { i18n: this.myLangObj });
      scaleApp.start( "module");

      this.instance = scaleApp.getInstance("module");
  },

  // API

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
    assertEquals( "function", typeof( this.instance.sb._ ) );
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
    assertEquals( this.myLangObj.en.helloWorld, this.instance.sb._("helloWorld") );
  },

  "test that _ returns base language string if current language is not supported": function(){
    var lang = "de-CH";
    scaleApp.i18n.setLanguage( lang );
    assertEquals( this.myLangObj.de.helloWorld, this.instance.sb._("helloWorld") );
  },

  "test that subscription to changes works": function(){
    var fn = function( code ){
      assertEquals( lang , code );
    };
    var lang = "de-CH";
    scaleApp.i18n.subscribe( fn );
    scaleApp.i18n.setLanguage( lang );
  },
});
