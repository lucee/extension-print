component extends="org.lucee.cfml.test.LuceeTestCase" labels="print" {
	
	function run() {
		describe("cfprint tag", function() {

			it("check the tag is installed", function() {
				var info = GetTagData( "cf", "print" );
				expect( info ).toHaveKey( "name" );
				expect( info ).toHaveKey( "attributes" );
				expect( info.status ).toBe( "implemented" );
				expect( len(info.attributes ) ).toBeGT( 0 );
			});

		});
	}
}