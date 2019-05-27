/*BandSplitter2, 4, or 8!
Splits a signal into bands
I could then direct it to multichannel, or process it.
*/


/*
Download and try Supersampler quark
*/

/*
Try Bjorklund quark in multichannel?
*/

/*
Check Dmand, which gets new values of patterns by a trigger
*/


//The Select or SelectXFocus can be interesting way of travelling when many wanting to move between many sounds
(
{
    var arr;
    arr = [
		SinOsc.ar(400),
		SinOsc.ar(600),
		SinOsc.ar(900),
		PinkNoise.ar() * Decay.ar(Impulse.ar(1), 0.5)
        ];
    SelectXFocus.ar(LFNoise2.ar(1) * arr.size, arr, 1, true) * 0.2
}.play;
)

