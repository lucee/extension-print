<cfscript>
	/**
	* Returns information about a printer
	* @functionname The name of the printer
	* @category print
	*/
	public struct function getPrinterInfo(required string printerName ){
		var printerLookup = new org.lucee.extension.print.javaxPrintServices();
		return printerLookup.info( arguments.printerName );
	}
</cfscript>
