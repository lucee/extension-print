component extends="org.lucee.cfml.test.LuceeTestCase" labels="print" {

	function run() {

		describe("getPrinterList", function() {

			it(title="enumerate local printers",  body=function() {
				var printers = getPrinterList();
				expect( isSimpleValue( printers ) ).toBeTrue();
				SystemOutput( "", true );
				SystemOutput( "-------- local printers-------", true);
				ListEach( printers, function( printer ){
					SystemOutput(printer, true);
				});

			});

		});

	}

}