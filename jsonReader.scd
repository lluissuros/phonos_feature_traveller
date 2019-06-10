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

o = Server.local.options;
o.numBuffers
o.numBuffers = 10500;
s.boot;



(

// == LOAD JSONS from python ===
var dir = Document.current.dir.asString ++ "/files";
var by_frame_id = dir ++ "/by_frame_id.json";
var track_to_path = dir ++ "/tracks_to_path.json";
var by_word = dir ++ "/by_word.json";

var load_json = {|filepath|
	var object;
	"parsing json into object, might take a while...".postln;
	object = filepath.parseYAMLFile(); //parses json into object
	"loaded !!".postln;
	object;
};



{d = load_json.( by_frame_id )}.bench;
{~tracks_paths = load_json.( track_to_path )}.bench;
{~by_codeword = load_json.( by_word )}.bench;


/*
    === LOAD BUFFERS ===
We load from the provided json on the python side
*/

~buffers_by_id = Dictionary.new;

// {~tracks_paths.keys.do({ |key|
// 	var path = ~tracks_paths[key];
// 	var buffer = Buffer.readChannel(s, path, channels:[0]);
// 	~buffers_by_id.add(key -> buffer );
// 	postf(" % loaded... \n", key);
// 	});
// }.bench;

"\n ... ~buffers_by_id loading buffers complete, but wait a little:".postln;
)

~buffers_by_id.keys.size





//TODO delete tests
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
var path = ~by_frame_id["spot1.wav_f1346"]["absolute_path"];
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
~buffers_by_id[~by_frame_id["spot1.wav_f1146"]["track_id"]]
~buffers_by_id[~by_frame_id["spot1.wav_f1146"]["track_id"]].sampleRate
~buffers_by_id["233014.wav"]
~by_frame_id["233014.wav_f1"]
~updateCurrent.("233014.wav_af4"); //breaks

~by_frame_id["spot1.wav_f1146"]["word_1_nearest"] //test codeword
~by_frame_id["spot1.wav_f1146"]["previous_frame_id"]




(
//MORE POTENCIAL FUNCS

~getSimilarFrameId = {|frameId, nearest=1|
	var nearest_neighbour = "word_"++ nearest ++"_nearest";
	var codeWord = ~by_frame_id[frameId][nearest_neighbour];
	var index = ~by_codeword[codeWord].size.rand;
	var otherFrameId = ~by_codeword[codeWord][index];
	codeWord.postln;
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
	var frame_id = ~by_frame_id.keys.asArray[~by_frame_id.keys.size.rand];
	//frame_id.postln;
	frame_id
};

~getNextFrameId = {|frameId, numberFrames=1|
	/* will give the n-further away frame id */
	Array.newClear(numberFrames).inject( frameId, { |acc, idx|
	~by_frame_id[acc]["next_frame_id"];
});
};

~getPreviousFrameId = {|frameId, numberFrames=1|
	/* will give the n-further away frame id */
	Array.newClear(numberFrames).inject( frameId, { |acc, idx|
	~by_frame_id[acc]["previous_frame_id"];
});
};


~updateCurrent = { |frameId|
	/*updates dictionary like ~current{frameId, buf, etc}
	*/
	var newCurrentDict = Dictionary.new;
	newCurrentdict[""frameId"] = frameId;
	newCurrentdict[""buf"] = ~getBuf.(frameId);
	newCurrentdict[""startFrame"] = ~getStartSample.(frameId);
	newCurrentdict[""endFrame"] = ~getEndSample.(frameId);

	~current = newCurrentDict;
};

)





//test
~getSimilarFrameId.("spot1.wav_f1146")
~getNextFrameId.("spot1.wav_f1146", 3)
~getPreviousFrameId.("spot1.wav_f1146", 3)
~getRandFrameId.()
~getBuf.(~getSimilarFrameId.("spot1.wav_f1146", 3));





/*

==============================================================
PERFORM

-We only need now to provide the frames!
-Remember to .asFloat for end_sample or start_sample or any numerical, they come as strings...

------
TODO:
* need a nicer, much less verbose approach to obtain frames
* to parse all start_frames end_frames .asFloat when charging(will it take ages?)
* nice potential in changing startLoop and endLoop
* nice to be in between small sample, and a little more when it becomes "music", nice artifacts
----

*/



(
SynthDef(\loopPlayer, {
	arg buf=0, rate=1, sPos=0, endPos=10000,  amp=0.1, out=0, loop=0, pan=0,
	atk=1.1, sus=0.3, rel=1.1;
	var env = EnvGen.kr(Env([0,1,1,0],[atk,sus,rel],[1,0,-1]),doneAction:2);
	var offset = LFNoise1.ar(0.1, 10000, 10000);
	var sig = LoopBuf.ar(
		1, buf,
		rate: (rate + LFNoise0.ar(0.1, 0.01, 0.005)) * (-1),
		startPos:sPos,
		startLoop:sPos,
//		endLoop:endPos + SinOsc.ar(30,0, 10, 5),
		endLoop:endPos + offset,
		interpolation:2);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;


//INIT
~coolFrames = ["spot1.wav_f1146","fa_bats.wav_f11556", "ens_quedem.wav_f572", "spot1_lower.wav_f267", "spot1_lower.wav_f586", "fostercare.wav_f653", "fostercare.wav_f1675", "spot4.wav_f121", "ens_quedem.wav_f724", "ens_quedem.wav_f653", "feedbackchords.wav_f1135", "Galaxies Humanely Vinegar.wav_f582", "feedbackchords.wav_f395"];

~updateCurrent.(~coolFrames[1]);
)







(
Pbindef(\loopPlayer1,
	\instrument, \loopPlayer,
	\buf, Pfuncn({~current["buf"]},inf),
	\out, Pseq([-1, 0, 1], inf),
	\test, 0,
	\amp, Pseq([0.5, 0.2, 0.8]/5, inf),
	\atk, Pbrown(1, 4, 0.0125, inf),
	\sus, Pbrown(1, 3, 0.0125, inf),
	\rel, Pbrown(1, 3, 0.0125, inf),
	\dur, Pwhite(0.05, 0.2, inf) * ( Pkey(\atk) + Pkey(\sus) + Pkey(\rel)),
	\getStart, Pfuncn({~current["startFrame"]}, inf), //need to get like this
	\getEnd, Pfuncn({~current["endFrame"]}, inf), //need to get like this to Pkey
	\offsetStart, Pbrown(0,300000,10000, inf),
	\offsetEnd,   Pbrown(0,1000000,30000, inf),
	\sPos, Pkey(\getStart) + Pkey(\offsetStart),
	\endPos, Pkey(\getEnd) + Pkey(\offsetEnd),
);

)

Pbindef(\loopPlayer1).play;
Pbindef(\loopPlayer1).stop;


~updateCurrent.(~coolFrames[11]);


(
// ==================
//FUNCTIONS TO CHANGE BUF and FRAMES
// ==================

~setRandBuf = {
	var frameId = ~getRandFrameId.();
	~updateCurrent.(frameId);
};

~setRandSameWord = {
	var frameId = ~getSimilarFrameId.(~current["frameId"]);
	//frameId.postln;
	~updateCurrent.(frameId);
};


)


~setRandBuf.();
~setRandSameWord.();



(
//generates over similars on current Frame
~similar1 = Task({
	/*generates over similars on current Frame*/
	var init_frame = ~current["frameId"];
	var frames_simcodes = (0..5).inject( [init_frame], { |acc, idx|
		var nearest = 1;
		var newFrame = ~getSimilarFrameId.(acc[idx], nearest);
		acc.add(newFrame);
	});

	frames_simcodes = frames_simcodes.scramble;
	frames_simcodes = frames_simcodes.pyramid(3);

	10.do({ arg i;
		var frameId = frames_simcodes.wrapAt(i);
		var waitTime = ((1..10)/2).choose;
		"SIM1".postln;
		~updateCurrent.(frameId);
		waitTime.wait;
    });

	"SIMILAR 1 TASK FINISHED".postln;
});

~similar2 = Task({
	/*generates over similars on current Frame*/
	var init_frame = ~current["frameId"];
	var frames_simcodes = (0..5).inject( [init_frame], { |acc, idx|
		var nearest = [1,2].wchoose([0.3,0.7].normalizeSum);
		var newFrame = ~getSimilarFrameId.(acc[idx], nearest);
		acc.add(newFrame);
	});

	frames_simcodes = frames_simcodes.scramble;
	frames_simcodes = frames_simcodes.pyramid(3);

	10.do({ arg i;
		var frameId = frames_simcodes.wrapAt(i);
		var waitTime = ((1..10)/2).choose;
		"SIM2".postln;
		~updateCurrent.(frameId);
		waitTime.wait;
    });

	"SIMILAR 2 TASK FINISHED".postln;
});


~similar3 = Task({
	/*generates over similars on current Frame*/
	var init_frame = ~current["frameId"];
	var frames_simcodes = (0..3).inject( [init_frame], { |acc, idx|
		var nearest = [1,2,3].wchoose([1,1,3].normalizeSum);
		var newFrame = ~getSimilarFrameId.(acc[idx], nearest);
		acc.add(newFrame);
	});

	frames_simcodes = frames_simcodes.scramble;
	frames_simcodes = frames_simcodes.pyramid(3);

	10.do({ arg i;
		var frameId = frames_simcodes.wrapAt(i);
		var waitTime = ((1..10)/2).choose;
		"SIM3".postln;
		~updateCurrent.(frameId);
		waitTime.wait;
    });

	"SIMILAR 3 TASK FINISHED".postln;
});


~moveForward = Task({
	/*moves over previous frames on current Frame*/
	30.do({ arg i;
		var nextFrameId = ~getNextFrameId.(~current["frameId"], 1);
		var waitTime = ((1..10)/5).choose;
		//nextFrameId.postln;
		~updateCurrent.(nextFrameId);
		waitTime.wait;
    });
	"MOVE FROWARD  FINISHED".postln;
});


~moveBackwards = Task({
	/*moves over previous frames on current Frame*/
	30.do({ arg i;
		var nextFrameId = ~getPreviousFrameId.(~current["frameId"], 1);
		var waitTime = ((1..10)/5).choose;
		//nextFrameId.postln;
		~updateCurrent.(nextFrameId);
		waitTime.wait;
    });
	"MOVE BACKWRDS  FINISHED".postln;
});

~updateSimilarRealTimeTask = Task({
	/*will get similar*/
	10.do({ arg i;
		var nextFrameId = ~getSimilarFrameId.(~current["frameId"], 3);
		var waitTime = ((1..10)).choose;
		~updateCurrent.(nextFrameId);
		"SIM REAL TIME".postln;
		waitTime.wait;
    });
	"GET SIM REAL TIME FINISHED".postln;
});

)


~updateCurrent.(~coolFrames[0]);
~updateCurrent.(~coolFrames[2]);
~updateCurrent.(~coolFrames[5]);


(
~moveForward.stop;
~moveForward.start;
)

(
~moveBackwards.stop;
~moveBackwards.start;
)

(
~updateSimilarRealTimeTask.stop;
~updateSimilarRealTimeTask.start;
)


(
~similar1.stop;
~similar1.start;
)


(
~similar2.stop;
~similar2.start;
)

(
~similar3.stop;
~similar3.start;
)


~similar1.start;
~similar1.pause;
~similar1.resume;
~similar1.reset;
~similar1.stop;


~updateCurrent.(~coolFrames[3]);
~updateCurrent.(~coolFrames[(~coolFrames.size-1).rand]); //rand cool


// ===========
// =========== NICE VALUES
// =========== NICE VALUES


//nice artifacts with small frames:
Pbindef(\loopPlayer1,
	\sPos, Pfuncn({~current["startFrame"]}, inf) + Pbrown(1000,20000,1000, inf),
	\endPos, Pfuncn({~current["endFrame"]}, inf) + Pbrown(0,20000,1000, inf), //when 0, nice artifacts
);


//nice artifacts with small frames:
Pbindef(\loopPlayer1,
	\offsetStart, Pbrown(1000,20000,1000, inf),
	\offsetEnd,   Pbrown(0,20000,1000, inf),
	\sPos, Pkey(\getStart) + Pkey(\offsetStart),
	\endPos, Pkey(\getEnd) + Pkey(\offsetEnd),
);

//original values:
Pbindef(\loopPlayer1,
	\offsetStart, Pbrown(0,30000,10000, inf),
	\offsetEnd,   Pbrown(0,1000000,30000, inf),
	\sPos, Pkey(\getStart) + Pkey(\offsetStart),
	\endPos, Pkey(\getEnd) + Pkey(\offsetEnd),
);

//start moves:
Pbindef(\loopPlayer1,
	\offsetStart, Pbrown(0,1000000,30000, inf),
	\offsetEnd,   Pbrown(0,1000000,30000, inf),
	\sPos, Pkey(\getStart) + Pkey(\offsetStart),
	\endPos, Pkey(\getEnd) + Pkey(\offsetEnd),
);



//ENVELOPES
Pbindef(\loopPlayer1,
	\sus, Pseq((1..200)/100, inf)
);

Pbindef(\loopPlayer1,
	\atk, Pseq((1..10)/10, inf)
);


(
//nice dur original, 10x faster
Pbindef(\loopPlayer1,
	\atk, Pbrown(1, 3, 0.0125, inf),
	\sus, Pbrown(1, 4, 0.0125, inf),
	\rel, Pbrown(1, 3, 0.0125, inf),
	\dur, Pwhite(0.005, 0.02, inf) * ( Pkey(\atk) + Pkey(\sus) + Pkey(\rel))
);
)




s.record
s.stopRecording


