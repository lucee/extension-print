component extends="org.lucee.cfml.test.LuceeTestCase" labels="print" {

	function beforeAll(){
		variables.missingPrinterName = "not_existing_printer";
		variables.testPrinterName = "PDF"; // default for CUPS on Github actions
		variables.testPrinterName = "Canon TS3100 series";
		variables.testPrinterName = "Microsoft Print to PDF";

		variables.sampleColorFile = getTempFile("", "color-test","pdf");
		cfdocument(format="PDF", filename="#sampleColorfile#", overwrite=true){
			cfdocumentsection(name = "page 1" ) {
				echo("<h1 style='color:red'>(RED) Hi from lucee #server.lucee.version# page 1</h1>");
			}
			cfdocumentsection(name = "page 2" ) {
				echo("<h1 style='color:red'>(RED) Hi from lucee #server.lucee.version# page 2</h1>");
			}
			cfdocumentsection(name = "page 3" ) {
				echo("<h1 style='color:red'>(RED) Hi from lucee #server.lucee.version# page 3</h1>");
			}
		}

		variables.sampleMonofile = getTempFile("", "mono-test","pdf");
		cfdocument(format="PDF", filename="#sampleMonofile#", overwrite=true){
			cfdocumentsection(name = "page 1" ) {
				echo("<h1>Hi from lucee #server.lucee.version# page 1</h1>");
			}

			cfdocumentsection(name = "page 2" ) {
				echo("<h1>Hi from lucee #server.lucee.version# page 2</h1>");
			}

			cfdocumentsection(name = "page 3" ) {
				echo("<h1>Hi from lucee #server.lucee.version# page 3</h1>");
			}
		}

		variables.plainTextFile = getTempFile("", "plain-text","txt");
		fileWrite( variables.plainTextFile, "Hi from lucee #server.lucee.version#" );
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

			it("should print a mono PDF file without throwing an error - page 1", function() {
				if ( !hasPrinter() ) return;
				SystemOutput( "mono printing to [#variables.testPrinterName#]", true );
				cfprint(
					source = variables.sampleMonofile,
					printer = variables.testPrinterName,
					pages = "1",
					color = false
				);
				expect( true ).toBeTrue();
			});

			it("should print a mono PDF file without throwing an error - page 2", function() {
				if ( !hasPrinter() ) return;
				SystemOutput( "mono printing to [#variables.testPrinterName#]", true );
				cfprint(
					source = variables.sampleMonofile,
					printer = variables.testPrinterName,
					pages = "2",
					color = false
				);
				expect( true ).toBeTrue();
			});

			it("should print a mono PDF file without throwing an error - page 2-3", function() {
				if ( !hasPrinter() ) return;
				SystemOutput( "mono printing to [#variables.testPrinterName#]", true );
				cfprint(
					source = variables.sampleMonofile,
					printer = variables.testPrinterName,
					pages = "2-3",
					color = false
				);
				expect( true ).toBeTrue();
			});

			it("should print a mono PDF file without throwing an error - all pages", function() {
				if ( !hasPrinter() ) return;
				SystemOutput( "mono printing to [#variables.testPrinterName#]", true );
				cfprint(
					source = variables.sampleMonofile,
					printer = variables.testPrinterName,
					color = false
				);
				expect( true ).toBeTrue();
			});

			it("should print a color PDF file without throwing an error - AUTO", function() {
				if ( !hasPrinter() ) return;
				SystemOutput( "color printing to [#variables.testPrinterName#], render='auto'", true );
				cfprint(
					source = variables.sampleColorfile,
					printer = variables.testPrinterName,
					pages = "1",
					color = true
				);
				expect( true ).toBeTrue();
			});

			it("should print a color PDF file without throwing an error - RASTER", function() {
				if ( !hasPrinter() ) return;
				SystemOutput( "color printing to [#variables.testPrinterName#], render='raster'", true );
				cfprint(
					source = variables.sampleColorfile,
					printer = variables.testPrinterName,
					pages = "1",
					color = true,
					render = 'raster'
				);
				expect( true ).toBeTrue();
			});

			it("should print a color PDF file without throwing an error - PRINTER", function() {
				if ( !hasPrinter() ) return;
				SystemOutput( "color printing to [#variables.testPrinterName#], render='printer'", true );
				try {
					cfprint(
						source = variables.sampleColorfile,
						printer = variables.testPrinterName,
						pages = "1",
						color = true,
						render = 'printer'
					);
					expect( true ).toBeTrue();
				} catch (e){
					systemOutput(e.message, true);
				}
			});

			xit("should print a plain text file without throwing an error", function() {
				if ( !hasPrinter() ) return;
				SystemOutput( "plain text printing to [#variables.testPrinterName#]", true );
				cfprint(
					source = variables.plainTextFile,
					printer = variables.testPrinterName,
					pages = "1"
				);
				expect( true ).toBeTrue();
			});
		});
	};

	private function hasPrinter(){
		return len( variables.testPrinterName ) gt 0;
	}
}