component extends="org.lucee.cfml.test.LuceeTestCase" labels="print" {

	function beforeAll(){
		variables.missingPrinterName = "not_existing_printer";
		variables.testPrinterName = "PDF"; // default for CUPS on Github actions
		//variables.testPrinterName = "Canon TS3100 series";
		//variables.testPrinterName = "Microsoft Print to PDF";

		variables.plainTextFile = getTempFile("", "plain-text","txt");
		fileWrite( variables.plainTextFile, "Hi from lucee #server.lucee.version#" );
	};

	function run() {
		describe("cfprint tag", function() {

			it("should throw an error, printer not found", function(currentSpec) {
				expect( function(){
					cfprint(
						source = getMonoPDF("404"),
						printer = variables.missingPrinterName,
						pages = "1"
					);
				}).toThrow();
			});

			it("should print a mono PDF file without throwing an error - page 1", function(currentSpec) {
				if ( !hasPrinter() ) return;
				SystemOutput( "mono printing to [#variables.testPrinterName#]", true );
				cfprint(
					source = getMonoPDF("page 1"),
					printer = variables.testPrinterName,
					pages = "1",
					color = false
				);
				expect( true ).toBeTrue();
			});

			it("should print a mono PDF file without throwing an error - page 2", function(currentSpec) {
				if ( !hasPrinter() ) return;
				SystemOutput( "mono printing to [#variables.testPrinterName#]", true );
				cfprint(
					source = getMonoPDF("page 2"),
					printer = variables.testPrinterName,
					pages = "2",
					color = false
				);
				expect( true ).toBeTrue();
			});

			it("should print a mono PDF file without throwing an error - page 2-3", function(currentSpec) {
				if ( !hasPrinter() ) return;
				SystemOutput( "mono printing to [#variables.testPrinterName#]", true );
				cfprint(
					source = getMonoPDF("page 2-3"),
					printer = variables.testPrinterName,
					pages = "2-3",
					color = false
				);
				expect( true ).toBeTrue();
			});

			it("should print a mono PDF file without throwing an error - all pages", function(currentSpec) {
				if ( !hasPrinter() ) return;
				SystemOutput( "mono printing to [#variables.testPrinterName#]", true );
				cfprint(
					source = getMonoPDF("all 3 pages"),
					printer = variables.testPrinterName,
					color = false
				);
				expect( true ).toBeTrue();
			});

			it("should print a color PDF file without throwing an error - AUTO", function(currentSpec) {
				if ( !hasPrinter() ) return;
				SystemOutput( "color printing to [#variables.testPrinterName#], render='auto'", true );
				cfprint(
					source = getColorPDF("auto page 1"),
					printer = variables.testPrinterName,
					pages = "1",
					color = true
				);
				expect( true ).toBeTrue();
			});

			it("should print a color PDF file without throwing an error - RASTER", function(currentSpec) {
				if ( !hasPrinter() ) return;
				SystemOutput( "color printing to [#variables.testPrinterName#], render='raster'", true );
				cfprint(
					source = getColorPDF("raster page 1"),
					printer = variables.testPrinterName,
					pages = "1",
					color = true,
					render = 'raster'
				);
				expect( true ).toBeTrue();
			});

			it("should print a color PDF file without throwing an error - PRINTER", function(currentSpec) {
				if ( !hasPrinter() ) return;
				SystemOutput( "color printing to [#variables.testPrinterName#], render='printer'", true );
				try {
					cfprint(
						source = getColorPDF("printer page 2"),
						printer = variables.testPrinterName,
						pages = "2",
						color = true,
						render = 'printer'
					);
					expect( true ).toBeTrue();
				} catch (e){
					systemOutput(e.message, true);
				}
			});

			xit("should print a plain text file without throwing an error", function(currentSpec) {
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

	private function getColorPDF( message ){
		var sampleColorFile = getTempFile("", "color-test","pdf");
		cfdocument(format="PDF", filename="#sampleColorfile#", overwrite=true){
			cfdocumentsection(name = "page 1" ) {
				echo( "<h1 style='color:red'>(RED) Hi from lucee #server.lucee.version# page 1</h1>" );
				echo( "<h2 style='color:blue'>(BLUE)#arguments.message.toJson()#</h2>" );
			}
			cfdocumentsection(name = "page 2" ) {
				echo( "<h1 style='color:red'>(RED) Hi from lucee #server.lucee.version# page 2</h1>" );
				echo( "<h2 style='color:blue'>(BLUE)#arguments.message.toJson()#</h2>"  );
			}
			cfdocumentsection(name = "page 3" ) {
				echo( "<h1 style='color:red'>(RED) Hi from lucee #server.lucee.version# page 3</h1>" );
				echo( "<h2 style='color:blue'>(BLUE)#arguments.message.toJson()#</h2>"  );
			}
		}
		return sampleColorFile
	}

	private function getMonoPDF( message ){
		var sampleMonofile = getTempFile("", "mono-test","pdf");
		cfdocument(format="PDF", filename="#sampleMonofile#", overwrite=true){
			cfdocumentsection(name = "page 1" ) {
				echo( "<h1>(Mono) Hi from lucee #server.lucee.version# page 1</h1>" );
				echo( "<h2>#arguments.message.toJson()#</h2>" );
			}

			cfdocumentsection(name = "page 2" ) {
				echo( "<h1>(Mono) Hi from lucee #server.lucee.version# page 2</h1>" );
				echo( "<h2>#arguments.message.toJson()#</h2>" );
			}

			cfdocumentsection(name = "page 3" ) {
				echo( "<h1>(Mono) Hi from lucee #server.lucee.version# page 3</h1>" );
				echo( "<h2>#arguments.message.toJson()#</h2>" );
			}
		}
		return sampleMonofile;
	}

}