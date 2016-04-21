s = Server.default;
s.boot;

(

var root = 100.0;
var beatLength = 5.0;
var sectionLength = 500.0;
var partials = [[1.0, 1.0],  [1.25, 0.75], [1.5, 0.5]];
var scale = [1/1,5/4,3/2,7/4,11/8,13/8,17/16,19/16];
var prob = 0.5;

var phasemod = CtkSynthDef(\myNote, {arg freq, mod, dur, amp, pan;
	var pm, env;
	env = EnvGen.kr(Env([0.001, 0.99, 0.001], [0.75, 0.25], [\sin, \sin]), doneAction: 0, timeScale: dur);
	pm = SinOsc.ar(freq, SinOsc.ar(XLine.kr(20, 100, 9), 0, 2pi), 0.25);

	Out.ar(0, Pan2.ar(pm * env, pan));
}).send(s);


// wrap section with passage
sectionLength.do({arg o;
var	routine = Routine.new({(o*beatLength).wait;
		scale.do({arg thisNote, i;

			// Todo:  insert sampling of Ard values

			if (prob.coin, {
				partials.do({arg thisPart, u;
					var aNote, randPan, randAmp, noteLength;
					randPan = rrand(-1.0, 1.0);
					randAmp = rrand(0.01, 0.25);
					noteLength = rrand(beatLength/2.0, beatLength*2.0);
					aNote = phasemod.note(0.0, noteLength).freq_(root*thisNote*thisPart[0]).dur_(thisPart[1]*noteLength).amp_(randAmp).pan_(randPan);
					aNote.play;
				});
			});
		});
	});
	routine.play;

});

)

s.quit;

