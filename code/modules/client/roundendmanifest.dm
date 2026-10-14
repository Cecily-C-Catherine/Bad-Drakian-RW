/client/proc/view_rogue_manifest()
	var/dat
	dat += "<h3>Round ID: [GLOB.rogue_round_id]</h1>"
	for(var/X in GLOB.character_list)
		dat += "[GLOB.character_list[X]]"

	var/datum/browser/popup = new(src, "actors", "<center>Inhabitants of the Realm</center>", 387, 420)
	popup.set_content(dat)
	popup.open(FALSE)

/client/proc/view_actors_manifest()
	var/dat
	for(var/department in GLOB.actors_list)
		var/list/actors_under_department = GLOB.actors_list[department] // Used purely for a len check.
		if(actors_under_department.len)
			dat += "<h2><font color='[JCOLOR_BY_DEPARTMENT[department]]'>[department]</font></h2><hr>"
			for(var/X in GLOB.actors_list[department]) // Woe be the key value pair WITH another kv inside!!! Mwahahaha
				dat += "[GLOB.actors_list[department][X]]"

	var/datum/browser/popup = new(src, "actors", "<center>This Story's Actors</center>", 387, 420)
	popup.set_content(dat)
	popup.open(FALSE)

/client/proc/view_roleplay_ads()
	var/dat
	for(var/X in GLOB.roleplay_ads)
		dat += "[GLOB.roleplay_ads[X]]"

	var/datum/browser/popup = new(src, "actors", "<center>Roleplay Ads</center>", 500, 600)
	popup.set_content(dat)
	popup.open(FALSE)

/// Shared formatting keeps saved and manually posted ads linked to the same examine panel.
/mob/living/carbon/human/proc/publish_roleplay_ad(notify_viewers = TRUE)
	if(!length(roleplay_ad))
		LAZYREMOVE(GLOB.roleplay_ads, mobid)
		return
	var/ad_text = replacetext(html_encode(roleplay_ad), "\n", "<br>")
	LAZYSET(GLOB.roleplay_ads, mobid, "<b><a href='?src=[REF(src)];task=view_headshot'>[html_encode(real_name)]</a></b> - [ad_text]<br>")
	if(notify_viewers)
		for(var/client/advertisee in GLOB.clients)
			if(advertisee == client || !(advertisee.prefs.toggles & ROLEPLAY_ADS))
				continue
			to_chat(advertisee, span_info("[html_encode(real_name)] has set a roleplay ad."))

/// Persist only this body's originating slot, even if another slot is open in preferences.
/datum/preferences/proc/save_roleplay_ad_for_character(mob/living/carbon/human/H)
	if(!path || H.roleplay_ad_owner != parent?.ckey || !H.roleplay_ad_slot)
		return FALSE
	if(H.roleplay_ad_slot < 1 || H.roleplay_ad_slot > max_save_slots)
		return FALSE
	var/savefile/S = new /savefile(path)
	S.cd = "/character[H.roleplay_ad_slot]"
	if(H.roleplay_ad_is_gnoll)
		WRITE_FILE(S["gnoll_roleplay_ad"], H.roleplay_ad)
	else
		WRITE_FILE(S["roleplay_ad"], H.roleplay_ad)
	if(default_slot == H.roleplay_ad_slot)
		if(H.roleplay_ad_is_gnoll)
			gnoll_prefs.roleplay_ad = H.roleplay_ad
		else
			roleplay_ad = H.roleplay_ad
	return TRUE
