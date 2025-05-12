<cfscript>
	/**
	* Returns a list of local printers
	*/
	public array function getPrinterList(){
		var _printers = new org.lucee.extension.print.javaxPrintServices().list();
		var printers = [];
		for ( var p in _printers ){
			arrayAppend( printers, p.getName() );
		}
		return printers;
	}
</cfscript>