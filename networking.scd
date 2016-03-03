/*
==========================================================
DX490a - Summer 2010
		Instructor: Stelios Manousakis
==========================================================
Class 16.1:
	Networking 2: Communication within a Local-Area-Network (LAN)
		Contents:
			• Connecting
			• A simple example
			• An example with sound
			• Troubleshooting
			• Additional networking quarks
				- iPhone/iPodTouch/iPad
==========================================================
*/


// ================= SUPERCOLLIDER IN LOCAL-AREA-NETWORKS =================


// As  we have seen in the Networking-1 class (10.2), NetAddr is the core object for handling networking between different applications within a computer. This is also the case for connecting two computers via LAN. (Note however that NetAddr is no good for Internet connections! More on that on the next example file).

// NOTE: This examples in this file need at least two computers!




// ====== CONNECTING ======

// The connection process requires working on more than one machines simultaneously. I will be pointing out which machine you need to work with by writting local/remote.


// • Step 1: LOCAL & REMOTE
//	Make sure your Firewalls are off in both machines


// • Step 2: LOCAL
//	Create a Local-Area-Network (sometimes referred to as ad-hoc network) with one of the available machines


// • Step 3: REMOTE
//	Connect other computers to this particular LAN.


// • Step 4: LOCAL & REMOTE
// 	Create a new NetAddr; you can use the computer's IP address as an argument for the NetAddr object, OR, you can use the name of the specific computer to log into it from a remote machine, appending ".local". For example, my computer's name is "stm", so I can log in like this:

	NetAddr("stm.local", 57120)
// Note that you need to use the current sclang port as the port argument  (by default set to 57120).
	NetAddr.langPort; // retrieve the current port SC is listening to

// So:
// connect LOCAL to the remote machine:
~remoteComp = NetAddr("128.95.92.193", 57120);  // 57120 is sclang default port, use it to send to a remote sclang
// do the same from the remote machine, using the local machine's IP or name


// • Step 5: LOCAL & REMOTE
//	Create an OSCresponder. The one below is just for testing, so it only prints out what it received.
r = OSCresponder(~remoteComp, 'stmIncoming', { arg time, resp, msg;
	[time, msg[1]].postln;
	}).add;


// • Step 6: LOCAL & REMOTE
// 	test by manually sending a message to the other computer. After creating an OSCresponder called 'dxlab8' on the remote machine you can send it this message.
~remoteComp.sendMsg('dxlab8', "did my message arrive?", 0.5);

// Similarily, you can send a message to this machine like this:
	~remoteComp.sendMsg('stmIncoming', "did my message arrive?", 0.5);


// now, remove the responder to try something a bit more involved:
r.remove




// ====== A SIMPLE EXAMPLE: LOCAL ======

// In this simple example, we will create a GUI interface with two knobs, one to send data to a remote machine, and one to receive.

// 1. connecting:
~remoteComp = NetAddr("169.254.144.182", 57120); // replace the IP ("Tesla.local") with the IP or name of the machine you want to connect to

// 2. making a responder for receiving
r = OSCresponder(~remoteComp, 'stmIncoming', { arg time, resp, msg;
	[time, msg[1]].postln;
	{~recKnob.value_(msg[1])}.defer;
	}).add;


// 3. Making a GUI window with a knob to send, and a knob to receive:
(
var window = Window.new("Networking test",Rect(318, 456, 400, 400)).front;
~recKnob = Knob.new(window,Rect(175, 205, 217, 189))
	.action_{|v| };
~sendKnob = Knob.new(window,Rect(8, 11, 216, 188))
	.action_{|v|
		~remoteComp.sendMsg('dxlab8', v.value); // << action: sending to remote machine
		};
StaticText.new(window,Rect(24, 333, 148, 50))
	.string_("Receive some data -->>");
StaticText.new(window,Rect(229, 15, 130, 47))
	.string_("<<-- Send some data");
)

/* Now, do the same in the remote machine, replacing in:
1. the IP of the receiving machine to the IP of this one
2. the cmdName of the OSCresponder to the name you're using in (3)
3. Replace the name you're using in (3) with the name you use in (2)
*/

// Don't forget to remove your responder once you're done!
r.remove



// ====== AN EXAMPLE WITH SOUND: LOCAL ======
// In this simple example, we will create the same GUI interface with two knobs, except this time the 'sending' knob will get data from analysis of the sound in the local machine, and will send the data to the remote machine to affect the synthesis there - and vice versa.

// • Synthesis: a self-phase-modulated Sinewave, with analysis to show how noisy it is:

s.boot;

(
~mult = 4;
// buffer for FFT
~buf = Buffer.alloc(s,2048,1);
// the synthdef
~fdbFM = CtkSynthDef(\fdbSine, {arg freq, fdbAmt, amp, pollFreq = 2, gate = 1;
	var sine, mod, fdbIn, fdbOut, env, chain, flatness;
	fdbIn = LocalIn.ar(1);
	env = EnvGen.kr(Env.new([0.00001, 1, 1, 0.00001], [0.05, 0.9, 0.5], [\exp, \sin], 1), gate,  doneAction: 2);
	mod = fdbIn * fdbAmt;
	sine = SinOsc.ar(freq, mod, amp); // fdb phase modulation
	chain = FFT(~buf, sine);
	flatness = SpecFlatness.kr(chain);
	SendReply.kr(Impulse.kr(pollFreq), 'flatness', flatness);
	Out.ar(0, sine * env);
	fdbOut = LocalOut.ar(sine);
})
);

// 1. connecting:
~remoteComp = NetAddr("169.254.144.182", 57120); // replace the IP ("Tesla.local") with the IP or name of the machine you want to connect to

// 2. making a responder for receiving
r = OSCresponder(~remoteComp, 'stmIncoming', { arg time, resp, msg;
	[time, msg[1]].postln;
	{~recKnob.value_(msg[1])}.defer;
	~note.fdbAmt_(msg[1] * ~mult + 1)
	}).add;


// 2a. making a responder for receiving from the analysis data from the synthdef, and moving the knob
~noisiness = OSCresponder(~remoteComp, 'flatness', { arg time, resp, msg;
	msg[3].postln;
	{~sendKnob.valueAction_(msg[3])}.defer; // naturally, it would be more efficient to send the message directly to the remote server, this is just for demonstration purposes...
	}).add;


// 3. Making a GUI window with a knob to send, and a knob to receive:
(
var window = Window.new("Networking test",Rect(318, 456, 400, 400)).front;
~recKnob = Knob.new(window,Rect(175, 205, 217, 189))
	.action_{|v| };
~sendKnob = Knob.new(window,Rect(8, 11, 216, 188))
	.action_{|v|
		~remoteComp.sendMsg('dxlab8', v.value); // << action: sending to remote machine
		};
StaticText.new(window,Rect(24, 333, 148, 50))
	.string_("Receive some data -->>");
StaticText.new(window,Rect(229, 15, 130, 47))
	.string_("<<-- Send some data");
)



~note = ~fdbFM.new().freq_(160).fdbAmt_(5.5).amp_(0.5).play
// change some numbers
~note.freq_(124)
~note.fdbAmt_(5.4)
~note.fdbAmt_(1244)
~mult = 4.6
~note.pollFreq_(2.6)
~note.release


// remove the responders
r.remove;
~noisiness.remove;





// ====== TROUBLESHOOTING ======

/* ATTENTION: IF THE ABOVE DOESN'T WORK, TRY TO RESET THE FOLLOWING:
- NetAddr ip (IPs may have changed and you may be using an older one)
- disconnect/reconnect to LAN (that has worked many times for me in the past...)
- relaunch SC (maybe something is hanging from before)
*/


// You can use the code below to troubleshoot, and see if there is anything coming in:
(
thisProcess.recvOSCfunc = { |time, addr, msg|
	if(msg[0] != 'status.reply') {
		"time: % sender: %\nmessage: %\n".postf(time, addr, msg);

	}
}
);

// stop posting.
thisProcess.recvOSCfunc = nil;




// ====== ADDITIONAL NETWORKING QUARKS ======

// NetLib is a very nice, small experimental library for collaborative network ensembles
// Republic is a class taking over some of the administrational burdens of organizing LAN group performances
// ListeningClocks 3 clocks that can communicate with other clocks for synchronizing performances over several computer in a nework


// ------ iPhone/iPodTouch/iPad --
// Connecting to an iThing is a very similar process, except the fact that you need a dedicated environment for sending OSC messages from the portable device. Until there is an official port of SC for iThings, a couple (free) examples include the mrmr App and rjdj.

// • Mrmr
// With mrmr you can create interfaces and control SC remotely. There is a quark that lets you create those interfaces from your computer, and which handles some of burdens of communication internally.
Quarks.install( "Mrmr", checkoutIfNeeded: false)
// The helpfile is pretty much all you need to get started

// • rjdj
// rjdj is a port of PureData for the iPhone/iPodTouch. There is also an iPad version, called rjVoyager. What is nice about it is that you can create Pd patches in your computer and load them to the portable device. This is probably worse for using as a controller of a remote machine as there are less GUI widgets, but you can actually do part of the processing in the portable device, and even make sounds with it!

