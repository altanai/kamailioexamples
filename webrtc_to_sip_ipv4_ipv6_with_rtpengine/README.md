# WebRTC to SIP


Issues : unistr.h: No such file or directory
Solution its is unicode file install it by typing 
```
apt-get install libunistring-dev
```



Ref:
https://github.com/havfo/WEBRTC-to-SIP/blob/master/etc/kamailio/kamailio.cfg

https://stackoverflow.com/questions/44612215/kamailiortpenginesip-js-failed-to-set-remote-answer-sdp-called-with-sdp-witho




https://github.com/caruizdiaz/kamailio-ws

	if ($ru =~ "transport=ws") {
		xlog("L_INFO", "Request going to WS");
		if(sdp_with_transport("RTP/SAVPF")) {
                        rtpengine_manage("force trust-address replace-origin replace-session-connection ICE=force");
                        t_on_reply("REPLY_WS_TO_WS");
                        return;
                }
                
#		rtpengine_manage("froc+SP");
		rtpengine_manage("force trust-address replace-origin replace-session-connection ICE=force RTP/SAVPF");
		t_on_reply("REPLY_FROM_WS");
	}
	else if ($proto =~ "ws") {
		xlog("L_INFO", "Request coming from WS");
#		rtpengine_manage("froc-sp");
		rtpengine_manage("force trust-address replace-origin replace-session-connection ICE=remove RTP/AVP");
		t_on_reply("REPLY_TO_WS");
	}
	else {
		xlog("L_INFO", "This is a classic phone call");
#	rtpengine_manage("co");
		rtpengine_manage("replace-origin replace-session-connection");
		t_on_reply("MANAGE_CLASSIC_REPLY");
	}