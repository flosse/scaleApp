/**
 * Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)
 */

/**
 * File: scaleApp.js
 * scaleApp is a tiny framework for One-Page-Applications.
 * It is licensed under the MIT licence.
 */

/**
 * Class: core
 * The core holds and manages all data that is used globally.
 */
window[ 'scaleApp' ] = (function( window, undefined ){

	// reference to the core object itself
	var that = this;

	// container for all registered modules
	var modules = { };

	// container for all module instances
	var instances = { };

	// container for lists of submodules
	var subInstances = { };

	// container for all templates
	var templates = { };

	// container for all functions that gets called when an instance gets created
	var onInstantiateFunctions = [];

	// as long the log object is not overridden do nothing
	var log = {
		'debug': function(){ return; },
		'info':  function(){ return; },
		'warn':  function(){ return; },
		'error': function(){ return; },
		'fatal': function(){ return; }
	};

	/**
	 * Function: onInstantiate
	 *
	 * Parameters:
	 * (Function) fn
	 */
	var onInstantiate = function( fn ){
		if( typeof fn === "function" ){
			onInstantiateFunctions.push( fn );
		}else{
			that["log"]["error"]( "onInstantiate expect a function as parameter", "core" );
		}
	};

	/**
	 * PrivateFunction: createInstance
	 * Creates a new instance of a module.
	 *
	 * Parameters:
	 * (String) moduleId	  - The ID of a registered module.
	 * (String) instanceId	- The ID of the instance that will be created.
	 * (Object) opt				  - An object that holds specific options for the module.
	 * (Function) opt			  - Callback function.
	 */
	var createInstance = function( moduleId, instanceId, opt, success, error ){

		var mod = modules[ moduleId ];

		var instance;

		var callSuccess = function(){
			if( typeof success === "function" ){ success( instance ); }
		};

		var callError = function(){
			if( typeof error === "function" ){ error( instance ); }
		};

		if( mod ){

			// Merge default options and instance options,
			// without modifying the defaults.
			var instanceOpts = { };
			$.extend( true, instanceOpts, mod['opt'], opt );

			var sb = new that['sandbox']( instanceId, instanceOpts );

			instance = mod['creator']( sb );

			// store opt
			instance['opt'] = instanceOpts;

			$.each( onInstantiateFunctions, function( i, fn ){
				fn( instanceId, instanceOpts, sb );
			});

			if( instanceOpts['templates'] && that['template'] ){

				that['template']['loadMultiple']( instanceOpts['templates'] )
					.done( function( res ){
							that['template']['set']( instanceId, res );
							callSuccess(); })
					.fail( function( err ){ callError( err ); })
					.then( function(){ delete instanceOpts['templates']; });

			} else { callSuccess(); }
		} else {
			 that["log"]["error"]( "could not start module '" + moduleId + "' - module does not exist.", "core" );
		}
	};

	/**
	 * PrivateFunction: checkOptionObject
	 * Checks whether the passed option object is valid or not.
	 *
	 * Parameters:
	 * (Object) opt
	 *
	 * Returns:
	 * False if it is not valid, true if everything is ok.
	 */
	var checkOptionObject = function( opt ){

		if( typeof opt !== "object" ){
			that["log"]["error"]( "could not register module - option has to be an object", "core" );
			return false;
		}
		if( opt['views'] ){
		 if( typeof opt['views'] !== "object" ){ return false }
	  }
			
		if( opt['models'] ){
		 if( typeof opt['models'] !== "object" ){ return false }
	  }

		if( opt['templates'] ){
		 if( typeof opt['templates'] !== "object" ){ return false }
	  }

		return true;
	};

	/**
	 * PrivateFunction: checkRegisterParameters
	 *
	 * Parameters:
	 * (String) moduleId
	 * (Function) creator
	 * (Object) opt
	 *
	 * Returns:
	 * True if everything is ok.
	 */
	var checkRegisterParameters = function( moduleId, creator, opt  ){

		var errString = "could not register module";

		if( typeof moduleId !== "string" ){
			that["log"]["error"]( errString + "- mouduleId has to be a string", "core" );
			return false;
		}
		if( typeof creator !== "function" ){
			that["log"]["error"]( errString + " - creator has to be a constructor function", "core" );
			return false;
		}

		var modObj = creator();

		if( typeof modObj							!== "object"   ||
				typeof modObj['init']			!== "function" ||
				typeof modObj['destroy']	!== "function" ){
			that["log"]["error"]( errString + " - creator has to return an object with the functions 'init' and 'destroy'", "core" );
			return false;
		}

		if( opt ){
			if( !checkOptionObject( opt ) ){ return false; }
		}

		return true;

	};

	/**
	 * Function: register
	 *
	 * Parameters:
	 * (String) moduleId	- The module id
	 * (Function) creator	- The module creator function
	 * (Object) ops				- The default options for this module
	 *
	 * Returns:
	 * True if registration was successfull.
	 */
	var register = function( moduleId, creator, opt ){

		if( !checkRegisterParameters( moduleId, creator, opt  ) ){ return false; }

		if( !opt ){ opt = {}; }

		modules[ moduleId ] = {
			'creator': creator,
			'opt': opt
		};

		return true;
	};

	/**
	 * PrivateFunction: hasValidStartParameter
	 *
	 * Parameters:
	 * (String) moduleId
	 * (String) instanceId
	 * (Object) opt
	 *
	 * Returns:
	 * True, if parameters are valid.
	 */
	var hasValidStartParameter = function( moduleId, instanceId, opt ){

		return	( typeof moduleId === "string" ) &&
			(
				( typeof instanceId === "string" && !opt )			||
				( typeof instanceId === "object" && !opt )			||
				( typeof instanceId === "string" && typeof opt === "object" )	||
				( !instanceId  &&  !opt )
			);
	};

	/**
	 * PrivateFunction: getSuitedParamaters
	 *
	 * Parameters:
	 * (String) moduleId
	 * (String) instanceId
	 * (Object) opt
	 *
	 * Returns:
	 * Object with parameters
	 */
	var getSuitedParamaters = function( moduleId, instanceId, opt ){

		if( hasValidStartParameter( moduleId, instanceId, opt ) ){
			if( typeof instanceId === "object" && !opt ){
				// no instance id was specified, so use module id instead
				opt = instanceId;
				instanceId = moduleId;
			}
			if( !instanceId && !opt ){
				instanceId = moduleId;
				opt = {};
			}
			return { 'moduleId': moduleId, 'instanceId': instanceId, 'opt': opt };
		}
		that["log"]["error"]( "could not start module '"+ moduleId +"' - illegal arguments.", "core" );
		return;
	};


	/**
	 * Function: start
	 *
	 * Parameters:
	 * (String) moduleId
	 * (String) instanceId
	 * (Object) opt
	 */
	var start = function( moduleId, instanceId, opt, callback ){

		var p = getSuitedParamaters( moduleId, instanceId, opt );
		if( p ){

			that["log"]["debug"]( "start '" + p['moduleId'] + "'", "core" );

			var onSuccess = function( instance ){
				instances[ p['instanceId'] ] = instance;
				instance['init']();
				if( typeof callback === "function" ){
					callback();
				}
			};
			createInstance( p['moduleId'], p['instanceId'], p['opt'], onSuccess );
			return true;
		}
		return false;
	};

	/**
	 * Function: startSubModule
	 *
	 * Parameters:
	 * (String) moduleId
	 * (String) parentInstanceId
	 * (String) instanceId
	 * (Object) opt
	 */
	var startSubModule = function( moduleId, instanceId, opt, parentInstanceId ){

		var p = getSuitedParamaters( moduleId, instanceId, opt );
		if( start( p['moduleId'], p['instanceId'], p['opt'] ) && typeof parentInstanceId === "string" ){

			var sub = subInstances[ parentInstanceId ];
			if( !sub ){
				sub = [ ];
			}
			sub.push( p['instanceId'] );
		}
	};

	/**
	 * Function: stop
	 *
	 * Parameters:
	 * (String) instanceId
	 */
	var stop = function( instanceId ){

		var instance = instances[ instanceId ];

		if( instance ){
			instance['destroy']();
			delete instances[ instanceId ];

			$.each( subInstances[ instanceId ], function( i, instance ){
				if( instance){ stop( instance ); }
			});
		}else{
			that['log']['error']( "could not stop instance '" + instanceId + "' - instance does not exist.", "core" );
			return false;
		}
	};


	/**
	 * Function: startAll
	 * Starts all available modules.
	 */
	var startAll = function( fn ){

		var callback = function(){};

		if( typeof fn === "function" ){
			var count = that['util']['countObjectKeys']( modules );
			callback = function(){
				count --;
				if( count === 0 ){
					fn();
				}
			};
		}
		$.each( modules, function( id, module ){
			if( module ){ start( id, id, module['opt'], callback ); }
		});
	};


	/**
	 * Function: stopAll
	 * Stops all available instances.
	 */
	var stopAll = function(){ $.each( instances, function( id, inst ){ stop( id ); }); };

	/**
	 * PrivateFunction: publish
	 *
	 * Parameters:
	 * (String) topic
	 * (Object) data
	 */
	var publish = function( topic, data ){

		$.each( instances, function( i, instance ){

			if( instance['subscriptions'] ){

				var handlers = instance['subscriptions'][ topic ];

				if( handlers ){
					$.each( handlers, function( i, h ){
						if( typeof h === "function" ){ h( data, topic ); }
					});
				}
			}
		});
	};

	/**
	 * PrivateFunction: subscribe
	 *
	 * Parameters:
	 * (String) topic
	 * (Function) handler
	 */
	var subscribe = function( instanceId, topic, handler ){

		that["log"]["debug"]( "subscribe to '" + topic + "'", instanceId );

		var instance = instances[ instanceId ];

		if( !instance['subscriptions'] ){
			instance['subscriptions'] = { };
		}
		var subs = instance['subscriptions'];

		if( !subs[ topic ] ){
			subs[ topic ] = [];
		}
		subs[ topic ].push( handler );
	};

	/**
	 * PrivateFunction: unsubscribe
	 *
	 * Parameters:
	 * (String) instanceId
	 * (String) topic
	 */
	var unsubscribe = function( instanceId, topic ){

		var subs = instances[ instanceId ]['subscriptions'];
		if( subs ){
			if( subs[ topic ] ){
				delete subs[ topic ];
			}
		}
	};

	/**
	 * Function: getInstances
	 *
	 * Parameters:
	 * (String) id
	 *
	 * Returns:
	 * Instance
	 */
	var getInstance = function( id ){
		return instances[ id ];
	};

	/**
	 * Function: getContainer
	 */
	var getContainer = function( instanceId ){

		var o = instances[ instanceId ]['opt'];

		if( o ){
			if( typeof o['container'] === "string" ){
				return $( "#" + o['container'] );
			}
		}
		return $( "#" + instanceId );
	};

	// public core API
	that = ({

		'register': register,
		'onInstantiate':onInstantiate,

		'start': start,
		'startSubModule': startSubModule,
		'stop': stop,
		'startAll': startAll,
		'stopAll': stopAll,

		'publish': publish,
		'subscribe': subscribe,

		'getContainer': getContainer,

		'getInstance': getInstance,

		'log': log

	});

	return that;

})( window );
