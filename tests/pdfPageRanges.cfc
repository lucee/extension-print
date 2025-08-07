component extends="org.lucee.cfml.test.LuceeTestCase" labels="print" {

	function beforeAll() {
		variables.processor = new org.lucee.extension.print.pdfboxRenderer();
	}

	function run() {
		describe("when given valid inputs", function() {
			it("should return a single page number correctly", function() {
				var result = variables.processor.getPagesToProcess(rangeString="3", totalPages=10);
				expect(result).toBe( [3] );
			});

			it("should return a range of pages correctly", function() {
				var result = variables.processor.getPagesToProcess(rangeString="2-5", totalPages=10);
				expect(result).toBe( [2, 3, 4, 5] );
			});

			it("should handle a combination of single pages and ranges", function() {
				var result = variables.processor.getPagesToProcess(rangeString="1, 4-6, 9", totalPages=10);
				expect(result).toBe( [1, 4, 5, 6, 9] );
			});

			it("should correctly sort and remove duplicates", function() {
				var result = variables.processor.getPagesToProcess(rangeString="4, 1-3, 2, 5-6, 4", totalPages=10);
				expect(result).toBe( [1, 2, 3, 4, 5, 6] );
			});

			it("should handle ranges that cover the total pages", function() {
				var result = variables.processor.getPagesToProcess(rangeString="1-10", totalPages=10);
				expect(result).toBe( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] );
			});

			it("should handle a range with white spaces", function() {
				var result = variables.processor.getPagesToProcess(rangeString=" 2 - 5 ", totalPages=10);
				expect(result).toBe( [2, 3, 4, 5] );
			});
		});

		describe("throw when given invalid or out-of-bounds inputs", function() {
			it("should throw a single page number that is out of bounds (too high)", function() {
				expect(function(){
					variables.processor.getPagesToProcess(rangeString="11", totalPages=10);
				}).tothrow();
			});

			it("should throw on a single page number that is out of bounds (too low)", function() {
				expect(function(){
					variables.processor.getPagesToProcess(rangeString="0", totalPages=10);
				}).tothrow();
			});

			it("should throw a range that is entirely out of bounds", function() {
				expect(function(){
					variables.processor.getPagesToProcess(rangeString="11-15", totalPages=10);
				}).tothrow();
			});

			it("should throw a range with a starting page out of bounds", function() {
				expect(function(){
					variables.processor.getPagesToProcess(rangeString="11-12", totalPages=10);
				}).tothrow();
			});

			it("should throw a range with an ending page out of bounds", function() {
				expect(function(){
					variables.processor.getPagesToProcess(rangeString="8-12", totalPages=10);
				}).tothrow();
			});

			it("should throw non-numeric parts of the string", function() {
				expect(function(){
					variables.processor.getPagesToProcess(rangeString="1, invalid, 3", totalPages=5);
				}).tothrow();
			});

			it("should throw ranges with a start page greater than the end page", function() {
				expect(function(){
					variables.processor.getPagesToProcess(rangeString="5-2", totalPages=10);
				}).tothrow();
			});

			it("should return an empty array for an empty string input", function() {
				expect(function(){
					variables.processor.getPagesToProcess(rangeString="", totalPages=10);
				}).tothrow();
			});

			it("should return an empty array for an input with only commas", function() {
				expect(function(){
					variables.processor.getPagesToProcess(rangeString=", ,", totalPages=10);
				}).tothrow();
			});
		});

		describe("when handling boundary conditions", function() {
			it("should correctly handle a range with minimum pages (1)", function() {
				var result = variables.processor.getPagesToProcess(rangeString="1", totalPages=1);
				expect(result).toBe( [1] );
			});

			it("should handle a range with a maximum number of pages", function() {
				var result = variables.processor.getPagesToProcess(rangeString="1-100", totalPages=100);
				var expected = [];
				for (var i=1; i<=100; i++) {
					arrayAppend(expected, i);
				}
				expect(result).toBe( expected );
			});
			
			it("should handle a range with a start page as '1'", function() {
				var result = variables.processor.getPagesToProcess(rangeString="1-3", totalPages=5);
				expect(result).toBe( [1, 2, 3] );
			});

			it("should handle a range with the last page as the end of the range", function() {
				var result = variables.processor.getPagesToProcess(rangeString="8-10", totalPages=10);
				expect(result).toBe( [8, 9, 10] );
			});
		});
	}

}