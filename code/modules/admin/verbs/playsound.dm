/client/proc/play_sound(S as sound)
	set category = "Special Verbs"
	set name = "play sound"

	if(!src.holder)
		src << "Only administrators may use this command."
		return

	var/sound/uploaded_sound = sound(S)
	uploaded_sound.priority = 255
	uploaded_sound.wait = 1
	uploaded_sound.channel = 999

	if(src.holder.rank == "Host" || src.holder.rank == "Coder" || src.holder.rank == "Super Administrator")
		log_admin("[key_name(src)] played sound [S]")
		message_admins("[key_name_admin(src)] played sound [S]", 1)
		for(var/client/C in world)
			if(!C.no_ambi && C.playadminsound)
				C << uploaded_sound
	else
		if(usr.client.canplaysound)
			usr.client.canplaysound = 0
			log_admin("[key_name(src)] played sound [S]")
			message_admins("[key_name_admin(src)] played sound [S]", 1)
			for(var/client/C in world)
				if(!C.no_ambi && C.playadminsound)
					C << uploaded_sound
		else
			usr << "You already used up your jukebox monies this round!"
			del(uploaded_sound)
//	else
//		usr << "Can't play Sound."


	//else
	//	alert("Debugging is disabled")
	//	return