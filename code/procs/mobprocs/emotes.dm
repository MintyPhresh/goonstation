// emote
#define VISIBLE 1
#define AUDIBLE 2
//#define VISIBLEAUDIBLE 3 //intended for something that is detectable either way
#define OPT_OUT 1 // Emote usable unless specifically disallowed
#define OPT_IN  2 // Emote only usable if specifically allowed
#define RESTRAINED 1
#define MUZZLED 2
#define CONSOLE 1
#define RETICLE 2


///parent emote
ABSTRACT_TYPE(/datum/emotedata)
/datum/emotedata/proc/make_emote(var/mob/emoter, var/target) //Default behavior for emotes

	em_restrained_fail_chattext ||= "<B>[emoter]</B> struggles to move."
	em_restrained_fail_maptext ||= "<I>struggles to move</I>"

	em_muzzled_fail_chattext ||= "<B>[emoter]</B> tries to make a noise."
	em_muzzled_fail_maptext ||= "<I>tries to make a noise</I>"

	switch(use_is_restricted_if)
		if(RESTRAINED)
			if(emoter.restrained()) // switch outputs to restrained outputs if you're restrained & the emote cares about that
				em_chattext = em_restrained_fail_chattext
				em_maptext = em_restrained_fail_maptext
		if(MUZZLED)
			if(emoter.wear_mask && emoter.wear_mask.is_muzzle) // switch outputs to muzzled outputs if you're muzzled & the emote cares about that
				em_chattext = em_muzzled_fail_chattext
				em_maptext = em_muzzled_fail_maptext
	return
/datum/emotedata
	// By default, the name of the emote datum is the activation phrase, e.g. *fart (or similar). (this happens in New())
	/// This list is for if the emote has alternate phrases that can activate it.
	var/list/phrases
	/// Defines if an emote is visible, audible, or both (both functionality ETA never?).
	var/mode = VISIBLE
	/// Text that goes in the chat box. Functional limitations with embedded expressions force this to be assigned in the make_emote() proc.
	var/em_chattext
	/// Text that floats above the emoter's head. Likewise wrt make_emote().
	var/em_maptext

	/// UNIMPLEMENTED You must wait this long before performing another emote.
	var/cooldown = 0 SECONDS
	/// UNIMPLEMENTED Is the emote opt-out (available by default) or opt-in (must be enabled for the specific mob)?
	var/em_opt
		// Use opt-in for emotes exclusive to specific mobs or situations, e.g. *birdwell, which seems to be silicon exclusive.

	/// Does something different if it's set to RESTRAINED or MUZZLED while you satisfy those conditions.
	var/use_is_restricted_if

	var/em_restrained_fail_chattext //generic restrained/muzzled failtexts
	var/em_restrained_fail_maptext
	var/em_muzzled_fail_chattext
	var/em_muzzled_fail_maptext

ABSTRACT_TYPE(/datum/emotedata/basic)
/datum/emotedata/basic
	blush
		make_emote(var/mob/emoter, var/target)
			em_chattext = "<b>[emoter]</b> blushes."
			em_maptext = "<I>blushes</I>"
			. = ..()
	eyebrow
		phrases = list("raiseeyebrow")
		make_emote(var/mob/emoter, var/target)
			em_chattext = "<b>[emoter]</b> raises an eyebrow."
			em_maptext = "<I>raises an eyebrow</I>"
			. = ..()
	flinch
		make_emote(var/mob/emoter, var/target)
			em_chattext = "<b>[emoter]</b> flinches."
			em_maptext = "<I>flinches</I>"
			. = ..()
	flipout
		make_emote(var/mob/emoter, var/target)
			em_chattext = "<b>[emoter]</b> shakes [his_or_her(emoter)] head."
			em_maptext = "<I>shakes [his_or_her(emoter)] head</I>"
			. = ..()
	handpuppet //contains some commented-out code because this emote needs improvement, but it should be atomized
		// use_is_restricted_if = RESTRAINED
		make_emote(var/mob/emoter, var/target)
			em_chattext = "<b>[emoter]</b> throws [his_or_her(emoter)] voice, badly, while flapping [his_or_her(emoter)] thumb and index finger like some sort of lips.[prob(10) ? " Admittedly, it is a pretty good impression of the [pick("captain", "head of personnel", "clown", "research director", "chief engineer", "head of security", "medical director", "AI", "chaplain", "detective")]." : null]"
			// em_maptext = "<I>talks funny while handpuppeting</I>"
			// em_restrained_fail_chattext = "<b>[emoter]</b> throws [his_or_her(emoter)] voice, badly, while moving [his_or_her(emoter)] fingers in a way you can't really understand.
			// em_restrained_fail_maptext ="<I>talks funny while trying to move [his_or_her(emoter)] arm</I>"
			. = ..()
	juggle
		use_is_restricted_if = RESTRAINED
		make_emote(var/mob/emoter, var/target)
			if (emoter.emote_check(voluntary, 2.5 SECONDS))
				if (emoter.traitHolder?.hasTrait("training_clown") || emoter.traitHolder?.hasTrait("training_mime") || emoter.can_juggle)
					var/obj/item/thing = emoter.equipped()
					if (!thing)
						if (emoter.l_hand)
							thing = emoter.l_hand
						else if (emoter.r_hand)
							thing = emoter.r_hand
					if (thing && !thing.cant_drop)
						if (emoter.juggling())
							if (prob(emoter.juggling.len * 5)) // might drop stuff while already juggling things
								emoter.drop_juggle()
							else
								emoter.add_juggle(thing)
						else
							emoter.add_juggle(thing)
					else
						message = "<B>[emoter]</B> wiggles [his_or_her(emoter)] fingers a bit.[prob(10) ? " Weird." : null]"
						maptext_out = "<I>wiggles [his_or_her(emoter)] fingers a bit.</I>"
			. = ..()
	pale
		phrases = list("gopale")
		make_emote(var/mob/emoter, var/target)
			em_chattext = "<b>[emoter]</b> goes pale for a second."
			em_maptext = "<I>goes pale...</I>"
			. = ..()

	rage
		phrases = list("fury","angry")
		make_emote(var/mob/emoter, var/target)
			em_chattext = "<b>[emoter]</b> becomes utterly furious!"
			em_maptext = "<I>becomes utterly furious!</I>"
			. = ..()
	rapidblink
		phrases = list("rblink","r_blink","blinkr","blink_r")
		make_emote(var/mob/emoter, var/target)
			em_chattext = "<b>[emoter]</b> blinks rapidly."
			em_maptext = "<I>blinks rapidly</I>"
			. = ..()
	shakehead
		phrases = list("smh")
		make_emote(var/mob/emoter, var/target)
			em_chattext = "<b>[emoter]</b> shakes [his_or_her(emoter)] head."
			em_maptext = "<I>shakes [his_or_her(emoter)] head</I>"
			. = ..()

	uguu
		mode = AUDIBLE
		make_emote(var/mob/emoter, var/target)
			if (istype(emoter.wear_mask, /obj/item/clothing/mask/anime) && !emoter.stat)
				em_chattext = "<b>[emoter]</b> uguus!"
				em_maptext = "<I>uguus</I>"
				playsound(emoter, 'sound/voice/uguu.ogg', 80, FALSE, 0, emoter.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
				SPAWN(1 SECOND)
					emoter.wear_mask.set_loc(emoter.loc)
					emoter.wear_mask = null
					logTheThing(LOG_COMBAT, emoter, "was gibbed by emoting uguu at [log_loc(emoter)].")
					emoter.gib()
					return
			else
				emoter.show_text("You just don't feel kawaii enough to uguu right now!", "red")
				return
			. = ..()
	// Commands for manual blinking/breathing, from April Fools' past.
	inhale
		make_emote(var/mob/emoter, var/target)
			if (!manualbreathing)
				emoter.show_text("You are already breathing!")
				return
			var/mob/living/L = emoter
			var/datum/lifeprocess/breath/B = L.lifeprocesses?[/datum/lifeprocess/breath]
			if (B)
				if (B.breathstate)
					emoter.show_text("You just breathed in, try breathing out next dummy!")
					return
				B.breathtimer = 0
				B.breathstate = 1

			emoter.show_text("You breathe in.")
	exhale
		make_emote(var/mob/emoter, var/target)
			if (!manualbreathing)
				emoter.show_text("You are already breathing!")
				return
			var/mob/living/L = emoter
			var/datum/lifeprocess/breath/B = L.lifeprocesses?[/datum/lifeprocess/breath]
			if (B)
				if (!B.breathstate)
					emoter.show_text("You just breathed out, try breathing in next silly!")
					return
				B.breathstate = 0

			emoter.show_text("You breathe out.")
	closeeyes
		make_emote(var/mob/emoter, var/target)
			if (!manualblinking)
				emoter.show_text("Why would you want to do that?")
				return
			var/mob/living/L = emoter
			var/datum/lifeprocess/statusupdate/S = L.lifeprocesses?[/datum/lifeprocess/statusupdate]
			if (S)
				if (S.blinkstate)
					emoter.show_text("You just closed your eyes, try opening them now dumbo!")
					return
				S.blinkstate = 1
				S.blinktimer = 0

			emoter.show_text("You close your eyes.")
	openeyes
		make_emote(var/mob/emoter, var/target)
			if (!manualblinking)
				emoter.show_text("Your eyes are already open!")
				return
			var/mob/living/L = emoter
			var/datum/lifeprocess/statusupdate/S = L.lifeprocesses?[/datum/lifeprocess/statusupdate]
			if (S)
				if (!S.blinkstate)
					emoter.show_text("Your eyes are already open, try closing them next moron!")
					return
				S.blinkstate = 0

			emoter.show_text("You open your eyes.")


ABSTRACT_TYPE(/datum/emotedata/basic/simple)
ABSTRACT_TYPE(/datum/emotedata/basic/simple/visible)
ABSTRACT_TYPE(/datum/emotedata/basic/simple/audible)
/datum/emotedata/basic/simple // For the discerning emoter. Makes the emoter do the first activation phrase in the list. Splendid.
		   					  // DISCLAIMER: Might do other shit too. idgaf. This is here so I don't have to rewrite the chattext.
	make_emote(var/mob/emoter, var/target)
		var/act = phrases[1]
		em_chattext ||= "<B>[emoter]</B> [act]s."
		em_maptext ||= "<I>[act]s</I>"
		. = ..()

	visible //Don't freak out: Code in the Emote() proc adds the name of each emote as an activation phrase.
		mode = VISIBLE
		//If you're making/editing an emote, note that emotes that have vars defined in {curly brackets} don't play nicely
		// with indentations.
		blink
		bow
		clap  {use_is_restricted_if = RESTRAINED}
		drool
		frown {phrases = list(":(")}
		gesticulate
		glare
		grimace {phrases = list("d:","dx")} // these should be D: and DX but lowercasing is RUINING US!!
		grin {phrases = list(">:)",":d")} // same for this! FUCK!
		grump {phrases = list(":i")}
		nod
		pout {phrases = list(":c")}
		quiver
		salute
		scowl {phrases = list(">:(")}
		shiver
		shrug
		smile {phrases = list(":)")}
		smirk {phrases = list(":j")}
		stare {phrases = list(":|")}
		sulk
		tremble
		wave

	audible //unfinished
		mode = AUDIBLE
		use_is_restricted_if = MUZZLED
		birdwell //unfinished
			use_is_restricted_if = null
			em_opt = OPT_IN
			make_emote(var/mob/emoter, var/target)
				. = ..()
				playsound(emoter.loc, 'sound/vox/birdwell.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
		cackle
		choke
		chortle
		chuckle
		cough
		gargle
		gasp
		giggle
		groan
		grumble
		guffaw
		gurgle
		hiccup
		laugh {phrases = list("xd")}
		moan
		mumble
		scoff
		sigh
			make_emote(var/mob/emoter, var/target)
				. = ..()
				var/muzzled = (emoter.wear_mask && emoter.wear_mask.is_muzzle)
				if (prob(1) && !muzzled) // needs to be here so people can't singh through muzzles
					em_chattext = "<B>[emoter]</B> singhs."
					em_maptext = "<I>singhs</I>"
		sneeze
			make_emote(var/mob/emoter, var/target)
				. = ..()
				var/muzzled = (emoter.wear_mask && emoter.wear_mask.is_muzzle)
				if (prob(1) && !muzzled && (emoter.mind?.assigned_role == "Clown" || emoter.reagents.has_reagent("honky_tonic")))
					em_chattext = "<B>[emoter]</B> sneezes out a handkerchief!"
					em_maptext = "<I>sneezes out a handkerchief!</I>"
					var/obj/HK = new /obj/item/cloth/handkerchief/random(get_turf(emoter))
					var/turf/T = get_edge_target_turf(emoter, pick(alldirs))
					HK.throw_at(T, 5, 1)
		sniff
		snore
		sob
		sputter
		wail
		weep
		whine
		wheeze
		whimper
		yawn // due to budget cuts noncontaigousyawn must be written elsewhere
			make_emote(var/mob/emoter, var/target)
				. = ..()
				for (var/mob/living/carbon/C in view(5,get_turf(emoter)))
					if (prob(5) && !ON_COOLDOWN(C, "contagious_yawn", 5 SECONDS) && target != null)
						C.emote("yawn", emoter) // just picking something random so that

ABSTRACT_TYPE(/datum/emotedata/targeted)
/*
/datum/emotedata/targeted //unfinished
	/// for CONSOLE targeting emotes. Within this range, targets will appear in the list.
	var/initiation_range = 5
	/// How does an enterprising young emoter choose what to emote at?
	var/targeting_type = RETICLE
	/// Emote to do if there's nobody to target; e.g. *saluteto does *salute.
	var/lonely_emote
	/// Chatbox text if there's nobody to target, and lonely_emote is not defined
	var/lonely_em_chattext = "<B>[src]</B> looks around wistfully."
	/// floating text if there's nobody to target, and lonely_emote is not defined
	var/lonely_em_maptext = "<I>looks around wistfully</I>"

	/// If a selected target is outside this range, the emote will fail.
	var/execution_range = 5

	/// How the selection popup describes your action.
	var/action_phrase = "target"
	emote()
		var/list/target_list = src.get_targets(range, "mob")
		if(length(target_list))
			target_thing = tgui_input_list(src, "Pick something to [action_phrase]!", "EmotiConsole v1.1.3", target_list, (20 SECONDS))
			boutput(src, SPAN_EMOTE("<B>[target_thing]</B> isn't close enough for you to [action_phrase]!"))
		else if(lonely_emote)
			src.emote(lonely_emote)
		. = ..()


	saluteto //unfinished
		phrases = list("saluteto")
		lonely_emote = "salute"
		mode = VISIBLE
		usable_if_restrained = FALSE

		action_phrase = "salute"
		em_chattext = "<B>[src]</B> salutes [target_thing]."
		em_maptext = "<I>salutes [target_thing]</I>"

	bowto
		phrases = list("bowto")
		lonely_emote = "bow"
		mode = VISIBLE

		action_phrase = "bow before"
		em_chattext = "<B>[src]</B> bows to [target_thing]."
		em_maptext = "<I> bows to [target_thing]</I>"

	waveto
		phrases = list("waveto")
		lonely_emote = "wave"
		mode = VISIBLE

		action_phrase = "wave to"
		em_chattext = "<B>[src]</B> waves to [target_thing]."
		em_maptext = "<I> bows to [target_thing]</I>"

	blowkiss
		phrases = list("blowkiss")
		lonely_em_chattext = "<B>[src]</b> blows a kiss to... [himself_or_herself(src)]?"
		lonely_em_maptext = "<I> blows a kiss to... [himself_or_herself(src)]?</I>"
		mode = VISIBLE

		action_phrase = "blow a [prob(1) ? "smooch" : "kiss"] at"
		em_chattext = "<B>[src]</B> blows a kiss to [M]."
		em_maptext = "<I>blows a kiss to [M]</I>"

/datum/emotedata/targeted/console
	targeting_type = CONSOLE

ABSTRACT_TYPE(/datum/emotedata/info)
/datum/emotedata/info //unfinished
	list
		phrases = list("list")

	listbasic
		phrases = list("listbasic")
*/
	//////////////////////
	//// TODO EMOTES! ////
	//////////////////////
/*
Basic
	scream
		phrases = list("scream")
		use_restricted_if = MUZZLED
	monsterscream
		phrases = list("monsterscream")
	fart
		phrases = list("fart")
	lookaround
		phrases = list("lookaround")
	juggle
		phrases = list("juggle")
		use_restricted_if = RESTRAINED
	twirl
		phrases = list("twirl","spin")
		use_restricted_if = RESTRAINED
	tip
		phrases = list("tip")
		use_restricted_if = RESTRAINED
	uguu
		phrases = list("uguu")
	hatstomp
		phrases = list("hatstomp","stomphat")
	bubble
		phrases = list("bubble")

Targeted
	saluteto
		phrases = list("saluteto")
		lonely_emote = "salute"
	waveto
		phrases = list("waveto")
		lonely_emote = "wave"
	nodat
		phrases = list("nodat")
		lonely_emote = "nod"
	glareat
		phrases = list("glareat")
		lonely_emote = "glare"
	blowkiss
		phrases = list("blowkiss")
	fingerguns
		phrases = list("fingerguns")
	lookat
		phrases = list("lookat","look")
		lonely_emote = "lookaround"
Console
	sidehug
		phrases = list("sidehug")
	give
		phrases = list("give")
Customs
	custom
		phrases = list("custom")
	customv
		phrases = list("customv")
	customh
		phrases = list("customh")
Info
	help
		phrases = list("help")
	list
		phrases = list("list")
	listbasic
		phrases = list("listbasic")
	listtarget
		phrases = list("listtarget")


*/
/mob/proc/emote(var/act, var/voluntary = 0, var/emoteTarget = null) //mbc : if voluntary is 2, it's a hotkeyed emote and that means that we can skip the findtext check. I am sorry, cleanup later
	set waitfor = FALSE
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOB_EMOTE, act, voluntary, emoteTarget)

	if (!bioHolder) bioHolder = new/datum/bioHolder( src )

	if(voluntary && !src.emote_allowed)
		return

	if (src.bioHolder.HasEffect("revenant"))
		src.visible_message(SPAN_ALERT("[src] makes [pick("a rude", "an eldritch", "a", "an eerie", "an otherworldly", "a netherly", "a spooky")] gesture!"), group = "revenant_emote")
		return

	if (voluntary == 1 && !emoteTarget)
		if (findtext(act, " ", 1, null))
			var/t1 = findtext(act, " ", 1, null)
			emoteTarget = copytext(act, t1 + 1, length(act) + 1)
			act = copytext(act, 1, t1)

	act = lowertext(act)

	var/custom = 0 //Sorry, gotta make this for chat groupings.

	// Following is intended to be replaced by the opt-in/-out system in the future. Do not forget!
	/* var/list/mutantrace_emote_stuff = src.mutantrace.emote(act, voluntary)
	if(!islist(mutantrace_emote_stuff))
		message = mutantrace_emote_stuff
	else
		if(length(mutantrace_emote_stuff) >= 1)
			message = mutantrace_emote_stuff[1]
		if(length(mutantrace_emote_stuff) >= 2)
			maptext_out = mutantrace_emote_stuff[2]

	if (!message) */
	var/datum/emotedata/selected_emote
	// Compares var/act to every emote's activation phrase, stopping when it finds a match
	for (var/datum/emotedata/em_data as anything in concrete_typesof(/datum/emotedata))
		var/split_path = splittext("[em_data]", "/")
		var/em_name = split_path[length(split_path)]
		em_data = get_singleton(em_data)
		 // This part here puts the end of the emote's path as an activation phrase. Cuts down on typing!
		if (length(em_data.phrases))
			if (!cmptext(em_data.phrases[1],em_name))
				em_data.phrases.Insert(1,em_name) //puts it at the front since it's the most important phrase
		else
			em_data.phrases += list(em_name)
		if (act in em_data.phrases)
			selected_emote = em_data
			selected_emote.make_emote(emoter = src, target = emoteTarget)
			break
	if (!selected_emote && voluntary)
		src.show_text("Invalid Emote: [act]")

	//////////////////////////////////////////////////////
	//// FOLLOWING CODE IS STOLEN FROM OLD EMOTE CODE ////
	//////////////////////////////////////////////////////

	if (selected_emote.em_maptext && !ON_COOLDOWN(src, "emote maptext", 0.5 SECONDS))
		var/image/chat_maptext/chat_text = null
		SPAWN(0) //blind stab at a life() hang - REMOVE LATER
			var/mob/living/L = src
			if (speechpopups && src.chat_text && L)
				chat_text = make_chat_maptext(src, selected_emote.em_maptext, "color: #C2BEBE;" + L.speechpopupstyle, alpha = 140)
				if(chat_text)
					if(selected_emote.mode == VISIBLE)
						chat_text.plane = PLANE_NOSHADOW_ABOVE
						chat_text.layer = 420
					chat_text.measure(src.client)
					for(var/image/chat_maptext/I in src.chat_text.lines)
						if(I != chat_text)
							I.bump_up(chat_text.measured_height)

			if (selected_emote.em_chattext)
				logTheThing(LOG_SAY, src, "EMOTE: [selected_emote.em_chattext]")
				act = lowertext(act)
				if (selected_emote.mode == VISIBLE)
					for (var/mob/O in viewers(src, null))
						O.show_message(SPAN_EMOTE("[selected_emote.em_chattext]"), selected_emote.mode, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
				else if (selected_emote.mode == AUDIBLE)
					for (var/mob/O in hearers(src, null))
						O.show_message(SPAN_EMOTE("[selected_emote.em_chattext]"), selected_emote.mode, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
				else if (!isturf(src.loc))
					var/atom/A = src.loc
					for (var/mob/O in A.contents)
						O.show_message(SPAN_EMOTE("[selected_emote.em_chattext]"), selected_emote.mode, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)


	else //The only difference between this and what comes before is that the "O.show_message()" has an extra bit with assoc_maptext = chat_text.
		 //Might be better simply to change how show_message() works, so it doesn't need this.
		 //Maybe it already does work like that?
		if (selected_emote.em_chattext)
			logTheThing(LOG_SAY, src, "EMOTE: [selected_emote.em_chattext]")
			act = lowertext(act)
			if (selected_emote.mode == VISIBLE)
				for (var/mob/O in viewers(src, null))
					O.show_message(SPAN_EMOTE("[selected_emote.em_chattext]"), selected_emote.mode, group = "[src]_[act]_[custom]")
			else if (selected_emote.mode == AUDIBLE)
				for (var/mob/O in hearers(src, null))
					O.show_message(SPAN_EMOTE("[selected_emote.em_chattext]"), selected_emote.mode, group = "[src]_[act]_[custom]")
			else if (!isturf(src.loc))
				var/atom/A = src.loc
				for (var/mob/O in A.contents)
					O.show_message(SPAN_EMOTE("[selected_emote.em_chattext]"), selected_emote.mode, group = "[src]_[act]_[custom]")


	//////////////////////////////////////////////////////
	//////////////////////////////////////////////////////
	//////////////////////////////////////////////////////
