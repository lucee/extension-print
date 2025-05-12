component javaSettings='{maven:["org.jmdns:jmdns:3.6.1"]}'{
	import javax.jmdns.JmDNS;
	import javax.jmdns.ServiceEvent;
	import javax.jmdns.ServiceListener;
	import java.net.InetAddress;

	public function discoverTypes(numeric wait=5000){
		var jmDNSService = JmDNS::create();
		var serviceTypeListener = new jmDNSServiceTypeListener(logger, getPageContext());
		jmDNSService.addServiceTypeListener(serviceTypeListener);
		sleep( wait );
		jmDNSService.close();
		return serviceTypeListener;
	}

	public function listServices(ip, string app="", string protocol="tcp", string serviceDomain="local"){
		var serviceListener = new jmDNSServiceListener( logger, getPageContext() );
		var app = arguments.app;
		if ( listLen( app,"." ) neq 3 ){
			if ( left( app, 1 ) neq "_" ) app = "_" & app;
			var serviceType = "#app#._#arguments.protocol#.#arguments.serviceDomain#.";
		} else {
			var serviceType = app;
		}
		if ( len( arguments.ip ) ) {
			var addr = InetAddress::getByName( ip );
			var jmDNSService = JmDNS::create( addr );
		} else {
			var jmDNSService = JmDNS::create();
		}

		jmDNSService.addServiceListener( serviceType, serviceListener );
		dump(arguments);
		dump(serviceType);
		flush;
		var serviceInfos = jmDNSService.list( serviceType );
		var services = [];
		for (var info in serviceInfos) {
			ArrayAppend(services, {
				"name": info.getName(),
				"server": info.getServer(),
				"description": info.getNiceTextString(),
				"application": info.getApplication(),
				"url": info.getURLs(),
				"type": info.getTypeWithSubtype(),
				"properties": toInfo(info),
				//"ip": toIp(info),
				"port": info.getPort(),
				"protocol": info.getProtocol(),
			});
		}
		serviceListener.setServicesDetail(services);
		jmDNSService.close();
		return serviceListener;
	}

	private struct function toInfo(info){
		var st = [=];
		var props = info.getPropertyNames();
		for (var i in props)
			st[i] = info.getPropertyString(i);
		return st;
	}
	private struct function toIP(info){
		var st = [=];
		var ips = info.getInetAddresses();
		for (var i in ips)
			st[i] = info.getClass(i);
		return st;
	}

	private void function logger(pc, type, mess, event){
		// any errors here are currently hidden
		// also the pageContext is not available so we have to pass it in
		try {
			pc.write( "<b>#type#</b>: #mess# <br>");
			pc.flush();
		} catch (e){
			systemOutput(e);
		}
	}

}