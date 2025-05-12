component extends="jmDNSListener" {

	variables.name="PrintJobListener";
	variables.services = {};

	function printDataTransferCompleted(event) {
		_logger("printDataTransferCompleted", event);
	}

	function printJobCanceled(event) {
		_logger("printJobCanceled", event);
	}

	function printJobCompleted(event) {
		_logger("printJobCompleted", event);
	}

	function printJobFailed(event) {
		_logger("printJobFailed", event);
	}

	function printJobNoMoreEvents(event) {
		_logger("printJobNoMoreEvents", event);
	}

	function printJobRequiresAttention(event) {
		_logger("printJobRequiresAttention", event);
	}

	function _logger(mess, event){
		arrayAppend( variables.log, {
			message: mess,
			status: event.toString()
		});
		// errors here are currently swallowed
		try {
			variables.logger(pc, variables.name,  mess, event );
		} catch(e) {
			systemOutput(e);
		}
	}
}