component extends="org.lucee.cfml.test.LuceeTestCase" labels="print" {
	
	function run() {
		describe("cfprint tag", function() {

			it("check the function getPrinterInfo is installed", function() {
				var info = GetFunctionData( 'getPrinterInfo' );
				expect( info ).toHaveKey( "name" );
				expect( info ).toHaveKey( "arguments" );
				expect( info ).toHaveKey( "status" );
				expect( info.status ).toBe( "implemented" );
				expect( len( info.arguments ) ).toBe( 1 );
			});

			it("check the function getPrinterList is installed", function() {
				var info = GetFunctionData( 'getPrinterList' );
				expect( info ).toHaveKey( "name" );
				expect( info ).toHaveKey( "arguments" );
				expect( info ).toHaveKey( "status" );
				expect( info.status ).toBe( "implemented" );
				expect( len( info.arguments ) ).toBe( 0 );
			});

		});
	}
}