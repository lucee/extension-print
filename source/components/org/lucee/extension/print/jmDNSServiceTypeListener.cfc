component extends="jmDNSListener" {

	variables.name="serviceTypeListener";
	variables.serviceTypes = {};
	variables.serviceSubTypes = {};

	function serviceTypeAdded(event) {
		_logger("Service type added   : " & event.getName() & "." & event.getType(), event);
		variables.serviceTypes[event.getType()] = event;
	}

	function subTypeForServiceTypeAdded(event) {
		_logger("Sub type for Service type added   : " & event.getName() & "." & event.getType(), event);
		variables.serviceSubTypes[event.getType()] = event;
		//variables.serviceTypes[event.getType()] = event.getName();
	}

	function getServiceTypes(){
		return variables.serviceTypes;
	}

	function getServiceSubTypes(){
		return variables.serviceSubTypes;
	}

}