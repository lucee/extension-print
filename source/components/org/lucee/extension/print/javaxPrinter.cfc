component {
	import java.io.File;
	import java.io.FileInputStream;
	import javax.print.attribute.HashPrintRequestAttributeSet;
	import javax.print.attribute.HashDocAttributeSet;
	import javax.print.attribute.standard.Chromaticity;
	import javax.print.attribute.standard.Copies;
	import javax.print.attribute.standard.Fidelity;
	import javax.print.attribute.standard.JobName;
	import javax.print.attribute.standard.MediaSizeName;
	import javax.print.attribute.standard.PageRanges;
	import javax.print.DocFlavor;
	import javax.print.PrintServiceLookup;
	import javax.print.SimpleDoc;
	import java.util.Locale;

	public function print( string printer, string paper){
		var attr = new HashPrintRequestAttributeSet();
		var docAttr = new HashDocAttributeSet();

		var PrintService = findPrinter( arguments.printer, attr );

		if ( isAttributeSupported( PrintService, "JobName" ) ){
			attr.add(new JobName( listLast(arguments.source, "/\"), Locale::US ));
		}

		if ( isAttributeSupported( PrintService, "Chromaticity" ) ){
			if ( len( arguments.color ) )
				docAttr.add( arguments.color ? Chromaticity::COLOR : Chromaticity::MONOCHROME );
		}

		if ( isAttributeSupported( PrintService, "Fidelity" ) ){
			if ( len( arguments.fidelity ) ){
				attr.add(Fidelity::FIDELITY_TRUE );
			} else {
				attr.add(Fidelity::FIDELITY_FALSE );
			}
		}
		
		if ( isAttributeSupported( PrintService, "Copies" ) ){
			if ( len( arguments.copies ) && arguments.copies > 1 )
				attr.add(new Copies( int(arguments.copies )) );
		}

		if ( isAttributeSupported( PrintService, "MediaSizeName" ) ){
			if ( len( arguments.paper ) )
				attr.add( getMedia( arguments.paper ).get(nullValue()) );
		}

		//dumpAttr(var=attr, label="RequestAttr");
		//dumpAttr(var=docAttr, label="DocAttr");

		var printJob = PrintService.createPrintJob();

		// INPUT_STREAM.AUTOSENSE is unreliable
		var printerSupportsPDF = isPdfSupported(PrintService);

		if ( arguments.render == "printer" && !printerSupportsPDF){
			throw "Printer does not report supporting printing PDF documents directly, try using render='raster|auto'";
		}

		var renders = {
			"AUTO": "Decide automatically based on capabilties",
			"RASTER": "Render PDF to PNG using PDFBOX and print PNG",
			"PRINTER": "Pass PDF directly to printer"
		};

		if (! structKeyExists(renders, arguments.render) )
			throw "Invalid [render] attribute [#arguments.render#], available render types are [#structKeyList(renders, ", ")#";

		if ( arguments.render != "raster" && printerSupportsPDF ) {

			var fis = new FileInputStream( arguments.source );

			// the PDFbox raster path handles the paging itself
			if ( len( arguments.pages ) ){
				systemOutput("pages: [#arguments.pages#]", true);
				var _pages = getPages( toString(arguments.pages) );
				systemOutput(_pages.toString(), true);
				attr.add( _pages );
			}

			// seems for DocFlavor.INPUT_STREAM.AUTOSENSE docAttr isn't supported?
			// var flavor = createObject("java", "javax.print.DocFlavor$INPUT_STREAM").AUTOSENSE;
			//var doc = new SimpleDoc( fis, flavor, docAttr );
			//var doc = new SimpleDoc( fis, flavor, nullValue() ); // LDEV-5608
			var doc = getSimpleDoc(fis, docAttr);

			//dump(doc);
			//dump(printJob);
			var printJobListener = new javaxPrintJobListener( logger, getPageContext() );
			//printjob.addPrintJobListener( printJobListener );
			printJob.print(doc, attr );
			//sleep(5000);

			//systemOutput(printJobListener.getLog(), true);
		} else {
			// print to png using pdf box
			var pdfToImage = new pdfboxRenderer();
			var tempPrintImages = getTempDirectory(true);
			var images = pdfToImage.convert(pdfPath=arguments.source,
				outputDir=tempPrintImages,
				imageFormat="png",
				dpi=300,
				pageRange=toString(arguments.pages),
				color=arguments.color );
			var printJob = PrintService.createPrintJob();
			var imageFlavor = createObject("java", "javax.print.DocFlavor$INPUT_STREAM").PNG;
			for (var imagePath in images) {
				var imageFile = new File( imagePath );
				var imageFis = new FileInputStream( imageFile );
				var imageDoc = new SimpleDoc(imageFis, imageFlavor, docAttr);
				var printJob = PrintService.createPrintJob();
				printJob.print(imageDoc, attr);
				imageFis.close();
				imageFile.delete();
			}
			directoryDelete(tempPrintImages);
		}

	}

	private Object function getSimpleDoc(java.lang.Object fis, Object docAttr) type="java" {
		javax.print.DocFlavor flavor = javax.print.DocFlavor.INPUT_STREAM.PDF;
		javax.print.SimpleDoc doc = new javax.print.SimpleDoc(fis, flavor, ((javax.print.attribute.DocAttributeSet) docAttr));
		//javax.print.SimpleDoc doc = new javax.print.SimpleDoc(fis, flavor, null);
		return doc;
	}
	/*
	private Object function _findPrinter(Object attr) type="java" {
		javax.print.DocFlavor flavor = javax.print.DocFlavor.INPUT_STREAM.AUTOSENSE;
		return javax.print.PrintServiceLookup.lookupPrintServices( null, ((javax.print.attribute.HashPrintRequestAttributeSet) attr) );
	}
	*/

	private function findPrinter( printer, attr ){
		var foundServiceNames = [];
		var flavor = createObject("java", "javax.print.DocFlavor$INPUT_STREAM").PDF; // DocFlavor::INPUT_STREAM; // i.e. pdf
		//dump(flavor.getMimeType());
		//dump(attr);

		// this behaves rather oddly, try the various combinatations of arguments
		// if the printer is found, it returns it

		var services = PrintServiceLookup::lookupPrintServices( flavor, attr ); ///returns nothing???
		var _printer = matchPrinter( arguments.printer, services, foundServiceNames);
		if ( len(_printer) ) {
			// systemOutput("match via flavor, attr", true);
			return _printer;
		}

		var services = PrintServiceLookup::lookupPrintServices( nullvalue(), attr );
		_printer = matchPrinter( arguments.printer, services, foundServiceNames);
		if ( len(_printer) ) {
			// systemOutput("match via null, attr", true);
			return _printer;
		}
		// this is the one which seems to work most often
		var services = PrintServiceLookup::lookupPrintServices( nullvalue(), nullvalue() );
		_printer = matchPrinter( arguments.printer, services, foundServiceNames);
		if ( len(_printer) ) {
			// systemOutput("match via null, null", true);
			return _printer;
		}

		throw "Could not find a printer named [#arguments.printer#], available printers are [#foundServiceNames.toList(", ")#]";
	}

	private function matchPrinter( required string printer, array services, array foundServiceNames){
		loop array="#services#" item="local.service" {
			if ( service.getName() eq arguments.printer )
				return service;
			arrayAppend( arguments.foundServiceNames, service.getName() );
		}
		return "";
	}

	private function getPages( string pages ){
		return new PageRanges( arguments.pages );
	}

	private function getMedia( string paper ){

		var mediaSizeNameClass = createObject("java", "javax.print.attribute.standard.MediaSizeName");
		var fields = mediaSizeNameClass.getClass().getFields();
		var st = [=];
		for ( var field in fields ){
			if ( arguments.paper eq field.getName() ) return field;
			st [field.getName() ] = field;
		}
		if ( listLen( arguments.paper,"_" eq 1 ) ){
			loop list="ISO,NA" item="local.prefix"{
				var key = prefix  & "_" & arguments.paper;
				if ( structKeyExists(st, key ) )
					return st[ key ];
			}
		}
		throw "Unsupported paper type [#arguments.paper#], available types are [#structKeyList(st, ", ")#]";
	}

	public boolean function isPdfSupported(required printService) {
		var docFlavorPdf = createObject("java", "javax.print.DocFlavor$INPUT_STREAM").PDF;
		var supportedFlavors = arguments.printService.getSupportedDocFlavors();

		for (var flavor in supportedFlavors) {
			if (flavor.getMimeType() == docFlavorPdf.getMimeType()) {
				return true;
			}
		}
		return false;
	}

	public boolean function isAttributeSupported(required printService, clazz) {
		var clazz = createObject("java", "javax.print.attribute.standard.#arguments.clazz#").getClass();
		return printService.isAttributeCategorySupported(clazz);
	}

	function dumpAttr(var, label){
		echo("<p><b>#label# Attributes </b></p>");
		var attr = var.toArray();
		throw "zac";
		systemOutput("....#label#....", true);
		for (var a in attr){
			systemOutput(a.getName() & ": " & a.toString(), true);
			dump(var=a.getName() & ": " & a.toString(), label=label);
		}
		systemOutput("", true);

	}

	private void function logger(pc, type, mess, event){
		// any errors here are currently hidden
		// also the pageContext is not available so we have to pass it in
		try {
			pc.write( "<b>#type#</b>: #mess# <br>");
			pc.flush();
		} catch (e){
			systemOutput(e);
		}
	}
}