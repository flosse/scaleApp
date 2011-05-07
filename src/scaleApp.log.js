/**
 * Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)
 */

/**
 * File: scaleApp.log.js
 * scaleApp.log.js is a logging extension for scaleApp.
 *
 * It is licensed under the MIT licence.
 */

/**
 * Class: scaleApp.log
 */
scaleApp.log = (function( window, undefined ){

	/**
	* PrivateClass: console
	* Some browsers don't support logging via the console object.
	* If the console object is not defined, just create a dummy.
	*/
	if( !console ){

		console = {};
		console.log		= function( msg ) { return; };
		console.debug	= function( msg ) { return; };
		console.info	= function( msg ) { return; };
		console.warn	= function( msg ) { return; };
		console.error	= function( msg ) { return; };
		console.fatal	= function( msg ) { return; };
	}

	/**
	* PrivateVariable: currentLogLevel
	* Holds the current LogLevel
	*/
	var currentLogLevel = 0;

	/**
	* Constants: logLevel
	* logging level indicators
	*
	* logLevel.DEBUG - Debug output
	* logLevel.INFO - Informational output
	* logLevel.WARN - Warnings
	* logLevel.ERROR - Errors
	* logLevel.FATAL - Fatal error
	*/
	var logLevel = {

		DEBUG:	0,
		INFO:		1,
		WARN:		2,
		ERROR:	3,
		FATAL:	4

	};

	/**
	* PrivateFunction: log
	*
	* Parameters:
	* (String) level
	* (String) msg
	* (String) module
	*/
	var log = function( level, msg, module ){

		if( module ){
			if( typeof msg === "object" ){
				// split into two logs
				log( level, module + ":");
				log( level, msg );
				return;
			}
			else {
				msg = module + ": " + msg;
			}
		}

		switch( level ){

			case logLevel.DEBUG:
				if( currentLogLevel <= logLevel.DEBUG ){  console.debug( msg ); }
				break;

			case logLevel.INFO:
				if( currentLogLevel <= logLevel.INFO ){  console.info( msg ); }
				break;

			case logLevel.WARN:
				if( currentLogLevel <= logLevel.WARN ) {  console.warn( msg ); }
				break;

			case logLevel.ERROR:
				if( currentLogLevel <= logLevel.ERROR ) {  console.error( msg ); }
				break;

			case logLevel.FATAL:
				if( currentLogLevel <= logLevel.FATAL ) {  console.error( msg ); }
				break;

			default:
				console.log( msg );
				break;
		}
	};

	// logging functions, each for a different level
	var debug =	function( msg, module ){ log( logLevel.DEBUG, msg, module ); };
	var info  =	function( msg, module ){ log( logLevel.INFO,  msg, module ); };
	var warn  =	function( msg, module ){ log( logLevel.WARN,  msg, module ); };
	var error =	function( msg, module ){ log( logLevel.ERROR, msg, module ); };
	var fatal =	function( msg, module ){ log( logLevel.FATAL, msg, module ); };

	// public API
	return ({

		debug: debug,
		info: info,
		warn: warn,
		error: error,
		fatal: fatal

	});

})( window );
