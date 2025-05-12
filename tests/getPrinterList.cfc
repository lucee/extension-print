component extends="org.lucee.cfml.test.LuceeTestCase" labels="print" {

	function run() {

		describe("getPrinterList", function() {

			it(title="",  body=function() {
				var printers = getPrinterList();
				// expect( isSimpleValue( printers ) ).toBeTrue();
				expect(printers).toBeArray();
				SystemOutput( "", true );
				SystemOutput( "-------- printers-------", true);
				ArrayEach( printers, function( printer ){
					SystemOutput(printer, true);
				});

			});

		});

	}

}