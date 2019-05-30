/*
JSON Reading



NOTE for JSON load:

Both Yaml and JSON loaders will load the Json, but the original numbers will now be Strings. Maybe should raise an issue, but in any case be aware of this and parse it .asFloat or .asInteger


provide object by_frame_id wth all caracteristics (easy acces, has codeword, embedding, most_similars, features, PCA, everything
 has maybe next_frame_id and previous_frame_id
)

other Hashmaps will have key: array[frame_id]
 * codewords
 * embeddings
 * cluster:
 * pitch:
 * any feature that I want


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


//from playAllSoundsFromFolder.scd
~addBuffersToDict= { |folderPath, soundsDict|
	var soundFilePaths = (folderPath +/+ "*").pathMatch;
	var buffers = soundFilePaths.collect({|path| Buffer.readChannel(s, path, channels:[0]) });
	postf("  \n ... loading % subfolder: \n", folderPath.folderName);

	buffers.do({|buf|
		// like this, it has easy acces such as ~soundsDict[9000]
		var key = soundsDict.size;
		soundsDict.add(key -> buf ) });
};
)

(
// == LOAD JSON ===
var dir = Document.current.dir.asString;
var by_frame_id_path = dir ++"/files/by_frame_id.json";

// TODO: create a json with the filepaths, and load the buffers
// ==> look at granulizer
//var tracks_paths = dir ++"/files/by_frame_id.json";


{~by_frame_id = ~load_json.( by_frame_id_path )}.bench;

// === LOAD BUFFERS ===

)





(
//test Buffer
var trackId = ~by_frame_id["spot1.wav_f1346"]["track_id"];
var path = ~by_frame_id["spot1.wav_f1346"]["absolute_path"];
var buf = Buffer.readChannel(s, path, channels:[0]);

//TODO: need all track_ids to build a Buffer dictionary, from all_tracks json

~testDict = Dictionary.new();
~testDict[trackId] = buf;
//~addBuffersToDict.()

trackId = ~by_frame_id["all_alone.wav_f27"]["track_id"];
path = ~by_frame_id["all_alone.wav_f27"]["absolute_path"];
buf = Buffer.readChannel(s, path, channels:[0]);
~testDict[trackId] = buf;
//... and so on

)


~testDict

//tests
~by_frame_id["spot1.wav_f1146"]["start_sample"] //test
~by_frame_id["spot1.wav_f1146"]["end_sample"] //test
~by_frame_id["spot1.wav_f1146"]["track_id"] //test
~by_frame_id["spot1.wav_f1146"]["absolute_path"] //test



~by_frame_id["spot1.wav_f12"]["track_id"]


(
/*
test how an array of bag-of-features would work:
*/

~testByCodeword = Dictionary.new();
~testByCodeword["c1"] = ["spot1.wav_f1146" , "spot1.wav_f1346", "spot1.wav_f142", "spot1.wav_f12", "all_alone.wav_f27", "all_alone.wav_f47"];
)

~testByCodeword["c1"]




~by_frame_id["spot1.wav_f1146"]
~by_frame_id["spot1.wav_f1146"]["start_sample"]
~by_frame_id["spot1.wav_f1146"]["end_sample"]
~by_frame_id["spot1.wav_f1146"]["absolute_path"]
~testDict[~by_frame_id["spot1.wav_f1146"]["track_id"]].numFrames
~testDict[~by_frame_id["spot1.wav_f1146"]["track_id"]].sampleRate
~testDict["spot1.wav_f1146"]






(
//MORE POTENCIAL FUNCS

~getByCodeword = {|frameId|
	// ~by_frame_id[frameId]["codeword"] NOT AVAILABLE YET
	var mockCodeword = "c1"; //see above
	var index = ~testByCodeword["c1"].size.rand;
	var otherFrameId = ~testByCodeword[mockCodeword][index];
	otherFrameId;
};

~getBuf = {|frameId|
	var trackId = ~by_frame_id[frameId]["track_id"];
	var buf = ~testDict[trackId];
	buf;
};

~getStartSample = {|frameId|
	~by_frame_id[frameId]["start_sample"].asFloat;
};

~getEndSample = {|frameId|
	~by_frame_id[frameId]["end_sample"].asFloat;
};

)






//test
~getByCodeword.("spot1.wav_f1146")
~getBuf.(~getByCodeword.("spot1.wav_f1146")); //NEED TO CREATE PROPER DICTIONRY FOR BUFFERS!!






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

