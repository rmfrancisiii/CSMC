// sample modal drone
// james watkins
// 29.12.2015

/*



*/

(
s = Server.default;
ServerOptions.devices;
s.options.device_("JackRouter");
s.boot;
 )


(
var sd, root, scale, partials, tonic, times, beatLength, phraseLength,  sectionLength, prob, routine;
thisThread.randSeed = 200;


// section
root = 100.0;
beatLength = 5.0;
sectionLength = 100.0;

partials = [[1.0, 1.0],  [1.25, 0.75], [1.5, 0.5]];
scale = [1/1,5/4,3/2,7/4,11/8,13/8,17/16,19/16];
prob = 0.5;

sd = CtkSynthDef(\myNote, {arg freq, dur, amp, pan;
	var sin, env, envGen;
	env = Env([0.001, 0.99, 0.001], [0.75, 0.25], [\sin, \sin]);
	envGen = EnvGen.kr(env, doneAction: 0, timeScale: dur);
	sin = SinOsc.ar(freq, 2, amp);
	Out.ar(0, Pan2.ar(sin * envGen, pan));
}).send(s);



sectionLength.do({arg o;
	routine = Routine.new({(o*beatLength).wait;
		scale.do({arg thisNote, i;

			// Todo:  insert sampling of Ard values

			if (prob.coin, {
				partials.do({arg thisPart, u;
					var aNote, randPan, randAmp, noteLength;
					randPan = rrand(-1.0, 1.0);
					randAmp = rrand(0.01, 0.25);
					noteLength = rrand(beatLength/2.0, beatLength*2.0);
					aNote = sd.note(0.0, noteLength).freq_(root*thisNote*thisPart[0]).dur_(thisPart[1]*noteLength).amp_(randAmp).pan_(randPan);
					aNote.play;
				});
			});
		});
	});
	routine.play;

});

)



s.quit;

