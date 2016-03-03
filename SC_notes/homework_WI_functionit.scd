{\rtf1\ansi\ansicpg1252\cocoartf1038\cocoasubrtf360
{\fonttbl\f0\fnil\fcharset0 Monaco;\f1\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;\red0\green0\blue191;\red0\green115\blue0;}
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\ql\qnatural\pardirnatural

\f0\fs18 \cf0 (\
\cf2 var\cf0  routebus, src, score;\
\cf2 var\cf0  filter, filter2, src2;\
\cf2 var\cf0  inc, time;\
\cf2 var\cf0  sourceFunction, filterFunction;\
\cf2 var\cf0  routineSF1, routineFF1;\
\cf2 var\cf0  mainRoutine;\
\cf2 var\cf0  freqEnv, freqEnv2, varEnv, waitEnv;\
\
\cf2 Server\cf0 .default = s = \cf2 Server\cf0 .internal.boot;\
\
s.scope;\
f = \cf2 FreqScope\cf0 .new;\
\
a = s.options.numOutputBusChannels;\
b = s.options.numInputBusChannels;\
c = s.options.numAudioBusChannels;\
\
\
a = \cf2 CtkAudio\cf0 .new(server: s);\
\
src = \cf2 CtkSynthDef\cf0 (\cf3 \\src\cf0 , \{\cf2 arg\cf0  outbus, freq, numharms, pan;\
	\cf2 Out\cf0 .ar(outbus, \cf2 Pan2\cf0 .ar(\cf2 Blip\cf0 .ar(freq, numharms, 0.1), pan))\
	\
\});\
\
filter = \cf2 CtkSynthDef\cf0 (\cf3 \\filter\cf0 , \{\cf2 arg\cf0  inbus, pan, noteDur, amp = 1, springer;\
	\cf2 var\cf0  src, filter, env;\
	src = \cf2 In\cf0 .ar(inbus);\
	env = \cf2 EnvGen\cf0 .kr(\
		\cf2 Env\cf0 ([0, 0.8, 0.8, 0], [0.001, 0.8, 0.001].normalizeSum, \cf3 \\sin\cf0 ),\
		timeScale: noteDur);\
	filter = 
\f1\fs24 \cf2 Friction\cf0 .ar(src, friction: 5.41322e-5, mass: 8.05501, spring: (springer))
\f0\fs18 ;\
	filter = \cf2 Balance\cf0 .ar(filter, src, 20);\
	\cf2 Out\cf0 .ar(0, \cf2 Pan2\cf0 .ar(filter * env * amp, pan))\
\});\
\
freqEnv = \cf2 Env\cf0 ([1120, 200, 6000, 300], [1, 2, 1].normalizeSum, \cf3 \\lin\cf0 );\
waitEnv = \cf2 Env\cf0 ([1, 0.001], [1].normalizeSum, \cf3 \\lin\cf0 );\
\
freqEnv2 = \cf2 Env\cf0 ([100, 200, 100, 300, 100, 1201, 400, 100, 500, 100, 400, 100, 4301, 300, 100, 200], [1, 2, 1, 2, 1, 3, 4, 5, 1, 5, 6, 7, 1, 2, 1].normalizeSum, \cf3 \\lin\cf0 );\
\
	sourceFunction = \{\cf2 arg\cf0  thisBus, thisFreq, thisNumharms, thisPan, thisDur;\
		\cf2 var\cf0  myBus;\
		myBus = a;\
			src.note(0.0, thisDur)\
			.outbus_(myBus)\
			.freq_(thisFreq)\
			.numharms_(thisNumharms)\
			.pan_(thisPan).play;\
	\};\
\
	filterFunction = \{\cf2 arg\cf0  thisBus, thisPan, thisDur, thisAmp, thisSpringer, targetNumb;\
		\cf2 var\cf0  myBus;\
		myBus = a;\
			filter.note(0, thisDur, addAction: \cf3 \\tail\cf0 , target: targetNumb)\
			.inbus_(myBus)\
			.pan_(thisPan)\
			.noteDur_(thisDur)\
			.amp_(thisAmp)\
			.springer_(thisSpringer).play\
	\};\
	\
	routineSF1 = \{\cf2 arg\cf0  numNotes, waitEnv;\
		  \cf2 Routine\cf0 \{\
		  numNotes.do(\{\cf2 arg\cf0  i;\
		  	sourceFunction.value(a, 3456.23, 11, 0, waitEnv[i/numNotes]);\
			waitEnv[i/numNotes].wait;\
		  \})\
		  \}\
	\};\
\
	routineFF1 = \{\cf2 arg\cf0  numNotes, trig;\
		  \cf2 Routine\cf0 \{\
		  numNotes.do(\{\cf2 arg\cf0  i;\
		  	filterFunction.value(a, 0, 13, 1.dbamp, 0.08, trig);\
			100.wait;\
		  \})\
		  \}\
	\};\
	\
	mainRoutine = \cf2 Routine\cf0 .run(\{\
			routineSF1.value(1, waitEnv).play;\
			routineFF1.value(1, 1).play;\
			\
	\});\
)\
}