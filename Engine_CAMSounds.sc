Engine_CAMSounds : CroneEngine {
	var kernel, debugPrinter;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		kernel = CAMSounds.new(Crone.server);

		// takes the floating value for mn from Lua to SC and makes it available to the global SC environment:
		this.addCommand(\mn, "f", { arg msg;
			var mn = msg[1].asFloat; 
			kernel.setmn(mn); 
		});
	 
	free {
		kernel.free;
	}
}
}
