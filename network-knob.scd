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


NetAddr("river.local", 57120)
// Note that you need to use the current sclang port as the port argument  (by default set to 57120).
	NetAddr.langPort; // retrieve the current port SC is listening to

// So:
// connect LOCAL to the remote machine:
~robert = NetAddr("192.168.0.106", 57120);  // 57120 is sclang default port, use it to send to a remote sclang

~jeff = NetAddr("192.168.0.104", 57120);  // 57120 is sclang default port, use it to send to a remote sclang

~jason = NetAddr("192.168.0.101", 57120);  // 57120 is sclang default port, use it to send to a remote sclang


r = OSCresponder(~james, 'james', { arg time, resp, msg;
    [time, msg[1]].postln;
    {~recKnob.value_(msg[1])}.defer;
    ~note.fdbAmt_(msg[1] * ~mult + 1)
    }).add;


// 2a. making a responder for receiving from the analysis data from the synthdef, and moving the knob
~noisiness = OSCresponder(~james, 'flatness', { arg time, resp, msg;
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
        ~robert.sendMsg('robert', v.value); // << action: sending to remote machine
        ~jeff.sendMsg('jeff', v.value); // << action: sending to remote
};
StaticText.new(window,Rect(24, 333, 148, 50))
    .string_("Receive some data -->>");
StaticText.new(window,Rect(229, 15, 130, 47))
    .string_("<<-- Send some data");
)

s.boot;

~note = ~fdbFM.new().freq_(160).fdbAmt_(5.5).amp_(0.5).play
// change some numbers

~note.freq_(11)
~note.fdbAmt_(5.7)
~note.fdbAmt_(1244)
~mult = 4.6
~note.pollFreq_(2.6)
~note.release

~robert.sendMsg('robert', 3000)

// remove the responders
r.remove;
~noisiness.remove;