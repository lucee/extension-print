<cfscript>
	/**
	* Returns a list of local printers
	*/
	public string function getPrinterList(){
		var printers = [];
		var localPrinters = new org.lucee.extension.print.javaxPrintServices().list();
		for ( var p in localPrinters ){
			arrayAppend( printers, p.getName() );
		}
		return printers.toList();
	}
</cfscript>