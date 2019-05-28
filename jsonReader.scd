/*
JSON Reading

check JSON object as well

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
var path = ~by_frame_id["spot1.wav_f1146"]["absolute_path"];
var buf = Buffer.readChannel(s, path, channels:[0]);
~testDict = ();
~testDict[~by_frame_id["spot1.wav_f1146"]["track_id"]] = buf;
//~addBuffersToDict.()

)

~by_frame_id["spot1.wav_f1146"]["start_sample"] //test
~by_frame_id["spot1.wav_f1146"]["track_id"] //test
~by_frame_id["spot1.wav_f1146"]["absolute_path"] //test



/*
TODO how to specify a particular frame as sPos

1 - I think buffer without BufRateScale should do, and startPos

*/


SynthDef(\simpleBufPlayer_frames, {
	arg buf=0, rate=1, sPos=0, endPos=10000,  amp=0.1, out=0, loop=0,
	atk=1.1, sus=0.3, rel=1.1;
	var sig, env, trigger;
	var loopFreq = (BufSampleRate.ir(buf) / endPos-sPos);
	var trig = Impulse.kr(loopFreq); // THE TRIG IS THE PROBLEM NOW
	trig = Impulse.kr(2.0);
	//loopFreq.poll;
	env = EnvGen.kr(Env([0,1,1,0],[atk,sus,rel],[1,0,-1]),doneAction:2);
	sig = PlayBuf.ar(1, buf, rate, trig, startPos:sPos, loop:loop);
	//test trig
	Out.ar([sig, trig], Mix.ar(sig*env*amp));
}).add;


//
~by_frame_id["spot1.wav_f1146"]["start_sample"]
~by_frame_id["spot1.wav_f1146"]["end_sample"]
~testDict[~by_frame_id["spot1.wav_f1146"]["track_id"]].numFrames
~testDict[~by_frame_id["spot1.wav_f1146"]["track_id"]].sampleRate



Pbindef(\testPlayer,
	\instrument, \simpleBufPlayer_frames,
	\buf, ~testDict[~by_frame_id["spot1.wav_f1146"]["track_id"]],
	\out, 0,
	\dur, Pseq([1] ,inf).trace,
	\amp, Pseq([0.5, 0.2, 0.8]/5, inf),
	\atk, 1,
	\sus, 2,
	\rel, 3,
	\loop, 1,
	\sPos, ~by_frame_id["spot1.wav_f1146"]["start_sample"], //NEED CONVERT TO NUMBER
	\endPos, ~by_frame_id["spot1.wav_f1146"]["end_sample"] , //NEED CONVERT TO NUMBER
);

Pbindef(\testPlayer).play;


s.record
s.stopRecording