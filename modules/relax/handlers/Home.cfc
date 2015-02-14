/**
********************************************************************************
Copyright 2005-2007 by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
* Main Handler
*/
component extends="BaseHandler"{

	// DI
	property name="relaxerService" 	inject="Relaxer@relax";

	/**
	* Home
	*/
	function index( event, rc, prc ){
		// Get the loaded API for the user
		prc.dsl				= DSLService.getLoadedAPI();
		prc.loadedAPIName 	= DSLService.getLoadedAPIName();
		prc.loadedAPIs		= DSLService.listAPIs();
		// JS/CSS Append
		prc.jsAppendList  	= "shCore,brushes/shBrushColdFusion,brushes/shBrushJScript,brushes/shBrushXml";
		prc.cssAppendList 	= "shCore,shThemeDefault";
		// Exit Handlers
		prc.xehResourceDoc  	= "relax/Home/resourceDoc";
		prc.xehResourceDocEvent = "relax:Home.resourceDoc";
		prc.xehLoadAPI			= "relax/Home/loadAPI";
		prc.xehExportHTML 		= "relax/Export/html";
		prc.xehExportPDF 		= "relax/Export/pdf";
		prc.xehExportwiki 		= "relax/Export/mediawiki";
		prc.xehExportTrac 		= "relax/Export/trac";
		prc.xehExportAPI		= "relax/Export/api";
		prc.xehImportAPI		= "relax/Import/api";

		// Expanded div for resource holders
		prc.expandedResourceDivs = false;

		// set view
		event.setView( "home/index" );
	}

	/**
	* Home
	*/
	function relax( event, rc, prc ){
	
		event.renderData( data=renderView( view="home/relax", module="relax" ) );
	}

	/**
	* Load a selected API
	*/
	function loadAPI( event, rc, prc ){
		event.paramValue( "apiName", "" );
		// load the api if it has length else ignored.
		if( len( rc.apiName ) ){
			DSLService.loadAPI( rc.apiName );
			flash.put( "notice", "API: #rc.apiName# loaded!" );
		}
		setNextEvent( prc.xehHome );
	}

	/**
	* The DSL Documentation
	*/
	function dslDocs( event, rc, prc ){
		prc.docs = getModel( "DSLDoc@relax" ).generate();
		event.setView( view="home/DSLDocs" );
	}

	/**
	* Home
	*/
	function relaxer( event, rc, prc ){
		// some defaults
		event.paramValue( "httpResource", "" );
		event.paramValue( "httpFormat", "" );
		event.paramValue( "httpMethod", "GET" );
		event.paramValue( "headerNames", "" );
		event.paramValue( "headerValues", "" );
		event.paramValue( "parameterNames", "" );
		event.paramValue( "parameterValues", "" );
		event.paramValue( "sendRequest", false );
		event.paramValue( "username", "" );
		event.paramValue( "password", "" );
		event.paramValue( "httpProxy", "" );
		event.paramValue( "httpProxyPort", "" );
		event.paramValue( "entryTier", "production" );

		// DSL Settings
		prc.dsl				= DSLService.getLoadedAPI();
		prc.loadedAPIName 	= DSLService.getLoadedAPIName();

		// custom css/js
		prc.jsAppendList  = "jquery.scrollTo-min,shCore,brushes/shBrushJScript,brushes/shBrushColdFusion,brushes/shBrushXml";
		prc.cssAppendList = "shCore,shThemeDefault";

		// exit handlers
		prc.xehPurgeHistory 	= "relax/Home.purgeHistory";
		prc.xehResourceDoc  	= "relax/Home.resourceDoc";
		prc.xehLoadAPI		= "relax/Home.loadAPI";

		// send request
		if( rc.sendRequest ){
			try{
				prc.results = relaxerService.send(argumentCollection=rc);
			} catch( Any e ){
				log.error("Error sending relaxed request! #e.message# #e.detail# #e.stackTrace#", e);
				flash.put( "notice", "Error sending relaxed request! #e.message# #e.detail# #e.tagContext.toString()#" );
			}
		}

		// Get request history
		rc.requestHistory = relaxerService.getHistory();

		// display relaxer
		event.setView("home/relaxer");
	}

	/**
	* Home
	*/
	function clearUserData( event, rc, prc ){
		DSLService.clearUserData();
		setNextEVent(rc.xehHome);
	}

	/**
	* Export Resource Doc
	*/
	function resourceDoc( event, rc, prc, resourceID, expandedDiv ){
		// DSL Settings
		prc.dsl				= DSLService.getLoadedAPI();
		prc.loadedAPIName 	= DSLService.getLoadedAPIName();
		// exit handlers
		prc.xehResourceDoc  	= "relax/Home.resourceDoc";
		// expanded divs
		prc.expandedResourceDivs = true;

		// custom css/js
		prc.jsAppendList  = "shCore,brushes/shBrushJScript,brushes/shBrushColdFusion,brushes/shBrushXml";
		prc.cssAppendList = "shCore,shThemeDefault";

		// select layout
		event.paramValue( "print", "html" );

		// selected ID for resource display
		for(var x=1; x lte arrayLen( prc.dsl.resources ); x++ ){
			if( prc.dsl.resources[ x ].resourceID eq rc.resourceID ){
				prc.thisResource = prc.dsl.resources[x];
				break;
			}
		}

		// set view for Rendering
		if( event.isAjax() ){
			event.renderData( data=renderView( view="home/docs/resourceDoc", module="relax" ) );
		} else {
			event.setView( view="home/docs/resourceDoc", layout="#rc.print#" );
		}
	}

	/**
	* Home
	*/
	function purgeHistory( event, rc, prc ){
		var results = {
			error = false,
			messages = "History cleaned!"
		};
		try{
			relaxerService.clearHistory();
		}
		catch(Any e){
			results.error = true;
			results.messages = "error clearing history: #e.detail# #e.message#";
			if( log.canError() ){
				log.error("Error clearing history: #e.message# #e.detail#",e);
			}
		}
		event.renderData(type="jsont",data=results);
	}

	

	/**
	* Home
	*/
	function dslDocsCodex( event, rc, prc ){
		event.renderData(data=getModel("DSLDoc@relax").generateCodex(),type="text");
	}

}