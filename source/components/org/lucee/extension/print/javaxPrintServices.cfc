component {
	import javax.print.PrintServiceLookup;

	function list(){
		return PrintServiceLookup::lookupPrintServices( nullValue(), nullValue() );
	}

	function info( printerName ){
		var printers = list();
		var _printerName = arguments.printerName;
		var printer = ArrayFilter( printers, function( item ){
			return _printerName == item.getName();
		});
		if ( arrayLen( printer ) != 1 )
			throw "Printer [#arguments.printer#] not found";
		var info = {};
		var attr = printer[1].getAttributes().toArray();
		arrayEach(attr, function( att ){
			info[ att.getName() ] = att.getValue();
		});
		return info;
	}

}