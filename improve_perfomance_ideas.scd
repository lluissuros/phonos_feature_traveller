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

*/










//************************************
//performance tests
//************************************

(
var dir = Document.current.dir.asString ++ "/files";
var by_frame_id = dir ++ "/by_frame_id.json";
var track_to_path = dir ++ "/tracks_to_path.json";
var by_word = dir ++ "/by_word.json";

var load_json = {|filepath|
	var dict;
	"parsing json into object, might take a while...".postln;
	dict  = filepath.parseYAMLFile.changeScalarValuesToDataTypes; //https://github.com/blacksound/BSLib/blob/master/classes/extDictionary.sc
//	dict = filepath.parseYAMLFile(); //parses json into object
	"loaded !!".postln;
	dict;
};

{d = load_json.( by_frame_id )}.bench;
{~tracks_paths = load_json.( track_to_path )}.bench;
)



// try this also : jsonCue.changeScalarValuesToDataTypes.asIdentityDictionaryWithSymbolKeys;



(
"running...".postln;
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

