component extends="jmDNSListener" {

	variables.name="serviceListener";
	variables.services = {};

	function serviceAdded(event) {
		_logger("Service added   : " & event.getName() & "." & event.getType(), event);
		variables.service[event.getType()] = event.getName();
	}

	function serviceRemoved(event) {
		_logger("Service removed : " & event.getName() & "." & event.getType(), event);
		structDelete( variables.services, event.getType());
	}

	function serviceResolved(event) {
		_logger("Service resolved: " & event.getInfo() & "." & event.getType(), event);
	}

	function getServices(){
		return variables.services;
	}

	function setServicesDetail( detail ){
		variables.servicesDetail = detail;
	}

	function getServicesDetail(){
		return variables.servicesDetail;
	}

}