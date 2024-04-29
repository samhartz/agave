// "the" bangs

ThebangsAg  {
	classvar maxVoices = 3;//32;

	var server;
	var group;

	// synth params
	var <>hz1;
	var <>hz2;
	var <>mod1;
	var <>mod2;
	var <>amp;
	var <>pan;
	var <>attack;
	var <>release;
	var <>z;

	// some bangs
	var bangs;
	// the bang - a method of Bangs, as a string
	var <thebang;
	// which bang - numerical index
	var <whichbang;

	var <voicer;

  var winenv, envbuf;

	*new { arg srv;
		^super.new.init(srv);
	}

	init {
		arg srv;
		server = srv;
		group = Group.new(server);

		// default parameter values
		hz1 = 330;
		hz2 = 10000;
		mod1 = 0.5;
		mod2 = 0.0;
    z = 400;
		attack = 0.01;
		release = 2;
		amp = 0.1;
		pan = 0.0;

    // envelope for the grains
    winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
    envbuf = Buffer.sendCollection(server, winenv.discretize, 1);

		bangs = BangsAg.class.methods.collect({|m| m.name});
		bangs.do({|name| postln(name); });

		this.whichBang = 0;

		voicer = OneshotVoicerAg.new(maxVoices);
	}

	//--- setters
	bang_{ arg name;
		// postln("bang_("++name++")");
		thebang = name;
	}

	whichBang_ { arg i;
		// postln("whichBang_("++i++")");
		whichbang = i;
		thebang = bangs[whichbang];
	}

	// bang!
	bang { arg hz, z;
		var fn;


		/*
		postln("bang!");
		postln([hz1, mod1, hz2, mod2, amp, pan, attack, release]);
		postln([server, group]);
		*/
		
		if (hz != nil, { hz1 = hz; });
		// if (z != nil, { z1 = z; });
		

		fn = {
			var syn;
      var pan=0, grainEnv, freqdev;

			syn = {
				arg gate=1, z=400, grainDur=0.1;
				var snd, perc, ender, grainWetDry=0.5;


				perc = EnvGen.ar(Env.perc(attack, release), doneAction:Done.freeSelf);
				ender = EnvGen.ar(Env.asr(0, 1, 0.01), gate:gate, doneAction:Done.freeSelf);
				
				snd = BangsAg.perform(thebang, hz1, mod1, hz2, mod2, perc);
        // z.poll;
        
        //filter
        snd = BPF.ar(snd, z, 0.5);
        // snd = MoogFF.ar(snd, z, 0.3);
        
        //delay
        snd = CombN.ar(Decay.ar(snd, 1/z, snd), 0.5, 0.5, 3) * 0.5;
        // snd = CombN.ar(Decay.ar(snd, 0.2, snd), 0.5, 0.5, 3);

        //granulation
        //from: https://doc.sccode.org/Classes/GrainFM.html
        // use WhiteNoise to control deviation from center pitch
        // TODO: make the input to WhiteNoise dynamic
        freqdev = WhiteNoise.kr(200);
        grainEnv = EnvGen.kr(
          Env([0, 1, 0], [1, 1], \sin, 1),
          gate,
          levelScale: amp,
          doneAction: Done.freeSelf
        );
        snd = (snd*(1-grainWetDry)) + (grainEnv*(grainWetDry*GrainFM.ar(2, Impulse.kr(10), grainDur, 440 + freqdev, 200, snd, pan, envbuf)));



        //send to out
				Out.ar(0, Pan2.ar(snd * perc * amp * ender, pan));

			}.play(group);
			syn
		};

		voicer.newVoice(fn);
	}


	setZ { arg z;
		group.set(\z, z);
	}

	freeAllNotes {
		// do need this to keep the voicer in sync..
		voicer.stopAllVoices;
		// but it should ultimately do the same as this (more reliable):
		group.set(\gate, 0);
	}

}
