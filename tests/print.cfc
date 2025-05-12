component extends="org.lucee.cfml.test.LuceeTestCase" labels="print" {

	function beforeAll(){
		variables.missingPrinterName = "not_existing_printer";
		variables.testPrinterName = ""; // "Microsoft XPS Document Writer";

		variables.sampleMonofile = getTempFile("", "mono-test","pdf");
		variables.sampleColorFile = getTempFile("", "color-test","pdf");

		
		cfdocument(format="PDF", filename="#sampleColorfile#", overwrite=true){
			echo("<h1 style='color:red'>Hi from lucee #server.lucee.version#</h1>");
		}

		cfdocument(format="PDF", filename="#sampleMonofile#", overwrite=true){
			echo("<h1>Hi from lucee #server.lucee.version#</h1>");
		}
	};

	function run() {
		describe("cfprint tag", function() {

			it("should throw an error, printer not found", function() {
				expect( function(){
					cfprint(
						source = variables.sampleMonofile,
						printer = variables.missingPrinterName,
						pages = "1"
					);
				}).toThrow();
			});

			it("should print a mono PDF file without throwing an error", function() {
				if ( !hasPrinter() ) return;
				cfprint(
					source = variables.sampleMonofile,
					printer = variables.testPrinterName,
					pages = "1",
					color = false
				);
				expect( true ).toBeTrue();
			});

			it("should print a color PDF file without throwing an error", function() {
				if ( !hasPrinter() ) return;
				cfprint(
					source = variables.sampleColorfile,
					printer = variables.testPrinterName,
					pages = "1",
					color = true
				);
				expect( true ).toBeTrue();
			});
		});
	};

	private function hasPrinter(){
		return len( variables.testPrinterName ) gt 0;
	}
}