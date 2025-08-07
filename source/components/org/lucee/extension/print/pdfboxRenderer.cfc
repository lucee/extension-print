/**
 * Converts a PDF file to a series of images using the Apache PDFBox 3.0.5 library.
 * This component defines its own Java dependencies using the 'javasettings' attribute.
 */
component accessors="true" javaSettings='{
	"maven": [
		{
			"groupId": "org.apache.pdfbox",
			"artifactId": "pdfbox",
			"version": "3.0.5"
		},
		{
			"groupId": "org.apache.pdfbox",
			"artifactId": "fontbox",
			"version": "3.0.5"
		},
		{
			"groupId": "commons-logging",
			"artifactId": "commons-logging",
			"version": "1.3.5"
		}
	]
}' {

	/**
	 * Converts a PDF file to a series of images (one image per page).
	 *
	 * @param pdfPath The absolute path to the input PDF file.
	 * @param outputDir The absolute path to the directory where images will be saved.
	 * @param imageFormat The format of the output images (e.g., "png", "jpeg"). Defaults to "png".
	 * @param dpi The dots per inch for the rendered images. Defaults to 300.
	 * @param pageRange A string representing the page range to convert (e.g., "1-3,5,7-9"). All pages are converted by default.
	 * @return An array of absolute paths to the generated image files.
	 */
	public array function convert(
		required string pdfPath,
		required string outputDir,
		string imageFormat="png",
		numeric dpi=300,
		string pageRange="",
		boolean color=false
	) {
		import java.io.File;
		import javax.imageio.ImageIO;
		import org.apache.pdfbox.Loader;
		import org.apache.pdfbox.pdmodel.PDDocument;
		import org.apache.pdfbox.rendering.PDFRenderer;
		import org.apache.pdfbox.rendering.ImageType;

		var outputPaths = [];
		var pdfFile = new File(arguments.pdfPath);

		var outputDirectory = new File(arguments.outputDir);
		if (!outputDirectory.exists()) {
			outputDirectory.mkdirs();
		}

		try {
			var document = Loader::loadPDF(pdfFile);
			var pdfRenderer = new PDFRenderer(document);
			var numberOfPages = document.getNumberOfPages();
			
			systemOutput("", true);
			systemOutput("pageRange: #arguments.pageRange#", true);
			systemOutput("numberOfPages: #numberOfPages#", true);

			var pagesToProcess = [];
			if (len(arguments.pageRange)) {
				pagesToProcess = getPagesToProcess(arguments.pageRange, numberOfPages);
			} else {
				for (var i = 1; i <= numberOfPages; i++) {
					arrayAppend(pagesToProcess, i);
				}
			}
			systemOutput("pagesToProcess: #pagesToProcess.toJson()#", true);

			var imageType = arguments.color ? ImageType::RGB : ImageType::GRAY;
			systemOutput("color: #arguments.color#", true);
			systemOutput(imageType, true);


			for (var pageNumber in pagesToProcess) {
				// Pages in PDFBox are zero-indexed, so subtract 1
				var pageIndex = pageNumber - 1;
				
				if (pageIndex < 0 || pageIndex >= numberOfPages) {
					continue;
				}

				// Render the page to a BufferedImage
				var bufferedImage = pdfRenderer.renderImageWithDPI(pageIndex, arguments.dpi, imageType);

				var outputFileName = "#outputDir#/page-#pageNumber#.#arguments.imageFormat#";
				var outputFile = new File(outputFileName);

				ImageIO::write(bufferedImage, arguments.imageFormat, outputFile);
				arrayAppend(outputPaths, outputFile.getAbsolutePath());
			}

		} catch (any e) {
			throw(
				message="Failed to convert PDF to images.",
				detail=e.message & " - " & e.detail,
				type="PDFConversionException",
				cause=e
			);
		} finally {
			if (!isNull(document)) {
				document.close();
			}
		}

		return outputPaths;
	}

	/**
	 * Parses a page range string (e.g., "1-3,5,7-9") and returns an array of page numbers.
	 *
	 * @param rangeString The string representing the page range.
	 * @param totalPages The total number of pages in the PDF.
	 * @return An array of integers representing the pages to process.
	 */
	public array function getPagesToProcess(required string rangeString, required numeric totalPages) {
		var pages = [];
		var parts = listToArray(arguments.rangeString, ",");
		
		for (var part in parts) {
			var trimmedPart = trim(part);
			if (isNumeric(trimmedPart)) {
				// single page
				var page = int(trimmedPart);
				if (page > 0 && page <= arguments.totalPages) {
					arrayAppend(pages, page);
				} else {
					throw "Invalid page [#page#] from pages [#arguments.rangeString#]";
				}
			} else if (listLen(trimmedPart, "-") == 2) {
				var range = listToArray(trimmedPart, "-");
				if ( arrayLen(range) != 2 )
					throw "Invalid page range [#trimmedPart#] from pages [#arguments.rangeString#] range should have two numbers";

				var start = int(trim(range[1]));
				var end = int(trim(range[2]));
				if ( end <= start)
					throw "Invalid page range [#trimmedPart#] from pages [#arguments.rangeString#] end [#end#] is greater than start [#start#]";
				if ( start eq 0 || start > arguments.totalPages || end eq 0 || end > arguments.totalPages )
					throw "Invalid page range [#trimmedPart#] from pages [#arguments.rangeString#]";
				if (start > 0 && start <= arguments.totalPages && end > 0 && end <= arguments.totalPages && start <= end) {
					for (var i = start; i <= end; i++) {
						arrayAppend(pages, i);
					}
				}
			} else {
				throw "Invalid page [#page#] from pages [#arguments.rangeString#]";
			}
		}
		pages = ArrayRemoveDuplicates( pages );
		if (arrayLen(pages) == 0)
			throw "No pages to process from [#arguments.rangeString#]";
		arraySort(pages, "numeric");
		return pages;
	}
}