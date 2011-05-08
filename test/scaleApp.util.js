TestCase("scaleApp.util tests", {
  
  setUp: function(){   
   
		this.object = { a: "one", b: "two", c: ["three"] };
  },
  
	// API namespace tests	
	"test that the scaleApp.util namespace exists": function(){    
		assertEquals( "object", typeof( scaleApp.util ) );    
	},

	"test that the scaleApp.util.mixin function exists": function(){    
		assertEquals( "function", typeof( scaleApp.util.mixin ) );    
	},

	"test that the scaleApp.util.countObjectKeys function exists": function(){    
		assertEquals( "function", typeof( scaleApp.util.countObjectKeys ) );    
	},

	// countObjectKey tests
	"test that the countObjectKeys function counts correctly": function(){    
		assertEquals( 3, scaleApp.util.countObjectKeys( this.object ) );    
	},

	"test that the countObjectKeys also counts arrays": function(){    
		assertEquals( 2, scaleApp.util.countObjectKeys( ["a","b"] ) );    
	},

	"test that the countObjectKeys function returns zero on wrong argument": function(){    
		assertEquals( 0, scaleApp.util.countObjectKeys( "aString" ) );    
	},

	// mixin tests

	"test that mixin extends an object with an other one": function(){    
	
		 var receivingObject = { a: "original", d: 55 };
		 var expected = { a: "original", b: "two", c: ["three"], d: 55 };
		 var givingObject = { a: "one", b: "two", c: ["three"] }; // copy of this.object

		 scaleApp.util.mixin( receivingObject, givingObject );

		 assertEquals( expected, receivingObject );    
		 assertEquals( this.object, givingObject );    
	 },

	"test that mixin extends an class with an object": function(){    
	
		var receivingClass = function(){};
		receivingClass.prototype = { a: "original", d: 55 };
		var expected = { a: "original", b: "two", c: ["three"], d: 55 };
		
		var givingObject = { a: "one", b: "two", c: ["three"] }; // copy of this.object

		 scaleApp.util.mixin( receivingClass, givingObject );

		 assertEquals( expected, receivingClass.prototype );    
		 assertEquals( this.object, givingObject );    
	 },

	"test that mixin extends an object with a class": function(){    
		
		var receivingObject = { a: "original", d: 55 };
		var expected = { a: "original", b: "two", c: ["three"], d: 55 };

		var givingClass = function(){};
		givingClass.prototype = { a: "one", b: "two", c: ["three"] }; // copy of this.object

		scaleApp.util.mixin( receivingObject, givingClass );

		assertEquals( expected, receivingObject );    
		assertEquals( this.object, givingClass.prototype );    
	},

	"test that mixin extends a class with an other one": function(){    
		
		var receivingClass = function(){};
		receivingClass.prototype = { a: "original", d: 55 };
		var expected = { a: "original", b: "two", c: ["three"], d: 55 };

		var givingClass = function(){};
		givingClass.prototype = { a: "one", b: "two", c: ["three"] }; // copy of this.object

		scaleApp.util.mixin( receivingClass, givingClass );

		assertEquals( expected, receivingClass.prototype );    
		assertEquals( this.object, givingClass.prototype );    
	},
});
