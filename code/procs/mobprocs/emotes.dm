// emote
#define VISIBLE 1
#define AUDIBLE 2
//#define VISIBLEAUDIBLE 3

///parent emote
ABSTRACT_TYPE(/datum/emotedata)
/datum/emotedata
	/// word you use to activate the emote, e.g. *fart (or similar). As list, to support multiple aliases
	var/list/phrase
	/// Defines if an emote is visible, audible, or both (both functionality ETA never?).
	var/mode = VISIBLE
	/// Text that goes in the chat box.
	var/em_chattext
	/// Text that floats above the emoter's head.
	var/em_maptext

	/// You must wait this long before performing another emote.
	var/cooldown
	/// Used to prevent certain beings from doing certain emotes, e.g. no birdwelling as a staffie.
	var/blacklist
	/// Same as the blacklist. Whitelist is used for simplicity's sake on things like mutrace-specific emotes
	var/whitelist

	var/usable_if_restrained = TRUE
	var/em_restrained_fail_chattext = "<B>%src%</B> struggles to move." //generic restrained failtext
	var/em_restrained_fail_maptext = "<I>struggles to move</I>"

	var/usable_if_muzzled = TRUE
	var/em_muzzled_fail_chattext = "<B>%src%</B> tries to make a noise." // generic muzzled failtext
	var/em_muzzled_fail_maptext = "<I>tries to make a noise</I>"

	New(var/emoter, var/atom/target)
		..()
		return

	nod
		phrase = list("nod")

		New(var/emoter, var/atom/target)
			em_chattext = "<B>[emoter]</B> nods."
			em_maptext = "<I>nods</I>"
			. = ..()

/*
ABSTRACT_TYPE(/datum/emotedata/targeted)
/datum/emote/targeted //unfinished
	/// Within this range, targets will appear in the list when it is first brought up.
	var/initiation_range = 5
	/// The target of the emote. Could be mob or obj.
	var/target_thing
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
		phrase = list("saluteto")
		lonely_emote = "salute"
		mode = VISIBLE
		usable_if_restrained = FALSE

		action_phrase = "salute"
		em_chattext = "<B>[src]</B> salutes [target_thing]."
		em_maptext = "<I>salutes [target_thing]</I>"

	bowto
		phrase = list("bowto")
		lonely_emote = "bow"
		mode = VISIBLE

		action_phrase = "bow before"
		em_chattext = "<B>[src]</B> bows to [target_thing]."
		em_maptext = "<I> bows to [target_thing]</I>"

	waveto
		phrase = list("waveto")
		lonely_emote = "wave"
		mode = VISIBLE

		action_phrase = "wave to"
		em_chattext = "<B>[src]</B> waves to [target_thing]."
		em_maptext = "<I> bows to [target_thing]</I>"

	blowkiss
		phrase = list("blowkiss")
		lonely_em_chattext = "<B>[src]</b> blows a kiss to... [himself_or_herself(src)]?"
		lonely_em_maptext = "<I> blows a kiss to... [himself_or_herself(src)]?</I>"
		mode = VISIBLE

		action_phrase = "blow a [prob(1) ? "smooch" : "kiss"] at"
		em_chattext = "<B>[src]</B> blows a kiss to [M]."
		em_maptext = "<I>blows a kiss to [M]</I>"

ABSTRACT_TYPE(/datum/emotedata/info)
/datum/emotedata/info //unfinished
	list
		phrase = list("list")

	listbasic
		phrase = list("listbasic")
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

	/// Are they wearing a muzzle?
	var/muzzled = (src.wear_mask && src.wear_mask.is_muzzle)
	/// Text that goes in the chat box.
	var/em_chattext
	/// Text that floats above the emoter's head.
	var/em_maptext

	var/custom = 0 //Sorry, gotta make this for chat groupings.

	// Following is intended to be replaced by the blacklist system in the future. Do not forget!
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
		em_data = get_singleton(em_data)
		if (act in em_data.phrase)
			selected_emote = em_data
			break

	if (selected_emote)
		selected_emote.New(emoter = src, target = emoteTarget)
	else if (voluntary)
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
