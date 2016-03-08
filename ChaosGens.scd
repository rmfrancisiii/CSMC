(
{ HenonN.ar(
    SampleRate.ir/128,
    LFNoise2.kr(1, 0.2, 1.2),
    LFNoise2.kr(1, 0.15, 0.15),
	0.5,
	4
) * 0.2 }.play(s);
)

(
{ Pan2.ar(Blip.ar(GbmanL.ar(FBSineN.ar(4)*LFNoise2.kr(1,8))*40)*0.4 )}.play(s);
)
