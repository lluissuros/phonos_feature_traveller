/*
JSON Reading



NOTE for JSON load:

Both Yaml and JSON loaders will load the Json, but the original numbers will now be Strings. Maybe should raise an issue, but in any case be aware of this and parse it .asFloat or .asInteger
 ==> I think from the python side, there is also a requierement for numbers to by stringyfied...


provide object by_frame_id wth all caracteristics (easy acces, has codeword, embedding, most_similars, features, PCA, everything
 has maybe next_frame_id and previous_frame_id
)

other Hashmaps will have key: array[frame_id]
 * codewords
 * embeddings
 * cluster:
 * pitch:
 * any feature that I want



=================
EXAMPLE JSON:
{
    "all_alone.wav_f0": {
        "absolute_path": "/Users/lluissuros/Documents/Datasets/phonos_dataset/all_alone.wav",
        "end_sample": 4096,
        "loudness": 0.0,
        "mfcc_0": -1138.4200439453125,
        "mfcc_1": 1.1444091796875e-05,
        "mfcc_10": -2.6702880859375e-05,
        "mfcc_11": -3.0517578125e-05,
        "mfcc_12": -3.814697265625e-05,
        "mfcc_2": -6.103515625e-05,
        "mfcc_3": 8.0108642578125e-05,
        "mfcc_4": -6.103515625e-05,
        "mfcc_5": 2.288818359375e-05,
        "mfcc_6": -2.6702880859375e-05,
        "mfcc_7": -5.340576171875e-05,
        "mfcc_8": -4.57763671875e-05,
        "mfcc_9": -2.288818359375e-05,
        "next_frame_id": "all_alone.wav_f1",
        "previous_frame_id": "all_alone.wav_f1533",
        "scale": "major",
        "start_sample": 0,
        "track_id": "all_alone.wav",
        "word_1_nearest": 153,
        "word_2_nearest": 28,
        "word_3_nearest": 1
    },
(...)
}
=================


*/


(
// === FUNCTIONS ===
~load_json = {|filepath|
	var object;
	"parsing json into object, might take a while...".postln;
	object = filepath.parseYAMLFile(); //parses json into object
	"loaded !!".postln;
	object;
};


)


(
// == LOAD JSONS from python ===
var dir = Document.current.dir.asString;
var by_frame_id = dir ++"/files/by_frame_id.json";
var track_to_path = dir ++"/files/tracks_to_path.json";
var by_word = dir ++"/files/by_word.json";


{~by_frame_id = ~load_json.( by_frame_id )}.bench;
{~tracks_paths = ~load_json.( track_to_path )}.bench;
{~by_codeword = ~load_json.( by_word )}.bench;
)



(
/*
    === LOAD BUFFERS ===
We load from the provided json on the python side
*/

~buffers_by_id = Dictionary.new;

~tracks_paths.keys.do({ |key|
	var path = ~tracks_paths[key];
	var buffer = Buffer.readChannel(s, path, channels:[0]);
	~buffers_by_id.add(key -> buffer );
	postf(" % loaded... \n", key);
});

"\n ... ~buffers_by_id loading buffers complete, but wait a little:".postln;
)


~by_frame_id["spot1.wav_f1346"]

//tests:
~buffers_by_id
~by_codeword["0"]
{~by_frame_id["spot1.wav_f1346"]["track_id"]}.bench
~buffers_by_id[~by_frame_id["spot1.wav_f1346"]["track_id"]]


(
//tests
var trackId = ~by_frame_id["spot1.wav_f1346"]["track_id"];
var buf = ~buffers_by_id[~by_frame_id["spot1.wav_f1346"]["track_id"]];
var path = ~by_frame_id["all_alone.wav_f27"]["absolute_path"];
trackId = ~by_frame_id["all_alone.wav_f27"]["track_id"];
)


//more tests
~by_frame_id["spot1.wav_f1146"]["start_sample"] //test
~by_frame_id["spot1.wav_f1146"]["end_sample"] //test
~by_frame_id["spot1.wav_f1146"]["track_id"] //test track_id
~by_frame_id["spot1.wav_f12"]["next_frame_id"]
~by_frame_id["spot1.wav_f1146"]["absolute_path"] //test path

~by_frame_id["spot1.wav_f1146"]
~by_frame_id["spot1.wav_f1146"]["start_sample"]
~by_frame_id["spot1.wav_f1146"]["end_sample"]
~by_frame_id["spot1.wav_f1146"]["absolute_path"]
~buffers_by_id[~by_frame_id["spot1.wav_f1146"]["track_id"]].numFrames
~buffers_by_id[~by_frame_id["spot1.wav_f1146"]["track_id"]].sampleRate

~by_frame_id["spot1.wav_f1146"]["word_1_nearest"] //test codeword




(
//MORE POTENCIAL FUNCS

~getSimilarFrameId = {|frameId, nearest=1|
	var nearest_neighbour = "word_"++ nearest ++"_nearest";
	var codeWord = ~by_frame_id[frameId][nearest_neighbour];
	var index = ~by_codeword[codeWord].size.rand;
	var otherFrameId = ~by_codeword[codeWord][index];
	otherFrameId;
};

~getBuf = {|frameId|
	var trackId = ~by_frame_id[frameId]["track_id"];
	var buf = ~buffers_by_id[trackId];
	buf;
};

~getStartSample = {|frameId|
	~by_frame_id[frameId]["start_sample"].asFloat;
};

~getEndSample = {|frameId|
	~by_frame_id[frameId]["end_sample"].asFloat;
};

~getRandFrameId = {
	~by_frame_id.keys.asArray[~by_frame_id.keys.size.rand];
};

)





//test
~getSimilarFrameId.("spot1.wav_f1146")
~getRandFrameId.()
~getBuf.(~getSimilarFrameId.("spot1.wav_f1146", 3));





/*

==============================================================
PERFORM

 We only need now to provide the frames!
Remember to .asFloat, they come as strings...

TODO:
 * need a nicer, much less verbose approach to obtain frames

*/



(
//TODO change name: loopbuf smtg
// TODO: huge potential in changing startLoop and endLoop
//NOTE: nice to be in between small sample, and a little more when it becomes "music"
SynthDef(\simpleBufPlayer_frames, {
	arg buf=0, rate=1, sPos=0, endPos=10000,  amp=0.1, out=0, loop=0,
	atk=1.1, sus=0.3, rel=1.1;
	var sig, env;
	env = EnvGen.kr(Env([0,1,1,0],[atk,sus,rel],[1,0,-1]),doneAction:2);
	sig = LoopBuf.ar(
		1, buf,
		rate: rate + LFNoise1.ar(0.1, 0.01, 0.005).poll,
		startPos:sPos,
		startLoop:sPos,
//		endLoop:endPos + SinOsc.ar(30,0, 10, 5),
		endLoop:endPos + LFNoise1.ar(0.01, 10000, 10000),
		interpolation:2);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;

)








~currentFrameId = "spot1.wav_f1146";
~currentFrameId = "all_alone.wav_47";
~getStartSample.(~currentFrameId)
~getBuf.("spot1.wav_f1346")
~getBuf.(~currentFrameId)
~getBuf.(~getByCodeword.(~currentFrameId))


(
~currentFrameId = "spot1.wav_f1146"; //init

Pbindef(\testPlayer,
	\instrument, \simpleBufPlayer_frames,
	\buf, Pfuncn({
		~currentFrameId = ~getByCodeword.(~currentFrameId); // change currentFrame
		//~currentFrameId.postln;
		~getBuf.(~getByCodeword.(~currentFrameId));
	}, inf),
	\out, Pseq([-1, 0, 1], inf),
	\dur, Pseq([1] ,inf),
	\amp, Pseq([0.5, 0.2, 0.8]/5, inf),
	\atk, 1,
	\sus, 7,
	\rel, 1,
	\loop, 0,
//	\sPos, ~getStartSample.(~currentFrameId) + Pbrown(0,30000,10000, inf),
//	\endPos, ~getEndSample.(~currentFrameId) + Pbrown(0,1000000,30000, inf),
	\sPos, ~getStartSample.(~currentFrameId),
	\endPos, ~getEndSample.(~currentFrameId),
);

)

Pbindef(\testPlayer).play;
Pbindef(\testPlayer).stop;


11.1.class

11.isInteger
"11.1".asFloat
~by_frame_id["spot1.wav_f1146"]["start_sample"].asFloat


~by_frame_id



s.record
s.stopRecording

