component {
	function init(logger, pc){
		variables.logger = logger;
		variables.pc = pc;
		variables.log = [];
	}

	function _logger(mess, event){
		arrayAppend( variables.log, mess );
		// errors here are currently swallowed
		try {
			variables.logger(pc, variables.name,  mess, event );
		} catch(e) {
			systemOutput(e);
		}
	}

	function getLog(){
		return variables.log;
	}
}