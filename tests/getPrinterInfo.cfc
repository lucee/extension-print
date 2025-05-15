component extends="org.lucee.cfml.test.LuceeTestCase" labels="print" {

	function run() {

		describe("getPrinterInfo", function() {

			it( title="enumerate printers and call getPrinterInfo",  body=function() {
				var printers = ListToArray( getPrinterList() );
				SystemOutput( "", true );
				ArrayEach( printers, function( printer ){
					SystemOutput("-------- printer [ #printer #]-------", true);

					var info = getPrinterInfo( printer );
					expect( info ).toBeStruct();

					for ( var i in info )
						SystemOutput(i & ": " & info[ i ], true);
					SystemOutput("", true );
				});
			});

			it( title="calling getPrinterInfo with an invalid printer url should throw",  body=function() {
				expect( function(){
					var info = getPrinterInfo( "123" );
				}).toThrow();
			});

		});

	}

}