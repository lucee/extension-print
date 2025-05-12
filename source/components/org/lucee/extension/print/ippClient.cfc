component javaSettings='{maven:["de.gmuth:ipp-client:3.2"]}'{
	import de.gmuth.ipp.client.IppInspector;
	import de.gmuth.ipp.client.IppPrinter;
	import de.gmuth.ipp.client.CupsClient;
	import de.gmuth.ipp.client.IppJob;
	import de.gmuth.ipp.client.IppColorMode;
	import de.gmuth.ipp.core.IppAttributesGroup;
	import de.gmuth.ipp.core.IppTag;
	import de.gmuth.ipp.core.IppOperation;
	import de.gmuth.ipp.core.IppRequest;
	import de.gmuth.ipp.attributes.TemplateAttributes;
	import de.gmuth.ipp.attributes.DocumentFormat;
	import de.gmuth.ipp.attributes.ColorMode;
	import java.net.URI;
	import java.io.File;
	import java.io.FileInputStream;

	variables.attributeBuilder = new component implementsJava="de.gmuth.ipp.core.IppAttributeBuilder" {

	}

	public function inspect(string printerService){
		//var ippUrl = replace( arguments.printerService )
		var printerURI = URI::create( arguments.printerService );
		var inspector = new IppInspector();
		dump(inspector);
		return inspector.inspect(printerURI, false, false);
	}

	public function info(string printerService){
		//var ippUrl = replace( arguments.printerService )
		//var printerURI = URI::create( arguments.printerService );
		var printer = new IppPrinter( arguments.printerService );
		//dump(printer.getAttributes());
		return toInfo(printer.getAttributes());
	}

	public function getCups( string host ){
		var cups = new CupsClient( arguments.host );
		return cups.getPrinterNames()
	}

	public function print(string printerService, printFile){
		//var ippUrl = replace( arguments.printerService )
		var file = new File( arguments.printFile );
		//var printerURI = URI::create( arguments.printerService );
		var printer = new IppPrinter( arguments.printerService );
		dump(printer);
		dump(printer.getState().toString());
		dump(printer.getAttributes().getValues("media-supported"));

		attributes =   createObject("java", "java.lang.reflect.Array").newInstance(
			createObject("java", "de.gmuth.ipp.core.IppAttributeBuilder").getClass(),
			0 // initial size (0 elements)
		);
		
		ArrayEach()

		dump(attributes.getClass());

		var df = new DocumentFormat("application/pdf");
		var jn = TemplateAttributes::jobName(file.name);
		var colorMode = new ColorMode("Monochrome");

		var arr = [createObject("java", "de.gmuth.ipp.core.IppAttributeBuilder").init(df)]//, jn, colorMode];
		javaArray = createObject("java", "java.util.Arrays").asList(arr).toArray(
  			createObject("java", "de.gmuth.ipp.core.IppAttributeBuilder[]")
		);
		dump(javaArray);

		attributes.put(df);
		attributes.put(colorMode);
		attributes.put(jn);
		dump(attributes);
		//var job = printer.createJob( df , jn,  colorMode );
		var req = new IppRequest();//.document(file);
		req.setDocumentInputStream(new FileInputStream(file));
		dump(req); abort;
		
		printer.sendDocument();
		job.waitForTermination();
		job.logDetails();
	//	dump(job.toString());
		//dump(printer.getAttributes());
		return toInfo(printer.getAttributes());
	}

	private struct function toInfo(info){
		var st = [=];
		for (var i in info){
			st[i] = {
				values: info[i].getValues(),
				desc: info[i].toString(),
				tag: info[i].getTag().toString(),
				getClass: function () { return info[i]; }
			}
			arrayEach(st[i].values, function(el, idx, arr){
				if (isSimpleValue(el)) return;
				arr[idx] = el.toString();
			});
		}
		return st;
	}

}