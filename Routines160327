s.boot;

(
var sb,freqData,seq;
sb=CtkSynthDef(\SineBank, {
	arg freq;
	var env,sin;
	env=Env([0,1,1,0], [0.5,16,7]);
	sin=SinOsc.ar(freq,0,0.03)*EnvGen.kr(env);
	Out.ar(0,Pan2.ar(sin));
}).send(s);

freqData=Array.fill(24,
	{arg i; 400+(i*(i+5.6))}).scramble;

seq=Task({
	loop({
   freqData.do({arg thisFreq, i;
		var aNote;
	aNote=sb.note(0.1, 24).freq_(thisFreq);
		aNote.play;
		(0.5+(i*0.1)).wait;
        });
	    });
              });
a=seq;
a.play;

)

(
var ps,freqData,seq;
ps=CtkSynthDef(\Pulsers, {
	arg freq;
	var env,blip;
	env=Env([0,1,1,0], [0.5,16,7]);
	blip=Blip.ar(freq,200,0.03)*EnvGen.kr(env);
	Out.ar(0,Pan2.ar(blip));
}).send(s);

freqData=Array.fill(24,
	{arg i; (i*(i+1))}).scramble;

seq=Task({
	loop({
   freqData.do({arg thisFreq, i;
		var aNote;
	aNote=ps.note(0.1, 24).freq_(thisFreq);
		aNote.play;
		(0.5+(24-i)).wait;
        });
	    });
              });
seq.play;

)



