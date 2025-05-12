component name="lucee print tag" {
	// Meta data
	this.metadata.hint = "Allows printing a document to a printer.";
	this.metadata.attributetype = "fixed";
	this.metadata.attributes = [
		"printer": {
			required: true,
			type: "string",
			default: "",
			hint: "Name of the printer to print to, can be a network or a local printer (IPP or UNC path)"
		},
		"source": {
			required: true,
			type: "any",
			default: "",
			hint: "path to a document or a variable in memory"
		},
		"type": {
			required: false,
			type: "string",
			default:"PDF",
			hint: "Type of document to print"
		},
		"copies": {
			required: false,
			type: "numeric",
			default: 1,
			hint: "Number of copies to print"
		},
		"color": {
			required:false,
			type: "boolean",
			default: false,
			hint: "Print in color or monochrome."
		},
		"fidelity": {
			required: false,
			type: "boolean",
			default: true,
			hint: "Print in high quality."
		},
		"pages": {
			required:false,
			type: "string",
			default: "",
			hint: "List of pages, or ranges to print. i.e. [1,4-5,8] otherwise print all pages"
		},
		"paper": {
			required: false,
			type: "string",
			default: "",
			hint: "Type of paper to print"
		},
	];
	/**
	* Invoked after tag is constructed
	*/
	public void function init(required boolean hasEndTag, component parent) {

		if (arguments.hasEndTag){
			throw (message = "Tag [print] doesn't not support a closing tag.");
		}

	}

	public boolean function onStartTag(struct attributes,struct caller) {

		if (!len(trim(attributes.printer ?: "")))
			throw "Attribute [printer] is required";

		if ( ! len( trim(attributes.source ?: "") ) )
			throw "Attribute [source] is required";
		else if (!FileExists(attributes.source) && !isObject( attributes.source ) )
			throw "Attribute [source] must be a file or a variable";
		doPrint( argumentCollection=arguments.attributes );
		return false;
	}

	public function doPrint(required string printer, required any source,
			string type="PDF", copies="", boolean color="false",
			boolean fidelity="true", string pages="", string paper=""){
		new org.lucee.extension.print.javaxPrinter().print(argumentCollection=arguments);
	}

	public boolean function onEndTag(struct attributes,struct caller,string generatedContent) {
		return false;
	}

}