/*PERFORMANCE PROBLEMS*/

/*1- DEALING WITH SUPER JSONS
Loaded Jsons have very bad performance (0.1 sec access), but if I create a similar object in SC, it has the normal very good performance!!!!
 Is there anything wrong with the load of JSON?

* API quark
* https://github.com/blacksound/BSLib/blob/master/classes/extDictionary.sc

*/



/*
DEALING WITH slow functions:
 Create an async-like programming in case the functions take too long?
https://mail.google.com/mail/u/0/#search/sc-users+async/FMfcgxwBVMhQthFBvfKgmntWQbXzfQSG
(Apparently this can be done with routines)
*/







/*
2- DEALINNG WITH BIG DATASET COLLECTION
Seems unreasonable to load everything into RAM:

* Use VDiskin, (we can select start in cueSoundFile), maybe glitch?
* Dynamically allocate and free Buffers

* Loading JSON: The parsing can take long, but then you can save the data as an Archive, and it loads really quickly. <-- COOL

*/



/*
ALTERNATIVE: using python, tlaking to sclang?
http://gewhere.github.io/blog/2017/10/13/live-coding-using-sc3-and-scikit-learn/


*/










//************************************
//performance tests
//************************************

(
//THIS TAKES FOREVER with changeScalarValuesToDataTypes...
var dir = Document.current.dir.asString ++ "/files";
var by_frame_id = dir ++ "/by_frame_id.json";
var track_to_path = dir ++ "/tracks_to_path.json";
var by_word = dir ++ "/by_word.json";

var load_json = {|filepath|
	var dict;
	"parsing json into object, might take a while...".postln;
	dict  = filepath.parseYAMLFile.changeScalarValuesToDataTypes; //https://github.com/blacksound/BSLib/blob/master/classes/extDictionary.sc , will change strings to previous values...
//	dict = filepath.parseYAMLFile(); //parses json into object
	"loaded !!".postln;
	dict;
};

{d = load_json.( by_frame_id )}.bench;
{~tracks_paths = load_json.( track_to_path )}.bench;
)



/*
TRY THIS FOR DYNAMIC BUFFER ALLOCATION:


https://mail.google.com/mail/u/0/#search/sc-users+too+many+buffers/FMfcgxwBWSwcLmSssTqGrftMWTPTJvrV

1//- To make it a bit more robust, free the buffer based on bufnum, or synth.

That is, the code example as given will free the buffer when *any* synth sends a '/tr'. That's a bit dangerous.

a/ You could send the bufnum back in the message, and free the buffer only if it matches.

(
OSCdef(\freeBuffer, { |msg|
    if(msg[3] == ~buffer.bufnum) {
        ~buffer.free
    };
}, '/tr', s.addr);

{
    var sig = PlayBuf.ar(1, ~buffer, BufRateScale.kr(~buffer), doneAction: 2);
    SendTrig.kr(Done.kr(sig), value: ~buffer.bufnum);
    sig;
}.play;
)

b/ Or, think of it like "this synth is using this buffer; when the synth ends, then we can free the buffer." One neat trick here is that it's easier to use OSC objects' argument filtering and 'oneShot', so it will fire once and only once for this synth (and clean itself up).

(
a = {
    var sig = PlayBuf.ar(1, ~buffer, BufRateScale.kr(~buffer), doneAction: 2);
    SendTrig.kr(Done.kr(sig));
    sig;
}.play;

// 'argTemplate' means match the nodeID in ['/tr', nodeID]
OSCFunc({ ~buffer.free }, '/tr', s.addr, argTemplate: [a.nodeID]).oneShot;
)






2. You should never 'read' a buffer and immediately use it. It takes a short time to read a buffer. Maybe the synth is starting before the buffer is ready, and this interferes with it stopping properly.

Something like this would be better.

~function = {
    var buf, instance;
    fork {
        buf = Buffer.read(s, ~somepath);
        s.sync;  // <<-- this is important!
        instance = {
            var sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf), doneAction: 2);
            SendTrig.kr(Done.kr(sig));
            sig;
        }.play;
        OSCFunc({ buf.free }, '/tr', s.addr, argTemplate: [instance.nodeID]).oneShot;
    };
};*/


(
"running...g".postln;
t = ~by_frame_id.keys.inject(Dictionary.new, {|accumulator, key|
		var dict = Dictionary.new;
	dict["end_sample"]= 11100000.rand; dict["absolute_path"]= 11100000.rand; dict["loudness"]= 11100000.rand; dict["track_id"]= 11100000.rand; dict["word_2_nearest"]= 11100000.rand; dict["word_3_nearest"]= 11100000.rand; dict["previous_frame_id"]= 11100000.rand; dict["mfcc_9"]= 11100000.rand; dict["mfcc_3"]= 11100000.rand; dict["mfcc_12"]= 11100000.rand; dict["mfcc_11"]= 11100000.rand; dict["mfcc_4"]= 11100000.rand; dict["mfcc_7"]= 11100000.rand; dict["mfcc_10"]= 11100000.rand; dict["mfcc_1"]= 11100000.rand; dict["next_frame_id"]= 11100000.rand; dict["scale"]= 11100000.rand; dict["mfcc_0"]= 11100000.rand; dict["start_sample"]= 11100000.rand; dict["mfcc_6"]= 11100000.rand; dict["mfcc_8"]= 11100000.rand;
	accumulator[key] = dict;
});
t.keys.size;
{t["spot1.wav_f"++10000]}.bench;
)


(
	var test = ~by_frame_id["spot1.wav_f1146"];
	{test["track_id"]}.bench
)

(

)



~by_frame_id.keys

{~by_frame_id["spot1.wav_f1146"]}.bench
{d["spot1.wav_f1146"]}.bench
{t["spot1.wav_f1146"]}.bench
{a["spot1.wav_f1146"]}.bench
{~by_frame_id["spot1.wav_f1146"]["track_id"]}.bench
{d["spot1.wav_f1149"]}.bench


~by_frame_id["spot1.wav_f1146"]
d["spot1.wav_f1146"]
a = ~by_frame_id.copy.()



~testDict.keys.postln
(
{
	var dict = Dictionary.new;
	dict["end_sample"]= 11100000.rand; dict["absolute_path"]= 11100000.rand; dict["loudness"]= 11100000.rand; dict["track_id"]= 11100000.rand; dict["word_2_nearest"]= 11100000.rand; dict["word_3_nearest"]= 11100000.rand; dict["previous_frame_id"]= 11100000.rand; dict["mfcc_9"]= 11100000.rand; dict["mfcc_3"]= 11100000.rand; dict["mfcc_12"]= 11100000.rand; dict["mfcc_11"]= 11100000.rand; dict["mfcc_4"]= 11100000.rand; dict["mfcc_7"]= 11100000.rand; dict["mfcc_10"]= 11100000.rand; dict["mfcc_1"]= 11100000.rand; dict["next_frame_id"]= 11100000.rand; dict["scale"]= 11100000.rand; dict["mfcc_0"]= 11100000.rand; dict["start_sample"]= 11100000.rand; dict["mfcc_6"]= 11100000.rand; dict["mfcc_8"]= 11100000.rand;
}.bench

)





{~testDict = ~by_frame_id["spot1.wav_f1146"]}.bench

~by_frame_id.keys.size.()
d.keys.size.()

~testDict2 = ~testDict.copy
~by_frame_id = d.copy

{d["track_id"]}.bench

{~getStartSample.("spot1.wav_f1146")}.bench



//SERGI:
s.sync
s.bind




(
s.bind {
	~by_frame_id["spot1.wav_f1346"].post;
	s.sync;
	"1".postln;
	~by_frame_id["spot1.wav_f1346"];
	"2".postln;
	~by_frame_id["spot1.wav_f1346"];
	"3".postln;
}
)



~by_frame_id["spot1.wav_f1346"]





(
/*
OK, this is GOOD:
s.sync inside a function (and inside a Routine) allows to sync with the server and interrupt the excution code with other actions. I think it might also solve the "late" problem.

A Routine is something like a thread
this is ASYNC!

 This doesnt solve the perfromance problem but gives a better way to deal with it.

*/


Routine.run {
    var c;
	// create a condition variable to control execution of the Routine
    //c = Condition.new;
	5.do({
		s.sync;
		"s1".postln;
		~by_frame_id["spot1.wav_f1346"]["track_id"];
	})
};

Routine.run {
    var c;
	// create a condition variable to control execution of the Routine
    //c = Condition.new;
	5.do({
		s.sync;
		"s2".postln;
		~by_frame_id["spot1.wav_f1346"];
	})
};

)


{~buffers_by_id["spot1.wav"]}.bench