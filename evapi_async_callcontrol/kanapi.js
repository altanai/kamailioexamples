
var net = require('net');
 
var HOST = '127.0.0.1';
var PORT = 8448;
 
var client = new net.Socket();
 
client.connect(PORT, HOST, function() {
 
	console.log('CONNECTING TO: ' + HOST + ':' + PORT);
 
});
 
client.on('connect', function(data) {
	console.log('CONNECTED TO: ' + HOST + ':' + PORT);
	// Write a message to the socket as soon as the client is connected, the server will receive it as message from the client 
	// client.write('I am the node.js SIP routing engine');
	kanapi_send_response('{ "version": "1.0", "client": "kanapi.js", "akey": "1q2w3e4r" }');
});
 
client.on('error', function(e) {
    if(e.code == 'ECONNREFUSED') {
        console.log('Is the server running at ' + PORT + '?');
 
        setTimeout(function() {
            client.connect(PORT, HOST, function(){
                // console.log('CONNECTING TO: ' + HOST + ':' + PORT + ' (*)');
            });
        }, 4000);
 
        console.log('Timeout for 5 seconds before trying port:' + PORT + ' again');
 
    }   
});
 
// Add a 'data' event handler for the client socket
// data is what the server sent to this socket
client.on('data', function(data) {
 
	console.log('RECEIVED DATA: ' + data);
	kanapi_handle_request(data);
 
	// Close the client socket completely
	// client.destroy();
 
});
 
// Add a 'close' event handler for the client socket
client.on('close', function() {
	console.log('Connection closed');
});
 
function kanapi_handle_request(data) {
    var size, strings, jdoc;
	var re = /^\+?[1-9]\d{1,14}$/;
	var response = {};
 
    size = 0;
    strings = [];
 
    data = new Buffer(data || '', null);
 
    for(var i = 0; i < data.length; i++) {
        var offset, c;
 
        c = data[i];
 
        if (c === 58) {
            offset = i + 1;
            size = parseInt(data.toString(null, size, i));
            strings.push(data.slice(offset, offset + size));
            i += size + 1;
            size += offset + 1;
            continue;
        }
    }
 
    console.log('[' + strings + '] <----: [' + data + ']');
 
	jdoc = JSON.parse(strings);
 
	console.log('json: [' + JSON.stringify(jdoc) + ']');
	if(jdoc.event != 'sip-routing') {
		return kanapi_send_response('{ "version": "1.0", "routing": "none" }');
	}
 
	console.log('caller: [' + jdoc.caller + ']');
	console.log('callee: [' + jdoc.callee + ']');
 
    response.version="1.0";
    response.xtra = {};
    response.xtra.tindex=jdoc.tindex;
    response.xtra.tlabel=jdoc.tlabel;
 
    if(re.test(jdoc.callee)) {
    	// e.164 number - send to gateway
    	response.routing = "serial";
    	//response.routing = "parallel";
    	response.routes = [];
    	response.routes[0] = {};
    	response.routes[0].uri = "sip:127.0.0.1:5080";
    	response.routes[0].headers = {};
    	response.routes[0].headers.extra = "X-Hdr-A: abc\r\nX-Hdr-B: bcd\r\n";
    	response.routes[1] = {};
    	response.routes[1].uri = "sip:127.0.0.1:5090";
    	response.routes[1].headers = {};
    	response.routes[1].headers.extra = "X-Hdr-C: cde\r\nX-Hdr-D: def\r\n";
	} else {
		// expect local extension - send to location
    	response.routing = "location";
	}
	return kanapi_send_response(JSON.stringify(response));
}
 
function kanapi_send_response(data) {
    var buffer;
 
    data = new Buffer(data || '', null);
 
    buffer = Buffer.concat([new Buffer(data.length + ':', null), data, new Buffer(',', null)]);
 
    console.log('[' + data + '] :----> [' + buffer + ']');
 
	client.write(buffer.toString('ascii'));
    return buffer;
}